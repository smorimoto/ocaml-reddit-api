    ((request(Post_form(uri((scheme(https))(host(www.reddit.com))(path /api/v1/access_token)))(headers((authorization <AUTHORIZATION>)))(params((grant_type(password))(username(<USERNAME>))(password(<PASSWORD>))))))(response(((encoding(Fixed 114))(headers((accept-ranges bytes)(cache-control"max-age=0, must-revalidate")(connection keep-alive)(content-length 114)(content-type"application/json; charset=UTF-8")(date"Thu, 03 Sep 2020 11:41:49 GMT")(server snooserv)(set-cookie"edgebucket=XhqAsnZsPnlkl4UbHi; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"access_token\": \"<ACCESS_TOKEN>\", \"token_type\": \"bearer\", \"expires_in\": 3600, \"scope\": \"*\"}")))((request(Post_form(uri((scheme(https))(host(oauth.reddit.com))(path /api/uncollapse_message)))(headers((authorization"bearer <ACCESS_TOKEN>")))(params((raw_json(1))(id(t4_rdjz4y))))))(response(((encoding(Fixed 2))(headers((accept-ranges bytes)(cache-control"private, s-maxage=0, max-age=0, must-revalidate, no-store, max-age=0, must-revalidate")(connection keep-alive)(content-length 2)(content-type"application/json; charset=UTF-8")(date"Thu, 03 Sep 2020 11:41:49 GMT")(expires -1)(server snooserv)(set-cookie"redesign_optout=true; Domain=reddit.com; Max-Age=94607999; Path=/; expires=Sun, 03-Sep-2023 11:41:49 GMT; secure")(set-cookie"session_tracker=aplberlgcclimefapp.0.1599133309422.Z0FBQUFBQmZVTlo5ZVVQVFRUQkVwXzI2MGF3UFBFR0ZTckpneTlUTTZyc3h6elg0M1RJSHF2WlBlZVU2ckg4cWdxcjNTa012RWxsakcxSzFENzVzVk4zZDIweWNIakwxSFBzdElwYkFkaWwyZm5UQ2Q2Q3gzUEY0X1Z6NUJaQXdaUjU3SFZ6M2RQeDc; Domain=reddit.com; Max-Age=7199; Path=/; expires=Thu, 03-Sep-2020 13:41:49 GMT; secure")(set-cookie"edgebucket=sFeEgj69sVZUFzMuJx; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-ratelimit-remaining 599.0)(x-ratelimit-reset 491)(x-ratelimit-used 1)(x-ua-compatible IE=edge)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false)){})))
