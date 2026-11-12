This looks ok in general, but I'm noticing the google uid is the same between dev and prod, what exactly does that value associate to? 
 
Also, idrk if we need cors rules considering the permissions around this bucket honestly but I guess it's not hurting anything, I don't think we'd ever want versioning on this thing, I think some of the code is slightly overly complex but it's still relatively readable and will do it's job I think so I guess taht's not a big deal
 
I noticed you enabled versioning on prod, don't think we want that
 
I would honestly recommend removing the sqitch for it, dont' think we ever want it
 
