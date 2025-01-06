;; Task Distribution System Contract

(define-map task-distributions
  uint  ;; task-id
  {
    quantum-providers: (list 10 principal),
    classical-providers: (list 10 principal),
    distribution-status: (string-ascii 20)
  }
)

(define-public (distribute-task (task-id uint) (quantum-providers (list 10 principal)) (classical-providers (list 10 principal)))
  (let
    (
      (task (unwrap! (contract-call? .hybrid-task-management get-task task-id) (err u404)))
    )
    (asserts! (is-eq (get status task) "pending") (err u405))
    (map-set task-distributions
      task-id
      {
        quantum-providers: quantum-providers,
        classical-providers: classical-providers,
        distribution-status: "distributed"
      }
    )
    (try! (contract-call? .hybrid-task-management update-task-status task-id "in-progress"))
    (ok true)
  )
)

(define-public (update-distribution-status (task-id uint) (new-status (string-ascii 20)))
  (let
    (
      (distribution (unwrap! (map-get? task-distributions task-id) (err u404)))
    )
    (ok (map-set task-distributions
      task-id
      (merge distribution { distribution-status: new-status })
    ))
  )
)

(define-read-only (get-task-distribution (task-id uint))
  (map-get? task-distributions task-id)
)

