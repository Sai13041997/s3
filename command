variable "environment" {
  type        = string
  description = "Environment to deploy into."
}

variable "destination_account_id" {
  type        = string
  description = "AWS account ID to deploy into (e.g. L2-Development)."
}

variable "use_kms" {
  description = "Use a KMS key instead of SSE-S3 (only if Security requires it)"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN, used only when use_kms = true"
  type        = string
  default     = null
}

variable "cors_allowed_origins" {
  description = "Web app origins allowed to call the bucket from a browser. Empty = no CORS."
  type        = list(string)
  default     = []
}

variable "google_sa_unique_id" {
  description = "Unique numeric ID of the Google service account allowed to assume the role"
  type        = string
}

variable "token_audience" {
  description = "Audience the function requests on its Google ID token"
  type        = string
}

variable "object_prefixes" {
  description = "Folders in the bucket the role can use"
  type        = list(string)
  default     = ["photos/"]
}

variable "allow_delete" {
  description = "Let the role delete photos (false if the app never deletes)"
  type        = bool
  default     = true
}
