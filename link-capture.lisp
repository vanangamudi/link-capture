;;;; link-capture.lisp  -- binary-ready VPS link capture

(defpackage :link-capture
  (:use :cl)
  (:export #:main)
  (:import-from :hunchentoot
                #:define-easy-handler
                #:easy-acceptor
                #:start
                #:stop
                #:parameter
                #:return-code*
                #:remote-addr*))
(in-package :link-capture)

;;; * Config (can be overridden by config.lisp) *

(defparameter *port* 8080)
(defparameter *output-file*
  (merge-pathnames "org/link-capture.org"
                   (user-homedir-pathname)))
(defparameter *log-file*
  (merge-pathnames ".link-capture.log"
                   (user-homedir-pathname)))
(defparameter *log-level* :info)
(defparameter *secret-token* "CHANGE_ME")

(defparameter *server* nil)

;;; * Tiny logger *

(defparameter *level-order* '(:error :warn :info :debug))

(defun level<= (a b)
  (let ((ia (position a *level-order*))
        (ib (position b *level-order*)))
    (and ia ib (<= ia ib))))

(defun now-string ()
  (multiple-value-bind (_sec min hour day month year)
      (decode-universal-time (get-universal-time))
    (format nil "~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d"
            year month day hour min)))

(defun log-line (level fmt &rest args)
  (when (level<= level *log-level*)
    (with-open-file (out *log-file*
                         :direction :output
                         :if-exists :append
                         :if-does-not-exist :create)
      (format out "~a [~(~a~)] " (now-string) level)
      (apply #'format out fmt args)
      (terpri out))))

(defun log-info (fmt &rest args) (apply #'log-line :info fmt args))
(defun log-warn (fmt &rest args) (apply #'log-line :warn fmt args))
(defun log-error (fmt &rest args) (apply #'log-line :error fmt args))

;;; * Capture writing *

(defun append-link (url title body)
  (ensure-directories-exist *output-file*)
  (with-open-file (out *output-file*
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
    (format out "* ~a~%" title)
    (format out ":PROPERTIES:~%")
    (format out ":CAPTURED: ~a~%" (now-string))
    (format out ":END:~%~%")
    (format out "- URL :: ~a~%~%" url)
    (when (and body (plusp (length body)))
      (format out "- Selection ::~%#+begin_quote~%~a~%#+end_quote~%~%" body))
    (format out "~%")))

;;; * HTTP handler *

(define-easy-handler (capture-handler :uri "/capture") ()
  (handler-case
      (let* ((token (parameter "token"))
             (url   (parameter "url"))
             (title (parameter "title"))
             (body  (parameter "body")))
        (cond
          ((null token)
           (setf (return-code*) 403)
           (log-warn "Missing token from ~a" (remote-addr*))
           "Missing token")

          ((not (string= token *secret-token*))
           (setf (return-code*) 403)
           (log-warn "Invalid token from ~a" (remote-addr*))
           "Invalid token")

          ((or (null url) (zerop (length url)))
           (setf (return-code*) 400)
           (log-warn "Missing URL from ~a" (remote-addr*))
           "Missing URL")

          (t
           (append-link url (or title url) body)
           (log-info "Saved: ~a" url)
           "Saved")))
    (error (e)
      (setf (return-code*) 500)
      (log-error "Unhandled error: ~a" e)
      "Internal error")))

;;; * Startup / shutdown

(defun load-config-if-present ()
  (let ((cfg (merge-pathnames "config.lisp"
                              *default-pathname-defaults*)))
    (when (probe-file cfg)
      (load cfg)
      (log-info "Loaded config from ~a" cfg))))

(defun start-server ()
  (load-config-if-present)
  (log-info "Starting on 127.0.0.1:~a" *port*)
  (setf *server*
        (start (make-instance 'easy-acceptor
                              :address "127.0.0.1"
                              :port *port*))))

(defun stop-server ()
  (when *server*
    (stop *server*)
    (setf *server* nil)
    (log-info "Stopped server")))

(defun main ()
  (start-server)
  (loop (sleep 3600))
  (stop-server))
