(defsystem "file-history-check"
  :description "file-history-check return the modication times of filehistory backups"
  :version "0.0.1"
  :author "Tom Rake<zzzap1958@gmail.com"
  :licence "GPL3"
  :depends-on ("local-time")
  :components ((:file "package")
	       (:file "main")))
