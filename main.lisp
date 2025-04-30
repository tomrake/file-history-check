(in-package #:file-history-check)

(defparameter *backup-points* nil
  "A backup-point is backup device in FileHistory
   A list entries FileHistory disks:
   For a samba share entry on samba-host could be:
      (\"\" \"samba-host\" \"filehistory\")")
(defparameter *backup-users*  nil
  "A list of backup user entries in a backup disk.
   A backup-user is a relative offset within a backup-point.
   A typical backup user entry is (\"user\" \"DISK-NAME\" \"Configuration\")")

(defun get-preferences ()
  (let ((pref-file (make-pathname :directory '(:absolute :home) :name "file-history-check-pref" :type "lisp")))
    (when (probe-file pref-file)
      (load pref-file))
    (unless *backup-points*
      (error "*backup-points* is empty. Set it in ~A" pref-file))
    (unless *backup-users*
      (error "*backup-users* is empty. Set it in ~A"  pref-file))))

(defun win-path-segment (s)
  "A Windows path segqment with preceeding separator."
  (concatenate 'string "\\" s))

(defun make-win-path (segments)
  "Convert a list of path segment names into a single window path segment path."
  (let ((rv ""))
    (dolist (seg segments)
      (setf rv (concatenate 'string rv (win-path-segment seg))))
    rv))


(defmacro with-remotes (remote-list a-remote &body body)
  `(dolist (,a-remote ,remote-list)
     ,@body))

(defmacro with-users (user-list a-user &body body)
  `(dolist (,a-user ,user-list)
     ,@body))

(defmacro with-files (file-list a-file &body body)
  `(dolist (,a-file ,file-list)
     ,@body))


;; (defun main ()
;;   (with-remotes '(("cisco" "filehistory")) a-remote
;;     (format t "~A" a-remote)))


(defun report-path (a-path)
  (let (a-date (time-string "Not Found"))
    (when (probe-file a-path)
      (setf a-date (file-write-date a-path))
      (setf time-string (local-time:format-timestring nil (local-time:universal-to-timestamp a-date) :format local-time:+rfc-1123-format+)))
    (format t "Date: ~A path: ~A~%" time-string a-path)))

(defun main ()
  (get-preferences)
  (with-remotes *backup-points* the-remote
    (when (probe-file (make-win-path the-remote))
      (format t "##### Backup Point ##### ~A~%" the-remote)
      (with-users *backup-users*  the-user
	(format t "#### User Disk #### ~A~%" the-user)
	(with-files '(("Catalog1.edb") ("Catalog2.edb") ("Config1.xml") ("Config2.xml")) the-file
	  (report-path (make-win-path (concatenate 'list  the-remote the-user the-file))))))))
