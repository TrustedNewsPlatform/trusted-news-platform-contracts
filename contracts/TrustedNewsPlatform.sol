pragma solidity 0.5.10;


contract TrustedNewsPlatform {

    // Structs

    struct News {
        address publisher;
        address[] concerns;
        mapping(address => bool) approvals;
        mapping(address => bool) didVote;
        uint remainingApprovals;
        uint publishmentTimestamp;
    }

    // Events

    event NewsPublished(
        address indexed publisher,
        address[] indexed concerns,
        bytes32 newsIpfsHash,
        uint publishmentTimestamp
    );
    event NewsApproved(
        bytes32 indexed newsIpfsHash,
        address approver
    );
    event NewsDisapproved(
        bytes32 indexed newsIpfsHash,
        address disapprover,
        bytes32 explanationIpfsHash
    );

    event NewsMarkedAsNotFake(
        bytes32 indexed newsIpfsHash
    );

    // Properties

    mapping(bytes32 => News) news;
    mapping(address => bytes32[]) newsConcerning;

    // Modifiers

    modifier hashIsNotTaken(bytes32 _newsIpfsHash) {
        require(news[_newsIpfsHash].publisher == address(0), "This news has already been taken");
        _;
    }

    modifier doesNewsExist(bytes32 _ipfsHash) {
        require(news[_ipfsHash].publisher != address(0), "News with the given hash does not exist");
        _;
    }

    modifier isApproverValid(bytes32 _newsIpfsHash) {
        bool isValid = false;

        for(uint i = 0; i < news[_newsIpfsHash].concerns.length; i++) {
            if(msg.sender == news[_newsIpfsHash].concerns[i]) {
                isValid = true;
                break;
            }
        }
        require(isValid, "Invalid approver");
        _;
    }

    modifier didNotVote(bytes32 _newsIpfsHash) {
        require(!news[_newsIpfsHash].didVote[msg.sender], "Sorry you already voted");
        _;
    }

    // State changing functions

    function publishNews(bytes32 _newsIpfsHash, address[] memory _requiredApprovals) public
    hashIsNotTaken(_newsIpfsHash)
    {
        news[_newsIpfsHash] = News({
            publisher: msg.sender,
            concerns: _requiredApprovals,
            remainingApprovals: _requiredApprovals.length,
            publishmentTimestamp: block.timestamp
        });
        for(uint i = 0; i < _requiredApprovals.length; i++) {
            newsConcerning[_requiredApprovals[i]].push(_newsIpfsHash);
        }
        emit NewsPublished(msg.sender, _requiredApprovals, _newsIpfsHash, block.timestamp);
    }

    function approveNews(bytes32 _newsIpfsHash) public
    doesNewsExist(_newsIpfsHash)
    isApproverValid(_newsIpfsHash)
    didNotVote(_newsIpfsHash)
    {
        require(!news[_newsIpfsHash].approvals[msg.sender], "You already approved this news");

        news[_newsIpfsHash].approvals[msg.sender] = true;
        news[_newsIpfsHash].remainingApprovals--;

        if(news[_newsIpfsHash].remainingApprovals == 0)
        {
            emit NewsMarkedAsNotFake(_newsIpfsHash);
        }

        news[_newsIpfsHash].didVote[msg.sender] = true;

        emit NewsApproved(_newsIpfsHash, msg.sender);
    }

    function disapproveNews(bytes32 _newsIpfsHash, bytes32 _explanationIpfsHash) public
    doesNewsExist(_newsIpfsHash)
    isApproverValid(_newsIpfsHash)
    didNotVote(_newsIpfsHash)
    {
        news[_newsIpfsHash].approvals[msg.sender] = false;
        news[_newsIpfsHash].didVote[msg.sender] = true;

        emit NewsDisapproved(_newsIpfsHash, msg.sender, _explanationIpfsHash);
    }

    // Getters

    function isHashValid(bytes32 _newsIpfsHash) public view returns(bool) {
        return news[_newsIpfsHash].publisher != address(0);
    }

    function getNewsPublisher(bytes32 _newsIpfsHash) public view returns(address) {
        return news[_newsIpfsHash].publisher;
    }

    function getNewsConcerns(bytes32 _newsIpfsHash) public view returns(address[] memory) {
        return news[_newsIpfsHash].concerns;
    }

    function isNewsApprovedBy(bytes32 _newsIpfsHash, address _approver) public view returns(bool) {
        return news[_newsIpfsHash].approvals[_approver];
    }

    function getNewsRemainingApprovals(bytes32 _newsIpfsHash) public view returns(uint) {
        return news[_newsIpfsHash].remainingApprovals;
    }

    function getNewsConcerning(address _entity) public view returns(bytes32[] memory) {
        return newsConcerning[_entity];
    }

    function getNewsConceringCount(address _entity) public view returns(uint) {
        return newsConcerning[_entity].length;
    }

    function getNewsConceringByID(address entity, uint _id) public view returns(bytes32) {
        require(_id < newsConcerning[entity].length, "Document with the given id does not exist");
        return newsConcerning[entity][_id];
    }

    function didVote(bytes32 _newsIpfsHash, address _entity) public view returns(bool) {
        return news[_newsIpfsHash].didVote[_entity];
    }

    function getNewsPublishmentTimestamp(bytes32 _newsIpfsHash) public view returns(uint) {
        return news[_newsIpfsHash].publishmentTimestamp;
    }
}