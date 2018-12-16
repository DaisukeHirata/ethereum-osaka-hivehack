pragma solidity >=0.4.22 <0.6.0;
contract Queue {
    mapping(uint256 => address) queue;
    uint256 public first = 1;
    uint256 public last = 0;
    uint256 public length = 0;
    event enqueueItem(address addr, uint256 first ,uint256 last);
    event dequeueItem(address addr, uint256 first ,uint256 last);
    event queuedItem(address addr, uint256 index);

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

    function logAllAddress() public returns (uint256 _length) {
        for (uint256 i = first; i <= last; i++) {
            emit queuedItem(queue[i], i);
        }
        return length;
    }
}

contract Banpaku {
    event userOnTheLine(address data, uint256 index);
    event userInExpo(address data, uint256 balancd);
    // パビリオン
    struct Pavilion {
        address pavilionAddress;
        uint256 reward; // 入場報酬
        Queue waitingPeople;
    }
    Pavilion[] public pavilions;
    // 入場料の分配
    uint256 public admissionAllotment = 50;
    uint256 public defaultBalance = 100;
    mapping(address => uint256) public balanceOf;
    constructor() public {
        address pavilionAddress1 = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        Queue waitingPeople1 = new Queue();
        pavilions.push(Pavilion({
            pavilionAddress: pavilionAddress1,
            reward: 10,
            waitingPeople: waitingPeople1
        }));
        balanceOf[pavilionAddress1] = 0;

        address pavilionAddress2 = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        Queue waitingPeople2 = new Queue();
        pavilions.push(Pavilion({
            pavilionAddress: pavilionAddress2,
            reward: 50,
            waitingPeople: waitingPeople2
        }));
        balanceOf[pavilionAddress2] = 0;

        address pavilionAddress3 = 0x583031D1113aD414F02576BD6afaBfb302140225;
        Queue waitingPeople3 = new Queue();
        pavilions.push(Pavilion({
            pavilionAddress: pavilionAddress3,
            reward: 100,
            waitingPeople: waitingPeople3
        }));
        balanceOf[pavilionAddress3] = 0;
    }

    function enterExpo() public {
        balanceOf[msg.sender] = defaultBalance;
        emit userInExpo(msg.sender, balanceOf[msg.sender]);
        uint256 allotment = calcAdmissionAllotment();
        for (uint i = 0; i < pavilions.length; i++) {
            address pavilionAddress = pavilions[i].pavilionAddress;
            balanceOf[pavilionAddress] += allotment;
        }
    }

    function getInLine(uint pavilionNo) public {
        pavilions[pavilionNo].waitingPeople.enqueue(msg.sender);
    }

    function passLine(uint pavilionNo) public {
        uint256 fee = calcPassFee(pavilionNo);
        balanceOf[msg.sender] -= fee;
        distributeToken(pavilionNo, fee);
        uint256 reward = calcPavilionEntranceReward(pavilionNo);
        balanceOf[msg.sender] += reward;
    }

    function enterPavilion(uint pavilionNo) public {
        pavilions[pavilionNo].waitingPeople.dequeue();
        uint256 reward = calcPavilionEntranceReward(pavilionNo);
        balanceOf[msg.sender] += reward;
    }

    function getLength(uint pavilionNo) public view returns (uint256 _length){
        return pavilions[pavilionNo].waitingPeople.length();
    }

    function calcAdmissionAllotment() public view returns (uint256 _allotment){
        return admissionAllotment;
    }

    function calcPavilionEntranceReward(uint pavilionNo) public view returns (uint256 _reward){
        return pavilions[pavilionNo].reward;
    }

    function calcPassFee(uint pavilionNo) public view returns (uint256 _fee){
        uint256 waitingLength = pavilions[pavilionNo].waitingPeople.length();
        return waitingLength;
    }

    function distributeToken(uint pavilionNo, uint256 fee) public {
        Queue waitingPeople = pavilions[pavilionNo].waitingPeople;

        uint256 amount = fee / waitingPeople.length();

        uint256 first = waitingPeople.first();
        uint256 last = waitingPeople.last();
        for (uint256 i = first; i <= last; i++) {
            address user = waitingPeople.getAddress(i);
            balanceOf[user] += amount;
            emit userOnTheLine(user, i);
        }
    }    
}