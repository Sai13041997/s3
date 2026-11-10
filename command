No CORS rule on the bucket yet. I add it once I have your web domains. Can you send me:

The exact origins the browser runs on, e.g. https://yourapp.web.app, plus any custom domain, and http://localhost:<port> if you test locally
Whether the browser does uploads with PUT, reads with fetch/XHR, or both

The rule I’ll set allows PUT and GET from those origins only.
