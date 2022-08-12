# Ownable Extended

This builds upon OpenZeppelin's ownable contract (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol).

In particular, it adds the addtional functionalities of:
1. 2 step ownership transfer. Existing owner would need to nominate the new owner address and the nominee would need to accept the nomination for the ownership transfer to happen. This helps to make the ownership transfer process safer in case of address typo, etc.
2. Similar to the 2 step ownership transfer above, but with the addition of a password. In this case, nominee can only accept the nomination successfully if they include the correct password. This further improves on the safety of the ownership transfer process.
