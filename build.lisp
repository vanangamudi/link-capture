;;(load "~/quicklisp/setup.lisp")

(ql:quickload :hunchentoot)

(load "link-capture.lisp")

(sb-ext:save-lisp-and-die
 "link-capture"
 :toplevel #'link-capture::main
 :executable t
 :save-runtime-options t)
