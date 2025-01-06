;; Hybrid Task Management Contract

(define-data-var task-count uint u0)

(define-map tasks
  uint
  {
    owner: principal,
    description: (string-utf8 1000),
    quantum-resources: uint,
    classical-resources: uint,
    status: (string-ascii 20),
    result: (optional (string-utf8 1000))
  }
)

(define-public (create-task (description (string-utf8 1000)) (quantum-resources uint) (classical-resources uint))
  (let
    (
      (task-id (+ (var-get task-count) u1))
    )
    (map-set tasks
      task-id
      {
        owner: tx-sender,
        description: description,
        quantum-resources: quantum-resources,
        classical-resources: classical-resources,
        status: "pending",
        result: none
      }
    )
    (var-set task-count task-id)
    (ok task-id)
  )
)

(define-public (update-task-status (task-id uint) (new-status (string-ascii 20)))
  (let
    (
      (task (unwrap! (map-get? tasks task-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner task)) (err u403))
    (ok (map-set tasks
      task-id
      (merge task { status: new-status })
    ))
  )
)

(define-public (set-task-result (task-id uint) (result (string-utf8 1000)))
  (let
    (
      (task (unwrap! (map-get? tasks task-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner task)) (err u403))
    (ok (map-set tasks
      task-id
      (merge task { result: (some result), status: "completed" })
    ))
  )
)

(define-read-only (get-task (task-id uint))
  (map-get? tasks task-id)
)

(define-read-only (get-task-count)
  (var-get task-count)
)

