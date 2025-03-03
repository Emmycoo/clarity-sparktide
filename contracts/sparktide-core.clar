;; Core platform functionality

;; Constants
(define-constant ERR_ALREADY_LIKED (err u201))
(define-constant ERR_ALREADY_BOOKMARKED (err u202))
(define-constant ERR_NOT_FOUND (err u203))

;; Events
(define-data-var event-counter uint u0)

(define-map user-stats principal
  {
    boards-created: uint,
    contributions: uint,
    reputation: uint,
    last-action: uint
  }
)

(define-map board-likes uint (list 1000 principal))
(define-map board-bookmarks uint (list 1000 principal))

;; Helper functions
(define-private (contains-principal? (principals (list 1000 principal)) (user principal))
  (is-some (index-of? principals user))
)

(define-private (emit-event (event-type (string-utf8 50)) (data (string-utf8 256)))
  (let ((event-id (+ (var-get event-counter) u1)))
    (var-set event-counter event-id)
    (print { event-id: event-id, type: event-type, data: data })
  )
)

(define-public (like-board (board-id uint))
  (let
    (
      (current-likes (default-to (list) (map-get? board-likes board-id)))
    )
    (asserts! (not (contains-principal? current-likes tx-sender)) ERR_ALREADY_LIKED)
    (map-set board-likes board-id (append current-likes tx-sender))
    (emit-event "board-liked" (concat (uint-to-ascii board-id) "-liked"))
    (ok true)
  )
)

(define-public (unlike-board (board-id uint))
  (let
    (
      (current-likes (default-to (list) (map-get? board-likes board-id)))
    )
    (asserts! (contains-principal? current-likes tx-sender) ERR_NOT_FOUND)
    (map-set board-likes board-id 
      (filter not-eq-principal current-likes))
    (emit-event "board-unliked" (concat (uint-to-ascii board-id) "-unliked"))
    (ok true)
  )
)

(define-private (not-eq-principal (p principal))
  (not (is-eq p tx-sender))
)

(define-public (bookmark-board (board-id uint))
  (let
    (
      (current-bookmarks (default-to (list) (map-get? board-bookmarks board-id)))
    )
    (asserts! (not (contains-principal? current-bookmarks tx-sender)) ERR_ALREADY_BOOKMARKED)
    (map-set board-bookmarks board-id (append current-bookmarks tx-sender))
    (emit-event "board-bookmarked" (concat (uint-to-ascii board-id) "-bookmarked"))
    (ok true)
  )
)

(define-public (unbookmark-board (board-id uint))
  (let
    (
      (current-bookmarks (default-to (list) (map-get? board-bookmarks board-id)))
    )
    (asserts! (contains-principal? current-bookmarks tx-sender) ERR_NOT_FOUND)
    (map-set board-bookmarks board-id 
      (filter not-eq-principal current-bookmarks))
    (emit-event "board-unbookmarked" (concat (uint-to-ascii board-id) "-unbookmarked"))
    (ok true)
  )
)
