pragma solidity ^0.4.26;

contract Dosh {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    enum Role {
        None,
        Client,
        SpecialClient,
        MedicalProfessional,
        Pharmacy,
        SpecialPharmacy
    }
    enum OrderStatus {
        Pending,
        Shipped,
        Delivered
    }

    struct User {
        address user;
        string name;
        string location;
        //Role role;
    }

    struct Drug {
        uint id;
        string name;
        bool isSpecial;
        address pharmacy;
        uint price;
    }

    struct Order {
        uint id;
        uint drugId;
        address client;
        OrderStatus status;
    }

    struct Message {
        uint id;
        address sender;
        address receiver;
        string content;
    }

    User[] public users;
    uint public drugCount = 0;
    uint public orderCount = 0;
    uint public messageCount = 0;

    mapping(address => Role) public roles;
    mapping(uint => Drug) public drugs;
    mapping(uint => Order) public orders;
    mapping(uint => Message) public messages;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPharmacy() {
        require(
            roles[msg.sender] == Role.Pharmacy ||
                roles[msg.sender] == Role.SpecialPharmacy
        );
        _;
    }

    modifier onlyClient() {
        require(
            roles[msg.sender] == Role.Client ||
                roles[msg.sender] == Role.SpecialClient
        );
        _;
    }

    modifier onlySpecialClient() {
        require(roles[msg.sender] == Role.SpecialClient);
        _;
    }

    function setRole(address user, Role role) public /* onlyOwner */ {
        roles[user] = role;
    }

    function upgradeToSpecialClient(address client) public onlyOwner {
        require(roles[client] == Role.Client);
        roles[client] = Role.SpecialClient;
    }

    function addUser(address user, string name, string location) public {
        User memory newUser = User({
            user: user,
            name: name,
            location: location
        });
        users.push(newUser);
    }

    function addDrug(
        string name,
        bool isSpecial,
        uint price
    ) public onlyPharmacy {
        if (isSpecial) {
            require(roles[msg.sender] == Role.SpecialPharmacy);
        }
        drugCount++;
        drugs[drugCount] = Drug(drugCount, name, isSpecial, msg.sender, price);
    }

    function placeOrder(uint drugId) public onlyClient {
        Drug storage drug = drugs[drugId];
        if (drug.isSpecial) {
            require(roles[msg.sender] == Role.SpecialClient);
        }
        orderCount++;
        orders[orderCount] = Order(
            orderCount,
            drugId,
            msg.sender,
            OrderStatus.Pending
        );
    }

    function updateOrderStatus(
        uint orderId,
        OrderStatus status
    ) public onlyPharmacy {
        Order storage order = orders[orderId];
        require(drugs[order.drugId].pharmacy == msg.sender);
        order.status = status;
    }

    // function sendMessage(address receiver, string content) public {
    //     require(roles[msg.sender] != Role.None && roles[receiver] != Role.None);
    //     messageCount++;
    //     messages[messageCount] = Message(
    //         messageCount,
    //         msg.sender,
    //         receiver,
    //         content
    //     );
    // }

    function getDrug(
        uint drugId
    ) public view returns (uint, string, bool, address, uint) {
        Drug storage drug = drugs[drugId];
        if (drug.isSpecial) {
            require(
                roles[msg.sender] == Role.SpecialClient ||
                    roles[msg.sender] == Role.MedicalProfessional ||
                    roles[msg.sender] == Role.Pharmacy ||
                    roles[msg.sender] == Role.SpecialPharmacy
            );
        }
        return (drug.id, drug.name, drug.isSpecial, drug.pharmacy, drug.price);
    }

    function getOrder(
        uint orderId
    ) public view returns (uint, uint, address, OrderStatus) {
        Order storage order = orders[orderId];
        require(
            order.client == msg.sender ||
                drugs[order.drugId].pharmacy == msg.sender ||
                roles[msg.sender] == Role.MedicalProfessional
        );
        return (order.id, order.drugId, order.client, order.status);
    }

    // function getMessage(
    //     uint messageId
    // ) public view returns (uint, address, address, string) {
    //     Message storage message = messages[messageId];
    //     require(
    //         message.sender == msg.sender ||
    //             message.receiver == msg.sender ||
    //             roles[msg.sender] == Role.MedicalProfessional
    //     );
    //     return (message.id, message.sender, message.receiver, message.content);
    // }
}
