pragma solidity >=0.4.22 <0.6.0;

contract Queue {
    mapping(uint256 => address) queue;
    uint256 public first = 1;
    uint256 public last = 0;
    uint256 public length = 0;
    event enqueueItem(address addr, uint256 first ,uint256 last);
    event dequeueItem(address addr, uint256 first ,uint256 last);

    function enqueue(address addr) public {
        last += 1;
        length += 1;
        queue[last] = addr;
        emit enqueueItem(addr, first, last);
    }

    function dequeue() public returns (address addr) {
        require(last >= first);  // non-empty queue

        addr = queue[first];

        delete queue[first];
        first += 1;
        length -= 1;
        emit dequeueItem(addr, first, last);
    }
    
    function getAddress(uint256 index) public view returns (address addr) {
        return queue[index];
    }
}

contract Banpaku {
    Queue waitingUsers;
    mapping(address => Queue) public pavilionQueue;
    event userOnTheLine(address data, uint256 index);

    constructor() public {
        waitingUsers = new Queue();
    }
        
    function goToTheLine() public {
        waitingUsers.enqueue(msg.sender);
    }
    
    function enterPavilion() public {
        waitingUsers.dequeue();
    }
    
    function getLength() public view returns (uint256 _length){
        return waitingUsers.length();
    }
    
    function distributeToken() public {
        uint256 first = waitingUsers.first();
        uint256 last = waitingUsers.last();
        for (uint256 i = first; i <= last; i++) {
            address user = waitingUsers.getAddress(i);
            emit userOnTheLine(user, i);
        }
    }    
}