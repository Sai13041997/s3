environment            = "prod"
destination_account_id = "<L2-Prod account ID>"
google_sa_unique_id    = "113890604168937748514"
token_audience         = "kyfb-events-files"

object_prefixes   = ["photos/", "resources/"]
enable_versioning = true

cors_allowed_origins = [
  "https://events-ea237.web.app",
  "https://events-ea237.firebaseapp.com",
  "https://kfbeventstaff.com",
]
