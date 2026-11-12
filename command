Hi Adam, prod is deployed:

Bucket: kfb-events-photos-prod
Region: us-east-1
Role ARN: arn:aws:iam::339712702314:role/kfb-events-s3-role-prod
Folders: photos/ and resources/
Token audience: kyfb-events-files
Service account: s3-files-prod@events-ea237.iam.gserviceaccount.com

Same setup as dev: CORS allows your 3 web origins (no localhost), GET/HEAD/POST and the Content-Type header only, and no versioning. Could you do a quick upload and view in prod, and if possible have a staff member open a photo on a KFB-managed device? Good luck with the app store reviews!
