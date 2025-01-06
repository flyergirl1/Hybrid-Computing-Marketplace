;; Resource Allocation Contract

(define-map resource-providers
  principal
  {
    quantum-capacity: uint,
    classical-capacity: uint,
    reputation: uint,
    total-tasks-completed: uint
  }
)

(define-map allocated-resources
  uint  ;; task-id
  {
    provider: principal,
    quantum-allocated: uint,
    classical-allocated: uint
  }
)

(define-public (register-provider (quantum-capacity uint) (classical-capacity uint))
  (ok (map-set resource-providers
    tx-sender
    {
      quantum-capacity: quantum-capacity,
      classical-capacity: classical-capacity,
      reputation: u0,
      total-tasks-completed: u0
    }
  ))
)

(define-public (allocate-resources (task-id uint) (quantum-needed uint) (classical-needed uint))
  (let
    (
      (provider-data (unwrap! (map-get? resource-providers tx-sender) (err u404)))
    )
    (asserts! (>= (get quantum-capacity provider-data) quantum-needed) (err u401))
    (asserts! (>= (get classical-capacity provider-data) classical-needed) (err u402))
    (map-set allocated-resources
      task-id
      {
        provider: tx-sender,
        quantum-allocated: quantum-needed,
        classical-allocated: classical-needed
      }
    )
    (ok true)
  )
)

(define-public (complete-task (task-id uint))
  (let
    (
      (allocation (unwrap! (map-get? allocated-resources task-id) (err u404)))
      (provider-data (unwrap! (map-get? resource-providers (get provider allocation)) (err u405)))
    )
    (map-set resource-providers
      (get provider allocation)
      (merge provider-data
        {
          reputation: (+ (get reputation provider-data) u1),
          total-tasks-completed: (+ (get total-tasks-completed provider-data) u1)
        }
      )
    )
    (ok true)
  )
)

(define-read-only (get-provider-data (provider principal))
  (map-get? resource-providers provider)
)

(define-read-only (get-task-allocation (task-id uint))
  (map-get? allocated-resources task-id)
)

