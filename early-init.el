(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET"
          (or (getenv "MACOSX_DEPLOYMENT_TARGET")
              (string-trim
               (shell-command-to-string "sw_vers -productVersion")))))
