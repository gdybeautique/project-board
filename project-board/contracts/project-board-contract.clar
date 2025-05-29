;; Project Board Smart Contract - Agile/Scrum Theme
;; Create stories, move to done, earn sprint trophies

;; Constants
(define-constant scrum-master tx-sender)
(define-constant err-not-scrum-master (err u100))
(define-constant err-story-not-found (err u101))
(define-constant err-story-already-done (err u102))
(define-constant err-not-team-member (err u103))
(define-constant err-invalid-story (err u104))

;; Data Variables
(define-data-var story-point-counter uint u0)
(define-data-var sprint-trophy-counter uint u0)

;; Data Maps
;; Store user story details
(define-map user-stories 
    { story-id: uint, team-member: principal }
    { 
        story-title: (string-utf8 256),
        acceptance-criteria: (string-utf8 1024),
        done: bool,
        created-in-sprint: uint,
        done-in-sprint: (optional uint)
    }
)

;; Track team member velocity
(define-map team-velocity
    principal
    {
        total-stories: uint,
        completed-stories: uint,
        backlog-stories: uint
    }
)

;; NFT Sprint Trophies
(define-non-fungible-token sprint-trophy uint)

;; Map to track sprint achievements
(define-map sprint-achievements
    { team-member: principal, trophy-type: (string-ascii 50) }
    { awarded: bool, awarded-sprint: uint }
)

;; Helper Functions
(define-private (assign-story-points)
    (let ((current-points (var-get story-point-counter)))
        (var-set story-point-counter (+ current-points u1))
        current-points
    )
)

(define-private (assign-trophy-id)
    (let ((current-trophies (var-get sprint-trophy-counter)))
        (var-set sprint-trophy-counter (+ current-trophies u1))
        current-trophies
    )
)

;; Read-only Functions
(define-read-only (view-story (story-id uint) (team-member principal))
    (map-get? user-stories { story-id: story-id, team-member: team-member })
)

(define-read-only (get-velocity (team-member principal))
    (default-to 
        { total-stories: u0, completed-stories: u0, backlog-stories: u0 }
        (map-get? team-velocity team-member)
    )
)

(define-read-only (has-sprint-trophy (team-member principal) (trophy-type (string-ascii 50)))
    (default-to 
        { awarded: false, awarded-sprint: u0 }
        (map-get? sprint-achievements { team-member: team-member, trophy-type: trophy-type })
    )
)

;; Private Functions
(define-private (update-velocity-metrics (team-member principal) (is-create bool) (is-complete bool))
    (let ((current-velocity (get-velocity team-member)))
        (if is-create
            ;; Creating a new story
            (map-set team-velocity team-member {
                total-stories: (+ (get total-stories current-velocity) u1),
                completed-stories: (get completed-stories current-velocity),
                backlog-stories: (+ (get backlog-stories current-velocity) u1)
            })
        
            (if is-complete
                ;; Moving story to done
                (map-set team-velocity team-member {
                    total-stories: (get total-stories current-velocity),
                    completed-stories: (+ (get completed-stories current-velocity) u1),
                    backlog-stories: (- (get backlog-stories current-velocity) u1)
                })
                ;; Removing from backlog
                (map-set team-velocity team-member {
                    total-stories: (get total-stories current-velocity),
                    completed-stories: (get completed-stories current-velocity),
                    backlog-stories: (- (get backlog-stories current-velocity) u1)
                })
            )
        )
    )
)

(define-private (check-sprint-milestones (team-member principal))
    (let (
        (velocity (get-velocity team-member))
        (completed (get completed-stories velocity))
    )
        ;; Check sprint achievements
        (begin
            ;; Sprint rookie trophy
            (and (is-eq completed u1) 
                 (not (get awarded (has-sprint-trophy team-member "sprint-rookie")))
                 (is-ok (grant-sprint-trophy team-member "sprint-rookie")))
            ;; Sprint veteran trophy for 10 stories
            (and (>= completed u10) 
                 (not (get awarded (has-sprint-trophy team-member "sprint-veteran")))
                 (is-ok (grant-sprint-trophy team-member "sprint-veteran")))
            ;; Sprint hero trophy for 50 stories
            (and (>= completed u50) 
                 (not (get awarded (has-sprint-trophy team-member "sprint-hero")))
                 (is-ok (grant-sprint-trophy team-member "sprint-hero")))
            ;; Sprint legend trophy for 100 stories
            (and (>= completed u100) 
                 (not (get awarded (has-sprint-trophy team-member "sprint-legend")))
                 (is-ok (grant-sprint-trophy team-member "sprint-legend")))
            true
        )
    )
)

(define-private (grant-sprint-trophy (team-member principal) (trophy-type (string-ascii 50)))
    (let ((trophy-id (assign-trophy-id)))
        (map-set sprint-achievements 
            { team-member: team-member, trophy-type: trophy-type }
            { awarded: true, awarded-sprint: block-height }
        )
        (nft-mint? sprint-trophy trophy-id team-member)
    )
)

;; Public Functions
(define-public (create-story (story-title (string-utf8 256)) (acceptance-criteria (string-utf8 1024)))
    (let (
        (story-id (assign-story-points))
        (team-member tx-sender)
    )
        (if (or (is-eq (len story-title) u0) (> (len story-title) u256) (> (len acceptance-criteria) u1024))
            err-invalid-story
            (begin
                (map-set user-stories 
                    { story-id: story-id, team-member: team-member }
                    {
                        story-title: story-title,
                        acceptance-criteria: acceptance-criteria,
                        done: false,
                        created-in-sprint: block-height,
                        done-in-sprint: none
                    }
                )
                (update-velocity-metrics team-member true false)
        
                (ok story-id)
            )
        )
    )
)

(define-public (move-to-done (story-id uint))
    (let (
        (story-key { story-id: story-id, team-member: tx-sender })
        (story (map-get? user-stories story-key))
    )
        (match story
            story-data
            (if (get done story-data)
                err-story-already-done
                (begin
                    (map-set user-stories story-key
                        (merge story-data {
                            done: true,
                            done-in-sprint: (some block-height)
                        })
                    )
                    (update-velocity-metrics tx-sender false true)
                    (check-sprint-milestones tx-sender)
                    (ok true)
                )
            )
            err-story-not-found
        )
    )
)

(define-public (remove-from-backlog (story-id uint))
    (let (
        (story-key { story-id: story-id, team-member: tx-sender })
        (story (map-get? user-stories story-key))
    )
        (match story
            story-data
            (begin
        
                (map-delete user-stories story-key)
                (if (not (get done story-data))
                    (update-velocity-metrics tx-sender false false)
        
        
        
                    true
                )
                (ok true)
            )
        
        
            err-story-not-found
        )
    )
)



;; Refine story details
(define-public (refine-story (story-id uint) (story-title (string-utf8 256)) (acceptance-criteria (string-utf8 1024)))
    (let (
        (story-key { story-id: story-id, team-member: tx-sender })
        (story (map-get? user-stories story-key))
    )
        (match story
            story-data
            (if (get done story-data)
                err-story-already-done
                (if (or (is-eq (len story-title) u0) (> (len story-title) u256) (> (len acceptance-criteria) u1024))
                    err-invalid-story
                    (begin
                        (map-set user-stories story-key
                            (merge story-data {
                                story-title: story-title,
                                acceptance-criteria: acceptance-criteria
                            })
                        )
                        (ok true)
                    )
                )
            )
            err-story-not-found
        )
    )
)



;; Check story in backlog
(define-read-only (story-in-backlog (story-id uint) (team-member principal))
    (is-some (map-get? user-stories { story-id: story-id, team-member: team-member }))
)