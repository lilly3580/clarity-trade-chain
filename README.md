# TradeChain
A platform for tokenized trade agreements on the Stacks blockchain.

## Features
- Create new trade agreements between two parties
- Token-based representation of trade agreements
- Agreement lifecycle management (create, accept, complete, dispute)
- Collateral locking mechanism for trade security
- Agreement terms and conditions storage
- View agreement status and details

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite 

## Usage Examples
```clarity
;; Create new trade agreement
(contract-call? .trade-chain create-agreement 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  u1000 
  "Trade 100 widgets for 1000 STX"
)

;; Accept agreement
(contract-call? .trade-chain accept-agreement u1)

;; Complete agreement
(contract-call? .trade-chain complete-agreement u1)

;; Get agreement details
(contract-call? .trade-chain get-agreement-details u1)
```

## Dependencies
- Clarity language 
- Clarinet for testing and deployment
