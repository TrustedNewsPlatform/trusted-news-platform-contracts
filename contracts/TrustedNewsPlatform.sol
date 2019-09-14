pragma solidity 0.5.10;


contract TrustedNewsPlatform {

    // Structs

    struct News {
        address publisher;
        address[] requireApprovals;
        mapping(address => bool) approvals;

        bool isFake;
    }

    // Events

    event NewsPublished(
        address indexed publisher,
        address[] indexed concerns,
        bytes32 newsIpfsHash
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

        for(uint i = 0; i < news[_newsIpfsHash].requireApprovals.length; i++) {
            if(msg.sender == news[_newsIpfsHash].requireApprovals[i]) {
                isValid = true;
            }
        }
        require(isValid, "Invalid approver");
        _;
    }

    function publishNews(bytes32 _newsIpfsHash, address[] memory _requiresApprovals) public
    hashIsNotTaken(_newsIpfsHash)
    {
        news[_newsIpfsHash] = News({
            publisher: msg.sender,
            requireApprovals: _requiresApprovals,
            isFake: true
        });
        emit NewsPublished(msg.sender, _requiresApprovals, _newsIpfsHash);
    }

    function approveNews(bytes32 _newsIpfsHash) public
    doesNewsExist(_newsIpfsHash)
    isApproverValid(_newsIpfsHash)
    {
        news[_newsIpfsHash].approvals[msg.sender] = true;

        uint numberOfApprovals;

        for(uint i = 0; i < news[_newsIpfsHash].requireApprovals.length; i++) {
            if(news[_newsIpfsHash].approvals[news[_newsIpfsHash].requireApprovals[i]]) {
                numberOfApprovals++;
            }
        }

        if(numberOfApprovals == news[_newsIpfsHash].requireApprovals.length) {
            news[_newsIpfsHash].isFake = false;

            for(uint i = 0; i < news[_newsIpfsHash].requireApprovals.length; i++) {
                newsConcerning[news[_newsIpfsHash].requireApprovals[i]].push(_newsIpfsHash);
            }

            emit NewsMarkedAsNotFake(_newsIpfsHash);
        }

        emit NewsApproved(_newsIpfsHash, msg.sender);
    }

    function disapproveNews(bytes32 _newsIpfsHash, bytes32 _explanationIpfsHash) public
    doesNewsExist(_newsIpfsHash)
    isApproverValid(_newsIpfsHash)
    {
        news[_newsIpfsHash].approvals[msg.sender] = false;
        emit NewsDisapproved(_newsIpfsHash, msg.sender, _explanationIpfsHash);
    }
}