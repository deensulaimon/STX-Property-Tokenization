;; Property Tokenization Smart Contract
;; Enables fractional ownership of real estate via SIP-010 tokens

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-property-not-found (err u103))
(define-constant err-property-already-exists (err u104))
(define-constant err-invalid-amount (err u105))

;; Token name and symbol
(define-constant token-name "Property Share Token")
(define-constant token-symbol "PST")
(define-constant token-decimals u6)

;; Data Variables
(define-data-var total-supply uint u0)
(define-data-var property-counter uint u0)

;; Data Maps
(define-map token-balances principal uint)
(define-map token-supplies principal uint)
(define-map allowances {owner: principal, spender: principal} uint)

;; Property data structure
(define-map properties
  uint 
  {
    owner: principal,
    property-address: (string-ascii 100),
    total-value: uint,
    total-shares: uint,
    price-per-share: uint,
    is-active: bool
  }
)

;; Property share ownership
(define-map property-shares
  {property-id: uint, owner: principal}
  uint
)

;; SIP-010 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq from tx-sender) (is-eq from contract-caller)) err-not-token-owner)
    (asserts! (>= (get-balance from) amount) err-insufficient-balance)
    (try! (ft-transfer? pst-token amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (who principal))
  (default-to u0 (map-get? token-balances who))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-token-uri)
  (ok none)
)

;; Define fungible token
(define-fungible-token pst-token)

;; Property Management Functions
(define-public (register-property 
  (property-address (string-ascii 100)) 
  (total-value uint) 
  (total-shares uint))
  (let 
    (
      (property-id (+ (var-get property-counter) u1))
      (price-per-share (/ total-value total-shares))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> total-value u0) err-invalid-amount)
    (asserts! (> total-shares u0) err-invalid-amount)

    (map-set properties property-id {
      owner: tx-sender,
      property-address: property-address,
      total-value: total-value,
      total-shares: total-shares,
      price-per-share: price-per-share,
      is-active: true
    })

    (var-set property-counter property-id)

    ;; Mint tokens for the property
    (try! (ft-mint? pst-token total-shares tx-sender))
    (var-set total-supply (+ (var-get total-supply) total-shares))
    (map-set token-balances tx-sender (+ (get-balance tx-sender) total-shares))

    (ok property-id)
  )
)

(define-public (buy-property-shares (property-id uint) (share-amount uint))
  (let 
    (
      (property-data (unwrap! (map-get? properties property-id) err-property-not-found))
      (price-per-share (get price-per-share property-data))
      (total-cost (* share-amount price-per-share))
      (property-owner (get owner property-data))
      (current-shares (default-to u0 (map-get? property-shares {property-id: property-id, owner: tx-sender})))
    )
    (asserts! (get is-active property-data) err-property-not-found)
    (asserts! (> share-amount u0) err-invalid-amount)
    (asserts! (>= (get-balance property-owner) share-amount) err-insufficient-balance)

    ;; Transfer tokens from property owner to buyer
    (try! (ft-transfer? pst-token share-amount property-owner tx-sender))
    (map-set token-balances property-owner (- (get-balance property-owner) share-amount))
    (map-set token-balances tx-sender (+ (get-balance tx-sender) share-amount))

    ;; Update property share ownership
    (map-set property-shares 
      {property-id: property-id, owner: tx-sender}
      (+ current-shares share-amount)
    )

    (ok true)
  )
)

(define-public (sell-property-shares (property-id uint) (share-amount uint) (to principal))
  (let 
    (
      (property-data (unwrap! (map-get? properties property-id) err-property-not-found))
      (current-shares (default-to u0 (map-get? property-shares {property-id: property-id, owner: tx-sender})))
      (buyer-shares (default-to u0 (map-get? property-shares {property-id: property-id, owner: to})))
    )
    (asserts! (get is-active property-data) err-property-not-found)
    (asserts! (> share-amount u0) err-invalid-amount)
    (asserts! (>= current-shares share-amount) err-insufficient-balance)
    (asserts! (>= (get-balance tx-sender) share-amount) err-insufficient-balance)

    ;; Transfer tokens
    (try! (ft-transfer? pst-token share-amount tx-sender to))
    (map-set token-balances tx-sender (- (get-balance tx-sender) share-amount))
    (map-set token-balances to (+ (get-balance to) share-amount))

    ;; Update share ownership
    (map-set property-shares 
      {property-id: property-id, owner: tx-sender}
      (- current-shares share-amount)
    )
    (map-set property-shares 
      {property-id: property-id, owner: to}
      (+ buyer-shares share-amount)
    )

    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-property-info (property-id uint))
  (map-get? properties property-id)
)

(define-read-only (get-property-shares (property-id uint) (owner principal))
  (default-to u0 (map-get? property-shares {property-id: property-id, owner: owner}))
)

(define-read-only (get-property-count)
  (var-get property-counter)
)

;; Initialize contract
(begin
  (map-set token-balances contract-owner u0)
)