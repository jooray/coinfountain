pragma solidity ^0.4.0;
contract CoinFountain {
    uint payoutPerPeriod;
    uint periodDuration;
    uint firstTouch;
    address[] touchers;
    address owner;
    
    // fountain information
    uint latitude; uint longtitude;
    string description;
    
    event FountainFunded(address funder, uint amount);
    event PeriodPaidOut(address toucher, uint periodStart);
    event Touched(address toucher);

    
    function CoinFointain(uint _payoutPerPeriod, uint _periodDuration, uint _latitude,
        uint _longtitude, string _description) {
        firstTouch = now;
        payoutPerPeriod = _payoutPerPeriod;
        periodDuration = _periodDuration;
        owner = msg.sender;
        
        latitude = _latitude; longtitude = _longtitude; description = _description;
    }
    
    function getFountainInformation() constant returns(uint, uint, uint, uint, string, uint, uint) {
        return (payoutPerPeriod, periodDuration, latitude, longtitude, description,
          firstTouch, touchers.length);
    }    
    
    function fund() payable {
        assert(msg.value > 0);
        // yay, we got funded!
        FountainFunded(msg.sender, msg.value);
    }
    
    function payOut() {
        if ((firstTouch + periodDuration <= now) || (this.balance < payoutPerPeriod) || (touchers.length == 0))
            return;
        uint payoutPerToucher = payoutPerPeriod / touchers.length; // should use SafeMath
        for (uint i = 0; i < touchers.length; i++) {
            touchers[i].transfer(payoutPerToucher);
            PeriodPaidOut(touchers[i], firstTouch);
        }
        delete touchers;
    }
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _; // call rest of the function
    }
    
    // called by the fountain hardware to add toucher
    function touch(address toucher) onlyOwner {
        payOut(); // if this is a new period, make sure the last one is settled
        if (touchers.length == 0)
            firstTouch = now;
        touchers.push(toucher);
        Touched(toucher);
    }
    
    // utility functions
    
    function changeOwner(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
