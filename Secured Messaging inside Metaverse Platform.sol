// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SecureMessagingInsideMetaverse {
    // Admin of the contract
    address public admin;

    // Mapping to track users and their access status
    mapping(address => bool) public users;

    // Mapping to track message requests between users
    mapping(address => mapping(address => bool)) public messageRequests;

    // Mapping to store actual messages between users
    mapping(address => mapping(address => string)) public messages;

    // Events for important contract actions
    event UserAdded(address user);
    event MessageRequestSent(address from, address to);
    event MessageSent(address from, address to, string message);
    event MessageRequestAccepted(address from, address to);
    event MessageRequestRejected(address from, address to);

    // Modifier to restrict access to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }

    // Modifier to restrict access to only registered users
    modifier onlyUsers() {
        require(users[msg.sender], "User does not have access");
        _;
    }

    // Constructor to set the admin and register the admin as the first user
    constructor() {
        admin = msg.sender;
        users[admin] = true;
        emit UserAdded(admin);
    }

    // Function for the admin to add a new user
    function addUser(address _user) external onlyAdmin {
        require(!users[_user], "This User already exists");
        users[_user] = true;
        emit UserAdded(_user);
    }

    // Function for a user to request access (admin approval required)
    function requestAccess() external {
        require(!users[msg.sender], "This User already has access");
        users[msg.sender] = false; // Mark user as pending until admin approval
    }

    // Function for the admin to approve access for a user
    function approveAccess(address _user) external onlyAdmin {
        require(!users[_user], "This User already has access");
        users[_user] = true;
        emit UserAdded(_user);
    }

    // Function for a user to send a message request to another user
    function sendRequest(address _to) external onlyUsers {
        require(users[_to], "The Recipient does not have access");
        require(!messageRequests[msg.sender][_to], "The Request already sent");
        messageRequests[msg.sender][_to] = true;
        emit MessageRequestSent(msg.sender, _to);
    }

    // Function for a user to accept a message request
    function acceptRequest(address _from) external onlyUsers {
        require(messageRequests[_from][msg.sender], "There is No pending request from sender");
        emit MessageRequestAccepted(_from, msg.sender);
        delete messageRequests[_from][msg.sender];
    }

    // Function for a user to reject a message request
    function rejectRequest(address _from) external onlyUsers {
        require(messageRequests[_from][msg.sender], "There is No pending request from sender");
        emit MessageRequestRejected(_from, msg.sender);
        delete messageRequests[_from][msg.sender];
    }

    // Function for a user to send a message to another user
    function sendMessage(address _to, string memory _message) external onlyUsers {
        require(users[_to], "The Recipient does not have access");
        require(bytes(_message).length > 0, "Message cannot be empty");
        messages[msg.sender][_to] = _message;
        emit MessageSent(msg.sender, _to, _message);
    }

    // Function to retrieve a message between two users
    function getMessage(address _from, address _to) external view returns (string memory) {
        require(users[_from] && users[_to], "Invalid users");
        return messages[_from][_to];
    }
}
