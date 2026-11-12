Praneeth, Sai
Thanks Alex.   Google UID: it’s the unique numeric ID of the Google service account the Firebase function runs as. The role only accepts Google tokens issued to that account. Agreed dev and prod shou…
I don't think we should give him the option for versioning, this data isn't business critical, and his application is responsible for the management, if we don't want storage costs for this app to balloon over time we would either need complex lifecycle rules or disable versioning
 
I would make him ask and justify versioning if he really needs it
 
Understood, didn't think about that part on the CORS
 
Also yeah did some reading on the GCP service account, looks like you did it exactly right, probably good to have separate account from test and prod though good thinking
 
