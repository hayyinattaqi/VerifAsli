// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VerifAsli
/// @notice On-chain ownership and anti-theft registry for physical items
///         (phones, laptops, bikes, cameras). Anyone can register an item,
///         mark it as stolen, and anyone can look up an item's status
///         before buying it second-hand — without needing a wallet.
/// @dev Deploy once via Remix to BOT Chain testnet, verify all functions,
///      then redeploy to BOT Chain mainnet. Built for Girl Meets Tech
///      Build Week Hackathon Vol.2 (RWA Track).
contract VerifAsli {
    struct Item {
        address owner;
        string name;
        bool isStolen;
        uint256 registeredAt;
        uint256 stolenAt;
    }

    /// @notice itemId => Item data
    mapping(uint256 => Item) public items;

    /// @notice hash(serial/IMEI) => already registered? Prevents the same
    ///         physical item from being registered twice under different
    ///         names/owners.
    mapping(bytes32 => bool) public serialUsed;

    /// @notice Auto-incrementing counter, also used as the public item ID
    ///         encoded into each item's QR code.
    uint256 public nextItemId;

    event ItemRegistered(uint256 indexed itemId, address indexed owner, string name, uint256 timestamp);
    event ItemMarkedStolen(uint256 indexed itemId, uint256 timestamp);
    event OwnershipTransferred(uint256 indexed itemId, address indexed from, address indexed to);

    modifier onlyItemOwner(uint256 itemId) {
        require(items[itemId].owner == msg.sender, "Not the owner");
        _;
    }

    /// @notice Register a physical item under the caller's wallet.
    /// @param serialHash keccak256 hash of the item's serial number/IMEI,
    ///        computed off-chain so the raw serial is never stored publicly.
    /// @param name Human-readable label, e.g. "iPhone 13 - blue sticker".
    /// @return itemId The new item's public ID (encode this into its QR code).
    function registerItem(bytes32 serialHash, string memory name) public returns (uint256) {
        require(!serialUsed[serialHash], "Item already registered");
        require(bytes(name).length > 0, "Name required");

        serialUsed[serialHash] = true;
        uint256 id = nextItemId;
        nextItemId++;

        items[id] = Item({
            owner: msg.sender,
            name: name,
            isStolen: false,
            registeredAt: block.timestamp,
            stolenAt: 0
        });

        emit ItemRegistered(id, msg.sender, name, block.timestamp);
        return id;
    }

    /// @notice Mark an item you own as stolen. Permanent and publicly visible.
    function reportStolen(uint256 itemId) public onlyItemOwner(itemId) {
        require(!items[itemId].isStolen, "Already marked stolen");
        items[itemId].isStolen = true;
        items[itemId].stolenAt = block.timestamp;
        emit ItemMarkedStolen(itemId, block.timestamp);
    }

    /// @notice Transfer a clean (not stolen) item to a new owner, e.g. after
    ///         a legitimate second-hand sale. Stretch goal — safe to skip
    ///         for the MVP submission.
    function transferOwnership(uint256 itemId, address newOwner) public onlyItemOwner(itemId) {
        require(!items[itemId].isStolen, "Cannot transfer a stolen item");
        require(newOwner != address(0), "Invalid new owner");
        address oldOwner = items[itemId].owner;
        items[itemId].owner = newOwner;
        emit OwnershipTransferred(itemId, oldOwner, newOwner);
    }

    /// @notice Public read-only lookup. Callable by anyone, no wallet needed —
    ///         this is what a buyer scanning a QR code calls before paying.
    function checkStatus(uint256 itemId)
        public
        view
        returns (address owner, string memory name, bool isStolen, uint256 registeredAt)
    {
        Item memory it = items[itemId];
        return (it.owner, it.name, it.isStolen, it.registeredAt);
    }
}
