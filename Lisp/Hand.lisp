

;;; You can use this to cut down on some of the spurious errors that SBCL produces
(declaim (sb-ext:muffle-conditions cl:warning))

(load "Lisp/Card.lisp")
(defpackage :hand
  (:use :cl :card)
  (:export :make-hand :hand-to-string :get-hand-type :set-unsorted :compare-hands))  ; Use the common Lisp package
(in-package :hand)

;; Hand class definition
(defclass hand ()
  ((cards :initarg :cards :accessor cards)
   (unsorted :initform nil :accessor unsorted)
   (hand-type :initform "" :accessor hand-type)
   (key-cards :initform nil :accessor key-cards)
   (kickers :initform nil :accessor kickers)))
   
   (defun make-hand (cards)
  "Creates a hand with the specified cards."
  (let ((hand (make-instance 'hand :cards cards))) 
    (separate-key-cards-and-kickers hand)                      
    (sort-hand hand)
    (evaluate-hand hand) 
    hand))
    
    ;;; Function to print out the rank of a hand
(defun get-hand-type (hand)
  (hand-type hand))
  
  (defun set-hand-type (hand hand-type-in)
  "Sets the hand-type of the given hand instance."
  (setf (hand-type hand) hand-type-in))
  
  (defun set-unsorted (hand card-list)
  "Sets the unsorted slot of a hand object."
  (setf (unsorted hand) (copy-list card-list)))

;; Evaluate the type of the hand (e.g., "flush", "straight", etc.)
(defun evaluate-hand (hand)
  (let* ((cards (cards hand))
         (face-counts (make-array 15 :initial-element 0)))
    ;; Count face values
    (dolist (card cards)
      (incf (aref face-counts (face-value card))))
    (let ((is-flush-bool (is-flush cards))
          (is-straight-bool (is-straight cards))
          )
      (cond
       ((and is-flush-bool is-straight-bool) (set-hand-type hand "Straight Flush") (set-hand-value-to-cards hand 9000))
       ((contains-n-of-a-kind face-counts 4) (set-hand-type hand "Four of a Kind") (set-hand-value-to-cards hand 8000))
       ((and (contains-n-of-a-kind face-counts 3) (contains-n-of-a-kind face-counts 2))
        (set-hand-type hand "Full House") (set-hand-value-to-cards hand 7000))
       (is-flush-bool (set-hand-type hand "Flush") (set-hand-value-to-cards hand 6000))
       (is-straight-bool (set-hand-type hand "Straight") (set-hand-value-to-cards hand 5000))
       ((contains-n-of-a-kind face-counts 3) (set-hand-type hand "Three of a Kind") (set-hand-value-to-cards hand 4000))
       ((= (count-pairs face-counts) 2) (set-hand-type hand "Two Pair") (set-hand-value-to-cards hand 3000))
       ((contains-n-of-a-kind face-counts 2) (set-hand-type hand "One Pair") (set-hand-value-to-cards hand 2000))
       (t (set-hand-type hand "High Card") (set-hand-value-to-cards hand 1000))))))

;; Set hand value to cards
(defun set-hand-value-to-cards (hand base-value)
  (dolist (card (cards hand))
    (let ((hand-value (if (or (string= (hand-type hand) "One Pair")
                              (string= (hand-type hand) "Two Pair"))
                          (+ base-value (face-value card))
                          (+ base-value (face-value card) (suit-value card)))))
      (set-hand-value card hand-value)
      )))

;; Check if hand is flush
(defun is-flush (cards)
  (let ((suit (suit (first cards))))
    (every (lambda (card) (string= (suit card) suit)) cards)))

;; Check if hand is straight
(defun is-straight (cards)
  "Check if the hand of cards is a straight."
  (let* ((values '())  ; Initialize an empty list to hold the card values
         (high-ace-straight-p nil))  ; Flag to check for a special high Ace straight
  
    ;; Manually extract the face values of the cards
    (dolist (card cards)
      (push (face-value card) values))  ; Add each card's value to the list
    
    ;; Sort the values manually using a simple insertion sort
    (setq values (manual-sort values))

    ;; Check for high Ace straight (2, 3, 4, 5, 14)
    (if (and (= (first values) 2)
             (= (first (last values)) 14)
             (= (nth 1 values) 3)
             (= (nth 2 values) 4)
             (= (nth 3 values) 5))
        (setq high-ace-straight-p t))  ; Set the flag to true for a high Ace straight

    ;; If we have a high Ace straight, return true
    (if high-ace-straight-p
        t
      ;; Otherwise, check if the values are consecutive
      (loop for i from 1 to (1- (length values))
            always (= (nth i values) (+ (nth (1- i) values) 1))))))
            
(defun manual-sort (list)
  "Sort a list of numbers using the insertion sort algorithm."
  (let ((sorted '()))
    (dolist (item list sorted)
      (setq sorted (insert-in-order item sorted)))))

(defun insert-in-order (item list)
  "Insert an item into a sorted list."
  (if (endp list)  ; If the list is empty, return a list with the item
      (list item)
      (if (< item (first list))  ; If the item is smaller than the first element, insert it at the beginning
          (cons item list)
          (cons (first list) (insert-in-order item (rest list))))))

;; Check for n of a kind
(defun contains-n-of-a-kind (face-counts n)
  (some (lambda (x) (= x n)) face-counts))

;; Count number of pairs
(defun count-pairs (face-counts)
  (count 2 face-counts))

;; Separate key cards and kickers
(defun separate-key-cards-and-kickers (hand)
  (let ((cards (cards hand))
        (face-counts (make-array 15 :initial-element 0)))
    (dolist (card cards)
      (incf (aref face-counts (face-value card))))
    (let ((key-cards (remove-if-not (lambda (card) (> (aref face-counts (face-value card)) 1)) cards))
          (kickers (remove-if-not (lambda (card) (= (aref face-counts (face-value card)) 1)) cards)))
      (setf (key-cards hand) key-cards)
      (setf (kickers hand) kickers))))

;; Sort the hand (key cards and kickers)
(defun sort-hand (hand)
  (let ((key-cards (key-cards hand))
        (kickers (kickers hand)))
    (setq key-cards (sort key-cards #'< :key #'(lambda (card) (+ (face-value card) (suit-value card)))))
    (setq kickers (sort kickers #'< :key #'(lambda (card) (+ (face-value card) (suit-value card)))))
    (setf (cards hand) (append key-cards kickers))))

;; Compare two hands
(defun compare-hands (hand1 hand2)
  (let ((cards1 (cards hand1))   ; Get the list of cards for hand1
        (cards2 (cards hand2))
        (keycards-length (length (key-cards hand1))))  ; Length of keycards for comparison
    ;; First comparison loop: Compare cards based on hand value up to keycards length
    (loop for i from 0 to (1- keycards-length)  ; Loop from 0 to length of keycards - 1
          for card1 in cards1
          for card2 in cards2
          until (not (= (hand-value card1) (hand-value card2)))  ; Compare hand values
          do (if (< (hand-value card1) (hand-value card2))  ; If card1 is less than card2
                 (return -1)  ; Return -1 if hand1 is worse
                 (return 1))) ; Return 1 if hand1 is better
    
    ;; Tie-breaking step: Set hand value to suit value if hand values are equal
    (loop for card in cards1 do
          (set-hand-value card (suit-value card)))  ; Add suit value to hand value
    (loop for card in cards2 do
          (set-hand-value card (suit-value card)))  ; Add suit value to hand value
    
    ;; Second comparison loop: Compare remaining cards from keycards length onwards
    (loop for i from keycards-length to (1- (length cards1))  ; Loop from keycards length to end
          for card1 in cards1
          for card2 in cards2
          until (not (= (hand-value card1) (hand-value card2)))  ; Compare suit values
          do (if (< (hand-value card1) (hand-value card2))  ; If card1 is less than card2
                 (return -1)  ; Return -1 if hand1 is worse
                 (return 1))) ; Return 1 if hand1 is better
    0))  ; If all comparisons are equal, return 0

;; To string for hand
(defun hand-to-string (hand)
  (loop for card in (unsorted hand)
        do (format t "~A " (card-to-string card)))  ; Print each card followed by a space
)
