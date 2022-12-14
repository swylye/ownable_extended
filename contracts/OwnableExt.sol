// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract OwnableExt {
    address private _owner;
    address private _nominee;

    mapping(address => bytes32) private nomineeToHash;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "NOT_OWNER");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    // 2 step process to transfer ownership
    // - existing owner calls nominateNewOwner function with nominee address
    // - nominee then accepts the nomination by calling acceptNomination which results in the transfer of ownership
    // Safer way of transferring ownership (in case of transferring to the wrong address directly)
    function nominateNewOwner(address _nomineeAdd) external virtual onlyOwner {
        require(_nomineeAdd != address(0), "INVALID_ADDRESS");
        _nominee = _nomineeAdd;
    }

    function acceptNomination() external virtual {
        require(_nominee == msg.sender, "NOT_NOMINEE");
        _nominee = address(0);
        _transferOwnership(msg.sender);
    }

    // Similar 2 step process to transfer ownership as above but with the addition of password
    // Choose a password then use hashString function to get the hashedString, include the hashedString together with nominee address to nominate a new owner
    // Nominee would need to include the password to accept the nomination
    function nominateNewOwnerPW(address _nomineeAdd, bytes32 _hashedString)
        external
        virtual
        onlyOwner
    {
        require(_nomineeAdd != address(0), "INVALID_ADDRESS");
        nomineeToHash[_nomineeAdd] = _hashedString;
    }

    function acceptNominationPW(string memory _password) external virtual {
        require(nomineeToHash[msg.sender] != 0, "NOT_NOMINEE");
        require(
            hashString(_password) == nomineeToHash[msg.sender],
            "INCORRECT_PASSWORD"
        );
        delete nomineeToHash[msg.sender];
        _transferOwnership(msg.sender);
    }

    function hashString(string memory _string)
        public
        pure
        virtual
        returns (bytes32 hashedString)
    {
        hashedString = keccak256(abi.encodePacked(_string));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) external virtual onlyOwner {
        require(_newOwner != address(0), "INVALID_ADDRESS");
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address _newOwner) internal virtual {
        address _oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }
}
