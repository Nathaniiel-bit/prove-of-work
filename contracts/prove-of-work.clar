;; --------------------------------------------
;; Proof of Community Work Protocol (PoCW)
;; Contract: proof-of-work.clar
;; --------------------------------------------

;; -----------------------------
;; CONSTANTS & VARIABLES
;; -----------------------------

(define-data-var admin principal tx-sender)
(define-data-var next-id uint u1)
(define-data-var total-points uint u0)
(define-data-var reward-pool uint u0)

;; -----------------------------
;; DATA STRUCTURES
;; -----------------------------

;; Registered contributors
(define-map contributors principal {
  username: (string-ascii 40),
  points: uint
})

;; Work logs (logged by admin for contributors)
(define-map work-logs uint {
  contributor: principal,
  description: (string-ascii 100),
  hours: uint,
  timestamp: uint,
  verified-by: principal
})

;; -----------------------------
;; 1. Register as Contributor
;; -----------------------------
(define-public (register-contributor (username (string-ascii 40)))
  (begin
    (asserts! (not (is-some (map-get? contributors tx-sender))) (err u100))
    (map-set contributors tx-sender {
      username: username,
      points: u0
    })
    (ok true)))

;; -----------------------------
;; 2. Log Verified Contribution (Admin Only)
;; -----------------------------
(define-public (log-contribution (contributor principal) (desc (string-ascii 100)) (hours uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u200))
    (asserts! (is-some (map-get? contributors contributor)) (err u201))
    (var-set next-id (+ (var-get next-id) u1))
    (map-set work-logs (var-get next-id) {
      contributor: contributor,
      description: desc,
      hours: hours,
      timestamp: stacks-block-height,
      verified-by: tx-sender
    })
    ;; Add points: 10 points per hour
    (let ((earned (* hours u10)))
      (let ((old (default-to u0 (get points (map-get? contributors contributor)))))
        (map-set contributors contributor {
          username: (get username (unwrap! (map-get? contributors contributor) (err u202))),
          points: (+ old earned)
        })
        (var-set total-points (+ (var-get total-points) earned))
        (ok true)))))

;; -----------------------------
;; 3. Contribute to Reward Pool
;; -----------------------------
(define-public (donate (amount uint))
  (begin
    (asserts! (> amount u0) (err u300))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok amount)))

;; -----------------------------
;; 4. Claim Reward Based on Points
;; -----------------------------
(define-public (claim-reward)
  (let (
    (user (map-get? contributors tx-sender))
    (pool (var-get reward-pool))
    (total (var-get total-points))
  )
    (match user
      user-data (let ((my-points (get points user-data)))
          (asserts! (> my-points u0) (err u301))
          (asserts! (> total u0) (err u303))
          (asserts! (> pool u0) (err u304))
          (let ((reward (/ (* my-points pool) total)))
            (try! (stx-transfer? reward (as-contract tx-sender) tx-sender))
            (var-set reward-pool (- pool reward))
            (map-set contributors tx-sender {
              username: (get username user-data),
              points: u0
            })
            (ok reward)))
      (err u302))))

;; -----------------------------
;; 5. Admin: Reset Contributors (Optional)
;; -----------------------------
(define-public (reset-round)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u400))
    (var-set total-points u0)
    ;; (optional: reset contributor points or prepare new round conditions)
    (ok true)))