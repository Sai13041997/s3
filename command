Adam: So far, so good. I just need s3:ListBucket set up. 
 
{
  "Effect": "Allow",
  "Action": "s3:ListBucket",
  "Resource": "arn:aws:s3:::kfb-events-photos-dev",
  "Condition": { "StringLike": { "s3:prefix": ["photos/*"] } }
}
