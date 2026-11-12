resource "aws_s3_bucket_cors_configuration" "photos" {
  count  = length(var.cors_allowed_origins) > 0 ? 1 : 0
  bucket = aws_s3_bucket.photos.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = var.cors_allowed_origins
    allowed_headers = ["Content-Type"]
    max_age_seconds = 3000
  }
}


git add s3.tf
git commit -m "Restrict CORS allowed headers to Content-Type"
git push origin feature/T012SP/HC-77160


Hi Adam, our security scan flagged the CORS rule, so I tightened it in dev: the browser can now only send the Content-Type header to S3. Could you quickly retest in dev: an upload, an image view, HEIC conversion and the photo editor? If anything fails, send me the browser console error. Once you confirm, I’ll push prod.


Allowed headers restricted to Content-Type. Methods are limited to GET, HEAD and POST. Multiple origins are required for the app’s own domains. The bucket is private and every request needs a valid pre-signed signature.
