;; TradeChain - Tokenized Trade Agreements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-agreement (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-wrong-status (err u103))

;; Data Variables
(define-data-var next-agreement-id uint u1)

;; Agreement Status
(define-constant status-pending u0)
(define-constant status-accepted u1) 
(define-constant status-completed u2)
(define-constant status-disputed u3)

;; Agreement Data Structure
(define-map agreements
  { agreement-id: uint }
  {
    creator: principal,
    counterparty: principal,
    amount: uint,
    terms: (string-ascii 256),
    status: uint,
    collateral: uint
  }
)

;; Create new agreement
(define-public (create-agreement (counterparty principal) (amount uint) (terms (string-ascii 256)))
  (let 
    (
      (agreement-id (var-get next-agreement-id))
    )
    (map-set agreements
      { agreement-id: agreement-id }
      {
        creator: tx-sender,
        counterparty: counterparty,
        amount: amount,
        terms: terms,
        status: status-pending,
        collateral: u0
      }
    )
    (var-set next-agreement-id (+ agreement-id u1))
    (ok agreement-id)
  )
)

;; Accept agreement and lock collateral
(define-public (accept-agreement (agreement-id uint))
  (let
    (
      (agreement (unwrap! (map-get? agreements {agreement-id: agreement-id}) (err err-invalid-agreement)))
    )
    (asserts! (is-eq (get counterparty agreement) tx-sender) (err err-unauthorized))
    (asserts! (is-eq (get status agreement) status-pending) (err err-wrong-status))
    (try! (stx-transfer? (get amount agreement) tx-sender (as-contract tx-sender)))
    (map-set agreements
      {agreement-id: agreement-id}
      (merge agreement {status: status-accepted, collateral: (get amount agreement)})
    )
    (ok true)
  )
)

;; Complete agreement
(define-public (complete-agreement (agreement-id uint))
  (let
    (
      (agreement (unwrap! (map-get? agreements {agreement-id: agreement-id}) (err err-invalid-agreement)))
    )
    (asserts! (is-eq (get status agreement) status-accepted) (err err-wrong-status))
    (asserts! (or
      (is-eq tx-sender (get creator agreement))
      (is-eq tx-sender (get counterparty agreement))
    ) (err err-unauthorized))
    
    ;; Release collateral
    (try! (as-contract (stx-transfer? (get collateral agreement) tx-sender (get counterparty agreement))))
    
    (map-set agreements
      {agreement-id: agreement-id}
      (merge agreement {status: status-completed})
    )
    (ok true)
  )
)

;; Get agreement details
(define-read-only (get-agreement-details (agreement-id uint))
  (ok (unwrap! (map-get? agreements {agreement-id: agreement-id}) (err err-invalid-agreement)))
)
