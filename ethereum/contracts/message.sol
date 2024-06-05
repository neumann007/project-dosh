// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureMessaging {
    struct Message {
        address sender;
        string content;
        uint256 timestamp;
    }

    mapping(address => Message[]) private messages;

    event MessageSent(
        address indexed from,
        address indexed to,
        uint256 timestamp,
        string content
    );

    function sendMessage(address _to, string memory _encryptedMessage) public {
        require(_to != address(0), "Invalid recipient address");
        require(
            bytes(_encryptedMessage).length > 0,
            "Message content cannot be empty"
        );

        Message memory newMessage = Message({
            sender: msg.sender,
            content: _encryptedMessage,
            timestamp: block.timestamp
        });

        messages[_to].push(newMessage);

        emit MessageSent(msg.sender, _to, block.timestamp, _encryptedMessage);
    }

    function getMessages() public view returns (Message[] memory) {
        return messages[msg.sender];
    }

    function getMessageCount() public view returns (uint256) {
        return messages[msg.sender].length;
    }
}
