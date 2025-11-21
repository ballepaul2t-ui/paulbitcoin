;; PaulBitcoin SIP-010 fungible token implementation

(define-trait sip010-ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response (optional uint) uint))
    (get-name () (response (optional (string-ascii 32)) uint))
    (get-symbol () (response (optional (string-ascii 8)) uint))
    (get-decimals () (response (optional uint) uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_NOT_INITIALIZED u101)
(define-constant ERR_ALREADY_INITIALIZED u102)
(define-constant ERR_INSUFFICIENT_BALANCE u103)
(define-constant ERR_ZERO_AMOUNT u104)

(define-data-var token-owner (optional principal) none)
(define-data-var total-supply uint u0)

(define-fungible-token paulbitcoin)

(define-read-only (get-owner)
  (var-get token-owner)
)

(define-private (ensure-initialized)
  (match (var-get token-owner)
    some-owner (ok some-owner)
    (err ERR_NOT_INITIALIZED)
  )
)

(define-private (is-owner (who principal))
  (match (var-get token-owner)
    some-owner (is-eq some-owner who)
    false
  )
)

;; One-time initializer to set the admin/owner of the token
(define-public (initialize (owner principal))
  (match (var-get token-owner)
    some-owner (err ERR_ALREADY_INITIALIZED)
    (begin
      (var-set token-owner (some owner))
      (ok true)
    )
  )
)

;; Allow the current owner to transfer ownership to a new principal
(define-public (set-owner (new-owner principal))
  (begin
    (try! (ensure-initialized))
    (if (is-owner tx-sender)
        (begin
          (var-set token-owner (some new-owner))
          (ok true))
        (err ERR_UNAUTHORIZED))
  )
)

;; Owner-only mint function
(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (ensure-initialized))
    (if (<= amount u0)
        (err ERR_ZERO_AMOUNT)
        (if (is-owner tx-sender)
            (begin
              (var-set total-supply (+ (var-get total-supply) amount))
              (match (ft-mint? paulbitcoin amount recipient)
                minted (ok minted)
                ft-err (err ft-err)))
            (err ERR_UNAUTHORIZED)))
  )
)

;; SIP-010 transfer implementation
(define-public (transfer (amount uint)
                         (sender principal)
                         (recipient principal)
                         (memo (optional (buff 34))))
  (begin
    (try! (ensure-initialized))
    (if (<= amount u0)
        (err ERR_ZERO_AMOUNT)
        (if (is-eq tx-sender sender)
            (match (ft-transfer? paulbitcoin amount sender recipient)
              transferred (ok transferred)
              ft-err (err ERR_INSUFFICIENT_BALANCE))
            (err ERR_UNAUTHORIZED)))
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance paulbitcoin owner))
)

(define-read-only (get-total-supply)
  (ok (some (var-get total-supply)))
)

(define-read-only (get-name)
  (ok (some "PaulBitcoin"))
)

(define-read-only (get-symbol)
  (ok (some "PBIT"))
)

(define-read-only (get-decimals)
  (ok (some u6))
)

(define-read-only (get-token-uri)
  (ok none)
)
