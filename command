Hi Adam, our PR review raised a couple of points, so I’m making two changes before prod:

Separate service account for prod. Right now dev and prod trust the same service account. That means any dev or test code, including local testing, can also reach the prod bucket, and a bug or wrong bucket name during testing could overwrite or delete live photos. A separate prod account keeps the two fully apart: dev credentials simply can’t touch prod. Could you create one, e.g. s3-files-prod@events-ea237.iam.gserviceaccount.com, have your prod function run as it, and send me its unique ID? The audience stays kyfb-events-files.
Versioning is turned off on the bucket. With versioning on, S3 keeps every old copy of a file each time it’s deleted or replaced, so storage and cost keep growing over time unless we add complex cleanup rules. Since your app already manages the files and decides what’s kept or deleted, we’re leaving versioning off. The trade-off is that a deleted or overwritten file can’t be recovered from the bucket. If you need recovery for a specific reason, let me know and we can review it.

I’ll deploy prod as soon as I have the new service account ID.
