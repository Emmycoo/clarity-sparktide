;; Core platform functionality
(define-map user-stats principal
  {
    boards-created: uint,
    contributions: uint,
    reputation: uint
  }
)

(define-map board-likes uint (list 1000 principal))
(define-map board-bookmarks uint (list 1000 principal))

(define-public (like-board (board-id uint))
  (let
    ((current-likes (default-to (list) (map-get? board-likes board-id))))
    (ok (map-set board-likes board-id
      (append current-likes tx-sender)))
  )
)

(define-public (bookmark-board (board-id uint))
  (let
    ((current-bookmarks (default-to (list) (map-get? board-bookmarks board-id))))
    (ok (map-set board-bookmarks board-id
      (append current-bookmarks tx-sender)))
  )
)
