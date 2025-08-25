Property Tokenization Smart Contract

Overview

This smart contract enables fractional ownership of real estate using SIP-010 compliant fungible tokens on the Stacks blockchain. Each property can be registered by the contract owner, tokenized into shares, and sold to investors. Holders of property shares can freely transfer or sell them to others, creating a decentralized property investment ecosystem.

✨ Features

Fractional Ownership: Real estate is divided into fungible tokens (PST) representing property shares.

Property Registration: Only the contract owner can register properties and tokenize them into shares.

Buying & Selling Shares: Investors can purchase shares from property owners or sell shares to other investors.

SIP-010 Compliance: Implements standard fungible token functions (transfer, get-balance, get-total-supply, etc.).

Ownership Tracking: Maintains a mapping of share ownership per property for transparency.

On-chain Property Records: Stores property metadata (address, value, shares, price per share, active status).

⚙️ Key Data Structures

properties – Stores property details including owner, address, total value, share count, price per share, and status.

property-shares – Tracks the number of shares held by each investor for each property.

token-balances – Maps each account to its token balance.

total-supply – Tracks total supply of tokens in circulation.

🚀 Public Functions
SIP-010 Token Functions

transfer(amount, from, to, memo) – Transfer tokens between users.

get-name() – Returns "Property Share Token".

get-symbol() – Returns "PST".

get-decimals() – Returns 6.

get-balance(who) – Returns balance of who.

get-total-supply() – Returns total minted supply.

get-token-uri() – Returns none (can be extended with metadata).

Property Management Functions

register-property(property-address, total-value, total-shares)
Registers a new property, mints tokens, and assigns shares to the property owner.

buy-property-shares(property-id, share-amount)
Allows an investor to purchase shares from the property owner.

sell-property-shares(property-id, share-amount, to)
Enables a share owner to sell shares to another investor.

Read-only Functions

get-property-info(property-id) – Returns metadata for a property.

get-property-shares(property-id, owner) – Returns the number of shares owned by a user.

get-property-count() – Returns the total number of properties registered.

🛑 Error Codes

u100 → Only the contract owner can perform this action.

u101 → Sender is not the token owner.

u102 → Insufficient balance.

u103 → Property not found.

u104 → Property already exists.

u105 → Invalid amount specified.

📌 Example Flow

Register a Property: Contract owner registers a new property worth 1,000,000 STX with 1,000 shares. Each share = 1,000 STX.

Minting Shares: Contract mints 1,000 PST tokens and assigns them to the property owner.

Buying Shares: An investor buys 100 PST from the property owner, gaining 10% ownership.

Selling Shares: The investor can later sell shares to another buyer.

🔮 Future Improvements

Integrate stablecoin payment for purchasing shares.

Add dividend distribution for rental income or property appreciation.

Enable secondary marketplace for property shares.

Support NFT property deeds linked to SIP-010 tokens.

📜 License

This contract is provided under the MIT License.