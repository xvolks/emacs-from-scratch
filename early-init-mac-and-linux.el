;; early-init-mac-and-linux.el — Multi-platform early init
;; -*- lexical-binding: t; -*-

;; macOS: set MACOSX_DEPLOYMENT_TARGET so native compilation works correctly
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET"
          (or (getenv "MACOSX_DEPLOYMENT_TARGET")
              (string-trim
               (shell-command-to-string "sw_vers -productVersion")))))

;; Linux: no special early-init needed; native compilation works out of the box
;; on both x86_64 and aarch64 as long as libgccjit is installed.
