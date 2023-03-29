// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuthenticationContract{

    // Structs for storing information about fog nodes and IoT devices
    struct FogNode {
        address nodeAddress;
        mapping(address => bool) devices;
    }
    
    // Structs for storing information about fog nodes and IoT devices
    struct IoTDevice {
        address deviceAddress;
        address fogNodeAddress;
    }
    
    // Mappings to store fog nodes and IoT devices
    mapping(address => FogNode) public fogNodes;
    mapping(address => IoTDevice) public IoTDevices;
    
    // Admins for managing access control
    mapping(address => bool) public admins;
    address public owner;
    
    // Events for tracking registration and de-registration of fog nodes and IoT devices
    event FogNodeRegistered(address indexed fogNodeAddress);
    event FogNodeDeregistered(address indexed fogNodeAddress);
    event IoTDeviceRegistered(address indexed deviceAddress, address indexed fogNodeAddress);
    event IoTDeviceDeregistered(address indexed deviceAddress);
    event InternalConnection(address indexed deviceAddress1, address indexed deviceAddress2);
    
    // Modifiers for checking admin and owner permissions
    modifier onlyAdmin() {
        //Note: Only Used for Deployment
        //require(admins[msg.sender], "Only admins can perform this action.");
        _;
    }
    
    modifier onlyOwner() {
        //Note: Only Used for Deployment
        //require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Constructor to set the owner as the first admin
    constructor() {
        owner = msg.sender;
        admins[owner] = true;
    }
    
    // Function for adding new admins
    function addAdmin(address newAdmin) public onlyOwner {
        admins[newAdmin] = true;
    }
    
    // Function for removing admins
    function removeAdmin(address admin) public onlyOwner {
        require(admin != owner, "The owner cannot be removed as an admin.");
        admins[admin] = false;
    }
    
    // Function for registering a fog node
    function registerFogNode(address fogNodeAddress) public onlyAdmin {
        fogNodes[fogNodeAddress].nodeAddress = fogNodeAddress;
        emit FogNodeRegistered(fogNodeAddress);
    }
    
    // Function for deregistering a fog node
    function deregisterFogNode(address fogNodeAddress) public onlyAdmin {
        delete fogNodes[fogNodeAddress];
        emit FogNodeDeregistered(fogNodeAddress);
    }
    
    // Function for registering an IoT device
    function registerIoTDevice(address deviceAddress, address fogNodeAddress) public onlyAdmin {
        IoTDevices[deviceAddress].deviceAddress = deviceAddress;
        IoTDevices[deviceAddress].fogNodeAddress = fogNodeAddress;
        fogNodes[fogNodeAddress].devices[deviceAddress] = true;
        emit IoTDeviceRegistered(deviceAddress, fogNodeAddress);
    }
    
    // Function for deregistering an IoT device
    function deregisterIoTDevice(address deviceAddress) public onlyAdmin {
        address fogNodeAddress = IoTDevices[deviceAddress].fogNodeAddress;
        delete IoTDevices[deviceAddress];
        delete fogNodes[fogNodeAddress].devices[deviceAddress];
        emit IoTDeviceDeregistered(deviceAddress);
    }

    // Internal connection between devices with same fog node
    function connectDevices(address deviceAddress1, address deviceAddress2) public {
        address fogNodeAddress = IoTDevices[deviceAddress1].fogNodeAddress;
        require(IoTDevices[deviceAddress2].fogNodeAddress == fogNodeAddress, "Devices are not in the same fog node.");
        emit InternalConnection(deviceAddress1, deviceAddress2);
    }    
}
