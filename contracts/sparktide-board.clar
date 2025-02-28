;; NFT Implementation for Moodboards
(impl-trait .nft-trait.nft-trait)

;; Constants for error handling
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_BOARD_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_LIST_FULL (err u103))

(define-non-fungible-token sparktide-board uint)

(define-data-var last-token-id uint u0)

;; Board creation and modification events
(define-map board-data uint 
  {
    owner: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    collaborators: (list 10 principal),
    assets: (list 50 (string-utf8 200)),
    created-at: uint,
    updated-at: uint
  }
)

(define-public (create-board (title (string-utf8 100)) (description (string-utf8 500)))
  (let 
    (
      (token-id (+ (var-get last-token-id) u1))
      (board-owner tx-sender)
    )
    (asserts! (> (len title) u0) ERR_INVALID_INPUT)
    (try! (nft-mint? sparktide-board token-id board-owner))
    (map-set board-data token-id
      {
        owner: board-owner,
        title: title,
        description: description,
        collaborators: (list),
        assets: (list),
        created-at: block-height,
        updated-at: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (update-board (board-id uint) (title (string-utf8 100)) (description (string-utf8 500)))
  (let
    ((board (unwrap! (map-get? board-data board-id) ERR_BOARD_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get owner board)) 
                 (is-some (index-of? (get collaborators board) tx-sender))) 
             ERR_NOT_AUTHORIZED)
    (ok (map-set board-data board-id
      (merge board 
        { 
          title: title,
          description: description,
          updated-at: block-height
        }
      )))
  )
)

(define-public (add-collaborator (board-id uint) (collaborator principal))
  (let
    ((board (unwrap! (map-get? board-data board-id) ERR_BOARD_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner board)) ERR_NOT_AUTHORIZED)
    (asserts! (< (len (get collaborators board)) u10) ERR_LIST_FULL)
    (ok (map-set board-data board-id
      (merge board { collaborators: (append (get collaborators board) collaborator) })))
  )
)

(define-public (remove-collaborator (board-id uint) (collaborator principal))
  (let
    ((board (unwrap! (map-get? board-data board-id) ERR_BOARD_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner board)) ERR_NOT_AUTHORIZED)
    (ok (map-set board-data board-id
      (merge board { 
        collaborators: (filter not-eq-collaborator (get collaborators board))
      })))
  )
)

(define-private (not-eq-collaborator (collab principal))
  (not (is-eq collab tx-sender)))
