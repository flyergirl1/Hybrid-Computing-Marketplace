;; Hybrid Algorithm NFT Contract

(define-non-fungible-token hybrid-algorithm uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  uint
  {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    creator: principal,
    quantum-component: (string-utf8 1000),
    classical-component: (string-utf8 1000)
  }
)

(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (quantum-component (string-utf8 1000)) (classical-component (string-utf8 1000)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? hybrid-algorithm token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        name: name,
        description: description,
        creator: tx-sender,
        quantum-component: quantum-component,
        classical-component: classical-component
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (recipient principal))
  (nft-transfer? hybrid-algorithm token-id tx-sender recipient)
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

