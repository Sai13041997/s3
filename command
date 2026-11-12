Hi Adam, two items from our PR review before I deploy prod:

Separate service account for prod. Please create one, e.g. s3-files-prod@events-ea237.iam.gserviceaccount.com, have your prod function run as it, and send me its unique ID. The audience stays kyfb-events-files.
No versioning on the bucket. Once a file is deleted or overwritten in S3, it can’t be recovered from the bucket, so your app is the source of truth for managing files. If you need recovery, let me know why and we can review it.
