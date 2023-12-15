# SafeERC20 Wrapper

- Fixes the inconsequent return values of transfer(). If it returns a value that is not `true`, the transaction will revert.
- It is a must to use this safe wrapper if you interact with external ERC20 tokens. If you have written the ERC20 token contract yourself, there's no need.

# ERC20 Limitations

- ERC20 needs 2 transactions to make a third party move a token, approve and transferFrom. This leads to bad UX and it can be hard to build good dApps because of this.
- if you use transfer() to a contract that can't handle them, the function won't revert and they will get stuck in the destination contract as a consequence.
- another limitation is that the ERC20 standard doesn't provide any way to listen for incoming tokens, so you can't interact with an ERC20 contract and make it do something when receiving tokens, like an ERC721/ERC777 can do with hooks
