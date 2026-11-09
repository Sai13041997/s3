Hi Adam, I’m building the AWS side now (S3 bucket + IAM role in our L2 accounts). To finish the role and send you the bucket name, Region and role ARN, I need a few answers from you:

Needed first (these block the role):

Service account email your Cloud Function runs as
That service account’s unique numeric ID. You can get it with: gcloud iam service-accounts describe <email> --format="value(uniqueId)"
Token audience you’ll request when the function fetches its Google ID token. If you don’t have one in mind, I can suggest a value and we agree on it.
