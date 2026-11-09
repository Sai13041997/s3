Get-ChildItem -Recurse -File | ForEach-Object { "===== $($_.FullName.Substring((Get-Location).Path.Length + 1)) ====="; Get-Content $_.FullName -Raw }
