# PaulBitcoin — Clarity SIP-010 FT

A simple SIP-010 fungible token implemented in Clarity using Clarinet.

## Prerequisites
- Clarinet installed (verify with `clarinet --version`).

## Project layout
- `Clarinet.toml` — project manifest
- `contracts/traits/sip010-ft-trait.clar` — SIP-010 trait
- `contracts/paulbitcoin.clar` — PaulBitcoin token

## Quick start
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
Sender must be the transaction sender.
```clarity path=null start=null
(contract-call? .paulbitcoin transfer u500 'ST3J2... 'ST2C2... none)
```

### Read balances and supply
```clarity path=null start=null
(contract-call? .paulbitcoin get-balance 'ST3J2...)
(contract-call? .paulbitcoin get-total-supply)
```

## Notes
- Decimals: 6 (PBIT smallest unit is micro-PBIT).
- `get-token-uri` returns none by default; extend as needed.
- Error codes: unauthorized (u100), not-initialized (u101), already-initialized (u102), insufficient-balance (u103), zero-amount (u104).
