# PaulBitcoin — SIP-010 fungible token

A simple SIP-010 fungible token implemented in Clarity using Clarinet.

## Prerequisites
- Clarinet installed (verify with `clarinet --version`).

## Project layout
- `Clarinet.toml` — project manifest
- `contracts/paulbitcoin.clar` — PaulBitcoin SIP-010 token + embedded SIP-010 trait
- `settings/` — Clarinet chain configuration (Devnet/Testnet/Mainnet)
- `tests/` — space for Vitest + Clarinet integration tests

## Contract overview

The `paulbitcoin` contract implements the SIP-010 fungible token trait with:

- Name: `PaulBitcoin`
- Symbol: `PBIT`
- Decimals: `6` (1 PBIT = 1_000_000 base units)
- Errors:
  - `u100` — unauthorized (caller is not the token owner or sender mismatch)
  - `u101` — not initialized (token owner not set)
  - `u102` — already initialized
  - `u103` — insufficient balance
  - `u104` — zero amount (amount must be greater than zero)

### Key functions

- `initialize (owner principal)` — one-time initializer that sets the token owner/admin.
- `set-owner (new-owner principal)` — allows the current owner to transfer ownership.
- `mint (amount uint, recipient principal)` — owner-only mint; increases total supply and mints to `recipient`.
- `transfer (amount uint, sender principal, recipient principal, memo (optional (buff 34)))` — SIP-010 transfer; the `sender` **must** be the `tx-sender`.
- `get-balance (owner principal)` — returns the balance of `owner`.
- `get-total-supply ()` — returns the current total supply (wrapped in `some`).
- `get-name ()`, `get-symbol ()`, `get-decimals ()`, `get-token-uri ()` — standard SIP-010 metadata getters.

## Quick start

From the project root:

- Syntax check:
  - `clarinet check`
- REPL (console):
  - `clarinet console`

### Initialize owner (one-time)
In the console, set the token admin (who can mint and change owner):

```clarity path=null start=null
(contract-call? .paulbitcoin initialize tx-sender)
```

You can pass any principal you want as admin.

### Mint tokens (owner only)

```clarity path=null start=null
(contract-call? .paulbitcoin mint u100000 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
```

### Transfer tokens

Sender must be the transaction sender (the `sender` argument must equal `tx-sender`).

```clarity path=null start=null
(contract-call? .paulbitcoin transfer u500 'ST3J2... 'ST2C2... none)
```

### Read balances and supply

```clarity path=null start=null
(contract-call? .paulbitcoin get-balance 'ST3J2...)
(contract-call? .paulbitcoin get-total-supply)
```

## Development

- Run `clarinet repl` or `clarinet console` to experiment with the contract locally.
- Add Vitest tests under `tests/` using the Clarinet TypeScript testing harness if desired.

## Notes
- Decimals: 6 (PBIT smallest unit is micro-PBIT).
- `get-token-uri` returns `none` by default; extend as needed.
- Error codes: unauthorized (`u100`), not-initialized (`u101`), already-initialized (`u102`), insufficient-balance (`u103`), zero-amount (`u104`).
