try { Invoke-WebRequest "https://kfb-events-photos-prod.s3.us-east-1.amazonaws.com/photos/test.jpg" -UseBasicParsing } catch { $_.Exception.Response.StatusCode.value__ }
try { Invoke-WebRequest "https://kfb-events-photos-prod.s3.us-east-1.amazonaws.com/" -UseBasicParsing } catch { $_.Exception.Response.StatusCode.value__ }
