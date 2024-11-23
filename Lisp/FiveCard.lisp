
;;; You can use this to cut down on some of the spurious errors that SBCL produces
(declaim (sb-ext:muffle-conditions cl:warning))

(load "Lisp/Card.lisp")
(load "Lisp/Hand.lisp")
(defpackage :five-card
  (:use :cl :card :hand))  ; Use the common Lisp package
(in-package :five-card)

(defun create-ordered-deck ()
  (let* ((suits '("D" "C" "H" "S"))
         (faces '("2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K" "A"))
         (deck '()))
    (dotimes (i (length suits))
      (dotimes (j (length faces))
        (push (card:make-card (nth j faces) (nth i suits)) deck)))
    deck))

;;; Function to shuffle the deck correctly
(setf *random-state* (make-random-state t))
(defun shuffle-deck (deck)
  "Shuffles a list of cards (deck) using the Fisher-Yates algorithm."
  (let ((n (length deck)))
    (loop for i from (1- n) downto 1 do
         (let ((j (random (1+ i))))  ; random index between 0 and i
           (let ((temp (nth j deck)))  ; store the card at index j
             (setf (nth j deck) (nth i deck))  ; set card at index i to j
             (setf (nth i deck) temp))))  ; set card at index i to original value of j
  deck))

;;; Function to display a deck of cards
(defun display-deck (deck)
  (loop for i from 1 to (length deck)
        for card in deck
        do (progn
             (format t "~A " (card-to-string card))  ;; Display the card
             (when (= (mod i 13) 0)                  ;; After every 13 cards, print a new line
               (format t "~%")))))

;;; Function to deal 6 hands of 5 cards each
(defun deal-hands (deck)
  (let ((hands '()))
    (loop for i from 0 below 6
          do (let ((hand (hand:make-hand (subseq deck (* i 5) (+ (* i 5) 5)))))
                   ;; Set the unsorted cards for the hand
                   (set-unsorted hand (subseq deck (* i 5) (+ (* i 5) 5)))
                   ;; Add the hand to the list
                   (push hand hands)
               )
    )
    ;; Update the deck by removing the first 30 cards dealt
    
    hands))

;;; Main function for running the program
(defun main ()
  (let* ((deck (create-ordered-deck))
         (shuffled-deck (shuffle-deck deck))
         (hands (reverse (deal-hands shuffled-deck))))  ;; Deal the hands here so it's accessible
    
    ;; Display introductory messages and the shuffled deck
    (format t "*** P O K E R H A N D A N A L Y Z E R ***~%")
    (format t "~%*** USING RANDOMIZED DECK OF CARDS ***~%")
    (format t "~%*** Shuffled 52 card deck:~%")
    (display-deck shuffled-deck)
    (setf shuffled-deck (subseq shuffled-deck 30)) 
    ;; Display the six hands
    (format t "~%*** Here are the six hands...~%")
    (loop for hand in hands
          do (hand-to-string hand)
          do (terpri))
          
    (format t "~%*** Here is what remains in the deck...~%")
    (display-deck shuffled-deck) (terpri)

    ;; Define an array of hand types in order of rank
    (let ((hand-types '("High Card" "One Pair" "Two Pair" "Three of a Kind" "Straight" "Flush" "Full House" 
                        "Four of a Kind" "Straight Flush" "Royal Flush")))
    
      ;; Sort hands based on the index of their hand_type in the hand-types array
      (format t "~%--- WINNING HAND ORDER ---~%")
      (let ((sorted-hands (sort hands 
                                (lambda (hand1 hand2)
                                  (let ((index1 (position (get-hand-type hand1) hand-types :test #'string=))
                                        (index2 (position (get-hand-type hand2) hand-types :test #'string=)))
                                    (if (and index1 index2)
                                        (< index1 index2)  ; Compare the indices
                                        nil))))))
        (loop for hand in (reverse sorted-hands)
              do (hand-to-string hand)
              do (format t " - ~A~%" (get-hand-type hand)))))
  )
)
            
(defun split-string (string delimiter)
  "Splits a string into a list of substrings, using the delimiter."
  (let ((start 0)
        (result '()))
    (loop for i from 0 to (length string)
          do (if (char= (elt string i) delimiter)
                 (progn
                   (push (subseq string start i) result)
                   (setf start (1+ i)))))
    (nreverse result)))
            
(defun comma-split (string)
  (loop for start = 0 then (1+ finish)
        for finish = (position #\, string :start start)
        collecting (if finish
                      (subseq string start finish)
                      (subseq string start))  ;; If no comma, take the rest of the string
        until (null finish)))
        
(defun remove-newlines (input-string)
  (remove #\Newline input-string :count nil :test #'char=))

(defun file-handling (file-path)
  (format t "*** P O K E R H A N D A N A L Y Z E R ***~%")
  (terpri)
  (format t "*** USING TEST DECK ***~%")
  (terpri)
  (format t "*** File: ~A~%" file-path)

  (handler-case
      (with-open-file (stream file-path)
        (let ((hands '())
              (seen-cards '())
              (has-duplicate nil)
              (duplicate-card nil)
              (hand-count 0)
              (valid-suits '("H" "D" "C" "S")))  ; Valid suits list

          ;; Loop through each line in the file
          (loop for line = (read-line stream nil) 
                while (< hand-count 6)  ; Process only 5 hands
                do
                  (princ line) (terpri) 

                  (let* ((card-records (comma-split line))  ; Split cards
                         (hand '()))  ; Initialize hand

                    ;; Process each card in the hand
                    (dolist (card-record card-records)
                      ;(format t "~A~%" card-record)

                      (let* ((card-value (remove-newlines (string-trim '() card-record)))
                             (card-face (if (string-equal (subseq card-value 0 2) "10") 
                                            (subseq card-value 0 2) 
                                            (subseq card-value 0 (1- (length card-value)))))
                             (card-suit (subseq card-value (length card-face))) ; initially treat last part as suit
                        )
                         ;(format t "~A ~A~%" card-face card-suit)
                        ;; Check if last character is a valid suit
                        (if (not (member card-suit valid-suits :test #'string=))
                            (progn
                              ;; If not, remove the last character (assumed invalid)
                              (setf card-value (subseq card-value 0 (1- (length card-value))))
                              ;; Recalculate card face and suit after trimming
                              (setf card-face (if (string-equal (subseq card-value 0 2) "10") 
                                                  (subseq card-value 0 2) 
                                                  (subseq card-value 0 (1- (length card-value)))))
                              (setf card-suit (subseq card-value (length card-face)))))
                          ;(format t "~A ~A~%" card-face card-suit)
                        ;; Check for duplicate cards
                        (when (member card-value seen-cards :test #'string=)
                          (setq has-duplicate t)
                          (setq duplicate-card card-value))

                        ;; Add card to seen cards and hand
                        (push (string-trim '() card-value) seen-cards)
                        (push (make-card (string-trim '() card-face) (string-trim '() card-suit)) hand)))

                    ;; Add the processed hand to the list of hands
                    (let ((new-hand (make-hand (reverse (subseq hand 0)))))
                      (set-unsorted new-hand (reverse (subseq hand 0)))
                      (push new-hand hands))

                    ;; Increment hand count
                    (setq hand-count (1+ hand-count))
                    )
                )

          ;; Handle duplicates
          (if has-duplicate
              (progn
                (format t "~%*** ERROR - DUPLICATED CARD FOUND IN DECK ***~%")
                (format t "~%*** DUPLICATE: ~A ***~%" duplicate-card))
              (progn
                    (terpri)
                    (format t "*** Here are the six hands...~%")
                    (dolist (hand (reverse hands))
                        (hand-to-string hand)
                        (terpri)
                    )

                    (format t "~%--- WINNING HAND ORDER ---~%")

                    (let ((sorted-hands (sort hands #'compare-hands)))
                        (dolist (hand sorted-hands)
                          (hand-to-string hand)
                          (format t " - ~A~%" (get-hand-type hand)))
                    )
                    (terpri)
              )
          )
        )
      )

    ;; Error handling
    (error (e)
          (format t "Error reading file: ~A~%" e)
      )
    )
)

;;; Check command-line arguments
(if (< (length sb-ext:*posix-argv*) 2)  ;; If there are less than two arguments
    (main)                            ;; Run main function
    (file-handling (second sb-ext:*posix-argv*)))  ;; Pass the second argument (file path)