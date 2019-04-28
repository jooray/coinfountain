pragma solidity ^0.5.0;
contract CoinFountain {
    uint payoutPerPeriod;
    uint periodDuration;
    uint firstTouch;
    address[]  touchers;
    address owner;
    
    // fountain information
    uint latitude; uint longtitude;
    string description;
    
    event FountainFunded(address funder, uint amount);
    event PeriodPaidOut(address toucher, uint periodStart);
    event Touched(address toucher);
    
    mapping (address => uint) pendingWithdrawals;

    
    constructor(uint _payoutPerPeriod, uint _periodDuration, uint _latitude,
        uint _longtitude, string memory _description) public {
        firstTouch = block.timestamp;
        payoutPerPeriod = _payoutPerPeriod;
        periodDuration = _periodDuration;
        owner = msg.sender;
        
        latitude = _latitude; longtitude = _longtitude; description = _description;
    }
    
    function getFountainInformation() view public returns(uint, uint, uint, uint, string memory, uint, uint) {
        return (payoutPerPeriod, periodDuration, latitude, longtitude, description,
          firstTouch, touchers.length);
    }    
    
    function fund() public payable {
        require(msg.value > 0);
        // yay, we got funded!
        emit FountainFunded(msg.sender, msg.value);
    }
    
    function payOut() public {
        if ((firstTouch + periodDuration > block.timestamp) || (address(this).balance < payoutPerPeriod) || (touchers.length == 0))
            return;
        uint payoutPerToucher = payoutPerPeriod / touchers.length; // should use SafeMath
        for (uint i = 0; i < touchers.length; i++) {
            pendingWithdrawals[touchers[i]] += payoutPerToucher;
            emit PeriodPaidOut(touchers[i], firstTouch);
        }
        delete touchers;
    }
    
    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _; // call rest of the function
    }
    
    // called by the fountain hardware to add toucher
    function touch(address toucher) onlyOwner public {
        payOut(); // if this is a new period, make sure the last one is settled
        if (touchers.length == 0)
            firstTouch = block.timestamp;
        touchers.push(toucher);
        emit Touched(toucher);
    }
    
    // utility functions
    
    function changeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
