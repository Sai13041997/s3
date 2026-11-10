Glad it’s working. On bucket access: console access to our AWS accounts would go through KFB’s access process, but your role can already list and read photos/ and resources/, so you can check from your function. Or tell me what you want verified (files, sizes, encryption) and I’ll check it for you.

For production I need:

Will prod use a separate service account? If so, its email and unique ID. A separate one is recommended, so dev can never touch prod files.
Prod web origins. I assume the same 3 minus localhost; confirm or correct.

Also, has a staff member viewed photos in dev from a KFB-managed laptop or phone? That’s the test that proves the original block is fixed.
