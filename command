cd "C:\Users\T012sp\Git repo\real-time-insurance-infra"
Get-ChildItem -Recurse -Filter *.tf | Where-Object { $_.FullName -notmatch '\\.terraform\\' -and (Select-String -Path $_.FullName -Pattern 'required_providers|backend "s3"' -Quiet) } | ForEach-Object { "===== $($_.Name) ====="; Get-Content $_.FullName -Raw }
