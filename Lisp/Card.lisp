

;;; You can use this to cut down on some of the spurious errors that SBCL produces
(declaim (sb-ext:muffle-conditions cl:warning))

(defpackage :card
  (:use :cl)
  (:export :make-card :card-to-string :face-value :suit-value :face :suit :hand-value :set-hand-value))  ; Use the common Lisp package

(in-package :card)

(defclass card ()
  ((face 
    :initarg :face 
    :accessor face)
   (suit 
    :initarg :suit 
    :accessor suit)
   (hand-value 
    :initform 0.0 
    :accessor hand-value)))
    
    ;;; Function to create a card
(defun make-card (facex suitx)
  (make-instance 'card :face facex :suit suitx))

(defun face-value (card)
  (let ((face (face card)))  ; Retrieve the face of the card
    (cond
     ((string= face "2") 2)
     ((string= face "3") 3)
     ((string= face "4") 4)
     ((string= face "5") 5)
     ((string= face "6") 6)
     ((string= face "7") 7)
     ((string= face "8") 8)
     ((string= face "9") 9)
     ((string= face "10") 10)
     ((string= face "J") 11)
     ((string= face "Q") 12)
     ((string= face "K") 13)
     ((string= face "A") 14)
     (t 0))))  ; Default case: returns 0 if face doesn't match any known value

(defun suit-value (card)
  (let ((suit (suit card)))  ; Retrieve the suit of the card
    (cond
     ((string= suit "D") 0.1)
     ((string= suit "C") 0.2)
     ((string= suit "H") 0.3)
     ((string= suit "S") 0.4)
     (t 0))))  ; Default case: returns 0 if suit doesn't match any known value

(defun card-to-string (card)
  (format nil "~A~A" (face card) (suit card)))

(defun set-hand-value (card value)
  (setf (hand-value card) (+ (hand-value card) value)))

(defun get-hand-value (card)
  (hand-value card))
