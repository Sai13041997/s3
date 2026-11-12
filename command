Thanks Alex.

Google UID: it’s the unique numeric ID of the Google service account the Firebase function runs as. The role only accepts Google tokens issued to that account. Agreed dev and prod shouldn’t share it. I’m asking Adam for a dedicated prod service account.
Versioning: I’m checking with Adam first, since it decides whether deleted files can be recovered. If he’s fine without it, I’ll remove it and the switch.
CORS: needed because the browser talks to S3 directly. Uploads use a pre-signed POST form, and reads use img and fetch. Without CORS the browser blocks those calls even with a valid signed URL. It’s locked to the app’s origins, GET/HEAD/POST and the Content-Type header only.
Complexity: happy to trim further, such as the KMS switch, in a follow-up.

I’ll update the PR once Adam confirms and ping you for another review.
