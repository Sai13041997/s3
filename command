Kept consistent with the other KFB repos on the shared kfb-github-terraform-state backend, which do not use locking today. Applies only run through the manually triggered workflow. I’ll raise state locking with the tf-action-tooling owners as a platform-wide change.



Not needed. The app uploads with pre-signed POST, not PUT. README updated to match.
