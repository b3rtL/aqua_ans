pragma solidity ^0.4.2;

contract NameService {

  address addr;
  bytes32 subname;
  uint fee;
  uint total;
  address creator;
  uint public nameCount;

  struct AddressCard {
      address owner;
      address addr;
      uint balance;
      uint ttl;
      }

  mapping(bytes32 => AddressCard) nameList;

  modifier hasBalance() {
      require(address(this).balance > 0);
      _;
  }

  modifier isOwner(bytes32 name) {
    require(msg.sender == nameList[name].owner);
    _;
  }

  modifier isCreator() {
    require(msg.sender == creator);
    _;
  }

  event NameCreated(bytes32 indexed name);
  event AddressChanged(bytes32 indexed name, address indexed _addr, address indexed _newaddr);
  event OwnerTransferred(bytes32 indexed name, address indexed _owner, address indexed _newowner);
  event NewSubOwner(bytes32 name, bytes32 sub, address _owner);

  constructor() public payable{
    creator = msg.sender;
    nameList[0x0].owner = msg.sender;
    nameCount = 0;
  }

  function createName(bytes32 name, address _addr) public payable {
    require(msg.value == 1000000000000000000);
    assert(nameList[name].addr != _addr);
      nameList[name].owner = msg.sender;
      nameList[name].addr = _addr;
      emit NameCreated(name);
      nameCount++;
  }

  function setSubnameOwner(bytes32 name, bytes32 sub, address _owner) public isOwner(name) {
        subname = keccak256(abi.encodePacked(name, sub));
        emit NewSubOwner(name, sub, _owner);
        nameList[subname].owner = _owner;
    }

  function setOwner(bytes32 name, address _newowner) public isOwner(name) payable {
    require(msg.value == 100000000000000000);
    nameList[name].owner = _newowner;
  }

  function changeAddress(bytes32 name, address _newaddr) public isOwner(name) payable {
    require(msg.value == 100000000000000000);
    require(nameList[name].addr != _newaddr);
    emit AddressChanged(name, nameList[name].addr, _newaddr);
    nameList[name].addr = _newaddr;
  }

  function getOwner(bytes32 name) public view returns (address){
    return nameList[name].owner;
  }


  function getAddress(bytes32 name) public view returns (address){
    return nameList[name].addr;
  }

  function liquidate() public isCreator hasBalance {
    msg.sender.transfer(address(this).balance);
  }
}
