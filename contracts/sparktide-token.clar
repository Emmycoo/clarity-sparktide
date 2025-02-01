;; Platform token for rewards
(define-fungible-token spark-token)

(define-constant contract-owner tx-sender)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR_NOT_AUTHORIZED)
    (ft-mint? spark-token amount recipient)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? spark-token amount tx-sender recipient)
)
