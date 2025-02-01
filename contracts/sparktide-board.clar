;; NFT Implementation for Moodboards
(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token sparktide-board uint)

(define-data-var last-token-id uint u0)

(define-map board-data uint 
  {
    owner: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    collaborators: (list 10 principal),
    assets: (list 50 (string-utf8 200)),
    created-at: uint
  }
)

(define-public (create-board (title (string-utf8 100)) (description (string-utf8 500)))
  (let 
    (
      (token-id (+ (var-get last-token-id) u1))
      (board-owner tx-sender)
    )
    (try! (nft-mint? sparktide-board token-id board-owner))
    (map-set board-data token-id
      {
        owner: board-owner,
        title: title,
        description: description,
        collaborators: (list),
        assets: (list),
        created-at: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (add-collaborator (board-id uint) (collaborator principal))
  (let
    ((board (unwrap! (map-get? board-data board-id) ERR_BOARD_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner board)) ERR_NOT_AUTHORIZED)
    (ok (map-set board-data board-id
      (merge board { collaborators: (append (get collaborators board) collaborator) })))
  )
)
