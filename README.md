# VerifAsli

**On-chain ownership tags that make stolen items hard to resell.**

Built for Girl Meets Tech's Build Week Hackathon Vol.2 (RWA Track), on BOT Chain.

## What it does

VerifAsli lets anyone register a physical item — a phone, laptop, bike, or camera — as owned by their wallet on BOT Chain. Every registered item gets a QR tag you print and stick on the actual item.

If the item is lost or stolen, the owner marks it as stolen with one transaction. That status is permanent and public. Anyone — a friend, a second-hand buyer, a pawn shop — can scan the tag and see the item's status instantly, with no wallet or account required on their end.

The idea isn't to reward whoever finds a lost item. It's to make stolen goods hard to sell in the first place: once an item is flagged, its resale market disappears, because any careful buyer can check before paying.

## How someone would use it

1. **Register.** Connect your wallet on the site, name your item, and enter its serial number or IMEI. You get back an item ID and a QR code.
2. **Attach.** Print the QR tag and stick it on the item itself.
3. **Report if stolen.** If the item goes missing, open its page and click "Mark as Stolen." Only your wallet can do this for items you registered.
4. **Check before buying.** Anyone can scan the tag (or open its link) to see the item's name, registration date, and whether it's been reported stolen — straight from the blockchain, no sign-up needed.
5. **Sell it legitimately.** If you sell a clean (non-stolen) item, transfer it to the buyer's wallet from the item's page. The tag stays valid — it just now points to the new owner.

## Why the serial number isn't stored in plain text

The raw serial/IMEI is hashed with `keccak256` in the browser before it's sent to the contract. On-chain, only the hash is stored (`serialUsed` mapping), which is enough to prevent the same item being registered twice, without exposing the real serial number to anyone reading the chain.

## Tech stack

- **Smart contract:** Solidity `^0.8.20`, written and deployed via Remix IDE.
- **Frontend:** a single `index.html` file — no build step, no backend. Uses `ethers.js` (v5, loaded from a CDN) for wallet interaction and `qrcode.js` for generating tags client-side.
- **Hosting:** GitHub Pages, served from a custom domain.

## Project structure

```
verifasli/
├── contracts/
│   ├── VerifAsli.sol        # the smart contract
│   └── VerifAsli.abi.json   # extracted ABI (for reference / Remix)
├── index.html                # the entire frontend
└── README.md
```

## Running it yourself / redeploying

1. Open `contracts/VerifAsli.sol` in [Remix](https://remix.ethereum.org), compile with Solidity `0.8.20`.
2. Deploy via "Injected Provider - MetaMask" while connected to BOT Chain Testnet (see network details below).
3. Copy the deployed address into `CONFIG.testnet.contractAddress` in `index.html`.
4. Test every action on testnet: register an item, mark it stolen, open its status page in an incognito window (no wallet) to confirm the public read-only view works.
5. Repeat the deploy on BOT Chain Mainnet, copy that address into `CONFIG.mainnet.contractAddress`, and flip `CONFIG.active` to `"mainnet"`.
6. Push `index.html` to a GitHub Pages–hosted repo and point your domain at it.

### BOT Chain network details

| | Testnet | Mainnet |
|---|---|---|
| Chain ID | 968 | 677 |
| RPC URL | `https://rpc.bohr.life` | `https://rpc.botchain.ai` |
| Explorer | `https://scan.bohr.life` | `https://scan.botchain.ai` |
| Get tokens | [faucet.botchain.ai/basic](https://faucet.botchain.ai/basic) | Organizer allocation (contact ahead of deploy) |

## Deployment

- **Testnet contract address:** `0x...` <!-- fill in after deploying to BOT Chain Testnet -->
- **Mainnet contract address:** `0x...` <!-- fill in after deploying to BOT Chain Mainnet -->
- **Live site:** `https://...` <!-- your custom domain -->

## What's not included (by design)

This is a hackathon MVP. Left out on purpose so the core flow stays reliable and easy to demo:

- No identity verification (KYC) of who's registering an item.
- No reward or payment mechanism for finders — see "Why" above for the reasoning.
- No ownership history list (past owners aren't shown, only the current one) — the `OwnershipTransferred` event is on-chain if this is added later.
- No multi-item dashboard ("all items I own") — each item is looked up by its own link/QR code.