pragma solidity 0.5.10;


contract EntitiesList {
    address owner;
    string[] domains;
    mapping(string => address) dnsAddresses;

    constructor() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only the contract owner can call this method");
        _;
    }

    function setNewDns(string calldata _dnsName, address _entityAddress) external {
        if(dnsAddresses[_dnsName] == address(0)) {
            domains.push(_dnsName);
        }
        dnsAddresses[_dnsName] = _entityAddress;
    }



}