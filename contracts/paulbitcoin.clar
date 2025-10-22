;; PaulBitcoin SIP-010 FT implementation
(impl-trait .sip010-ft-trait.sip010-ft-trait)

;; Constants
(define-constant TOKEN-NAME "PaulBitcoin")
(define-constant TOKEN-SYMBOL "PBIT")
(define-constant TOKEN-DECIMALS u6)

;; Error codes
(define-constant ERR-UNAUTHORIZED u100)
(define-constant ERR-NOT-INITIALIZED u101)
(define-constant ERR-ALREADY-INITIALIZED u102)
(define-constant ERR-INSUFFICIENT-BALANCE u103)
(define-constant ERR-ZERO-AMOUNT u104)

;; State
(define-data-var total-supply uint u0)
(define-data-var owner (optional principal) none)
(define-map balances { account: principal } { balance: uint })

;; SIP-010 read-onlys
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-balance (who principal))
  (ok (match (map-get? balances { account: who })
        entry (get balance entry)
        u0))
)

(define-read-only (get-total-supply)
  (ok (some (var-get total-supply)))
)

(define-read-only (get-token-uri)
  (ok none)
)

;; Admin controls
(define-public (initialize (admin principal))
  (if (is-none (var-get owner))
      (begin
        (var-set owner (some admin))
        (ok true))
      (err ERR-ALREADY-INITIALIZED))
)

(define-public (set-owner (new-admin principal))
  (match (var-get owner) current
    (if (is-eq tx-sender current)
        (begin (var-set owner (some new-admin)) (ok true))
        (err ERR-UNAUTHORIZED))
    (err ERR-NOT-INITIALIZED))
)

;; Minting (owner-only)
(define-public (mint (amount uint) (recipient principal))
  (if (is-eq amount u0)
      (err ERR-ZERO-AMOUNT)
      (match (var-get owner) current
        (if (is-eq tx-sender current)
            (begin
              (var-set total-supply (+ (var-get total-supply) amount))
              (let ((rbal (match (map-get? balances { account: recipient }) r-entry (get balance r-entry) u0)))
                (map-set balances { account: recipient } { balance: (+ rbal amount) }))
              (ok true))
            (err ERR-UNAUTHORIZED))
        (err ERR-NOT-INITIALIZED)))
)

;; Transfers
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq amount u0)
      (err ERR-ZERO-AMOUNT)
      (if (not (is-eq tx-sender sender))
          (err ERR-UNAUTHORIZED)
          (match (map-get? balances { account: sender }) s-entry
            (let ((sbal (get balance s-entry)))
              (if (>= sbal amount)
                  (begin
                    ;; debit sender
                    (let ((new-sbal (- sbal amount)))
                      (if (is-eq new-sbal u0)
                          (map-delete balances { account: sender })
                          (map-set balances { account: sender } { balance: new-sbal })))
                    ;; credit recipient
                    (let ((rbal (match (map-get? balances { account: recipient }) r-entry (get balance r-entry) u0)))
                      (map-set balances { account: recipient } { balance: (+ rbal amount) }))
                    (ok true))
                  (err ERR-INSUFFICIENT-BALANCE)))
            (err ERR-INSUFFICIENT-BALANCE))))
)
