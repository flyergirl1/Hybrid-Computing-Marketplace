;; Compute Time Marketplace Contract

(define-fungible-token compute-time-token)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))

(define-map listings
  uint
  {
    seller: principal,
    quantum-time: uint,
    classical-time: uint,
    price: uint,
    active: bool
  }
)

(define-data-var listing-count uint u0)

(define-public (create-listing (quantum-time uint) (classical-time uint) (price uint))
  (let
    (
      (listing-id (+ (var-get listing-count) u1))
    )
    (map-set listings
      listing-id
      {
        seller: tx-sender,
        quantum-time: quantum-time,
        classical-time: classical-time,
        price: price,
        active: true
      }
    )
    (var-set listing-count listing-id)
    (ok listing-id)
  )
)

(define-public (buy-compute-time (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) (err u404)))
    )
    (asserts! (get active listing) (err u405))
    (try! (ft-transfer? compute-time-token (get price listing) tx-sender (get seller listing)))
    (map-set listings
      listing-id
      (merge listing { active: false })
    )
    (ok true)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get seller listing)) (err u403))
    (ok (map-set listings
      listing-id
      (merge listing { active: false })
    ))
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id)
)

(define-read-only (get-listing-count)
  (var-get listing-count)
)

