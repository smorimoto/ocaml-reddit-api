((request(Post_form(uri((scheme(https))(host(www.reddit.com))(path /api/v1/access_token)))(headers((authorization <AUTHORIZATION>)))(params((grant_type(password))(username(<USERNAME>))(password(<PASSWORD>))))))(response(((encoding(Fixed 114))(headers((accept-ranges bytes)(cache-control"max-age=0, must-revalidate")(connection keep-alive)(content-length 114)(content-type"application/json; charset=UTF-8")(date"Sun, 30 Aug 2020 12:04:28 GMT")(server snooserv)(set-cookie"edgebucket=lXYgUs7xkMZTsWAnj4; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"access_token\": \"<ACCESS_TOKEN>\", \"token_type\": \"bearer\", \"expires_in\": 3600, \"scope\": \"*\"}")))((request(Get(uri((scheme(https))(host(oauth.reddit.com))(path /prefs/blocked)(query((raw_json(1))))))(headers((authorization"bearer <ACCESS_TOKEN>")))))(response(((encoding(Fixed 129))(headers((accept-ranges bytes)(cache-control"private, s-maxage=0, max-age=0, must-revalidate, no-store, max-age=0, must-revalidate")(connection keep-alive)(content-length 129)(content-type"application/json; charset=UTF-8")(date"Sun, 30 Aug 2020 12:04:29 GMT")(expires -1)(server snooserv)(set-cookie"session_tracker=mligfrlljmffiqejmp.0.1598789069287.Z0FBQUFBQmZTNVhOdDJnSlVWWHNZOG95MWZ4MnBXbUhDXzI0Q01fbFBORVZfd19kaFRSbUFYd0ZtbHNJcGswQ094RmJHUDRfNFBodVFvN3NoRG9yTmNyZHhubGc1YUFiaUYtV2RWS3RKV182djFJc0ZxWTBXMjhYX0p2aGFucXM2ckphSDVEVE83NGc; Domain=reddit.com; Max-Age=7199; Path=/; expires=Sun, 30-Aug-2020 14:04:29 GMT; secure; SameSite=None; Secure")(set-cookie"redesign_optout=true; Domain=reddit.com; Max-Age=94607999; Path=/; expires=Wed, 30-Aug-2023 12:04:29 GMT; secure")(set-cookie"csv=1; Max-Age=63072000; Domain=.reddit.com; Path=/; Secure; SameSite=None")(set-cookie"edgebucket=hva6CW1TtSBjRKdy1P; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-ratelimit-remaining 599.0)(x-ratelimit-reset 331)(x-ratelimit-used 1)(x-ua-compatible IE=edge)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"kind\": \"UserList\", \"data\": {\"children\": [{\"date\": 1598788910.0, \"rel_id\": \"r9_1vt16j\", \"name\": \"ketralnis\", \"id\": \"t2_nn0q\"}]}}")))
