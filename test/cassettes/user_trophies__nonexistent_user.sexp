  ((request(Post_form(uri((scheme(https))(host(www.reddit.com))(path /api/v1/access_token)))(headers((authorization <AUTHORIZATION>)))(params((grant_type(password))(username(<USERNAME>))(password(<PASSWORD>))))))(response(((encoding(Fixed 117))(headers((accept-ranges bytes)(cache-control"max-age=0, must-revalidate")(connection keep-alive)(content-length 117)(content-type"application/json; charset=UTF-8")(date"Sun, 10 Jan 2021 01:43:36 GMT")(server snooserv)(set-cookie"edgebucket=ZEZ77U0pKYTfrbEWGG; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"access_token\": \"<ACCESS_TOKEN>\", \"token_type\": \"bearer\", \"expires_in\": 3600, \"scope\": \"*\"}")))((request(Get(uri((scheme(https))(host(oauth.reddit.com))(path /api/v1/user/thisusershouldnotexist/trophies)(query((raw_json(1))))))(headers((authorization"bearer <ACCESS_TOKEN>")))))(response(((encoding(Fixed 117))(headers((accept-ranges bytes)(access-control-allow-origin *)(access-control-expose-headers X-Moose)(cache-control"private, s-maxage=0, max-age=0, must-revalidate, no-store, max-age=0, must-revalidate")(connection keep-alive)(content-length 117)(content-type"application/json; charset=UTF-8")(date"Sun, 10 Jan 2021 01:43:36 GMT")(expires -1)(server snooserv)(set-cookie"loid=00000000009qwqjgvj.2.1610243016983.Z0FBQUFBQmYtbHZJUU9hRUFUWFZjODZtYXpQc3ZmcEFBRGlhUmJ6SHVUcHZkaWhnSlYzLTdGX1lWeFBKdXBidUFHWkNGcDlyWjUwYldZRm9pY1hzSmdRVDUtc29oU1dRVTZuN2xORV9aRUw3c1BuREVoTTc0QWoxTUc5QWNJVzhpV3FBRld6MXd5cGM; Domain=reddit.com; Max-Age=63071999; Path=/; expires=Tue, 10-Jan-2023 01:43:36 GMT; secure; SameSite=None; Secure")(set-cookie"session_tracker=lelclkkkproocadhjk.0.1610243016953.Z0FBQUFBQmYtbHZJc1BPR0JwU2NQSGZmUmQzWEFKUjcteG9uZWpjQnRvamdkVHFRblh4RkFXNFkyOGZQQjhILVdGUWgwOUtuMVF5RUR2Q2VtU292NGdTZkFGMHhRM0VtMWM1ek0yaS1JYzFSLXBYRVJEWGE4alNYclZIYlg1TURsZ1U2NWRLd2xPOXM; Domain=reddit.com; Max-Age=7199; Path=/; expires=Sun, 10-Jan-2021 03:43:36 GMT; secure; SameSite=None; Secure")(set-cookie"csv=1; Max-Age=63072000; Domain=.reddit.com; Path=/; Secure; SameSite=None")(set-cookie"edgebucket=KcuBWSGAMYDPIP0qGP; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-ratelimit-remaining 599.0)(x-ratelimit-reset 384)(x-ratelimit-used 1)(x-ua-compatible IE=edge)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status Bad_request)(flush false))"{\"fields\": [\"id\"], \"explanation\": \"that user doesn't exist\", \"message\": \"Bad Request\", \"reason\": \"USER_DOESNT_EXIST\"}")))