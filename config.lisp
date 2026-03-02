(in-package :cl-user)

(defparameter link-capture::*log-level* :info) ; :error :warn :info :debug
(defparameter link-capture::*secret-token* "CHANGE_ME")
(defparameter link-capture::*port* 8080)

(defparameter link-capture::*output-file*
  (merge-pathnames "org/links.org" (user-homedir-pathname)))

(defparameter link-capture::*log-file*
  (merge-pathnames  ".link-capture.log" (user-homedir-pathname)))
