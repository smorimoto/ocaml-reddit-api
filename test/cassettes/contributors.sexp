    ((request(Post_form(uri((scheme(https))(host(www.reddit.com))(path /api/v1/access_token)))(headers((authorization <AUTHORIZATION>)))(params((grant_type(password))(username(<USERNAME>))(password(<PASSWORD>))))))(response(((encoding(Fixed 114))(headers((accept-ranges bytes)(cache-control"max-age=0, must-revalidate")(connection keep-alive)(content-length 114)(content-type"application/json; charset=UTF-8")(date"Sat, 19 Sep 2020 23:24:27 GMT")(server snooserv)(set-cookie"edgebucket=TjgCENvXAX0QKxZ8Q8; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"access_token\": \"<ACCESS_TOKEN>\", \"token_type\": \"bearer\", \"expires_in\": 3600, \"scope\": \"*\"}")))((request(Get(uri((scheme(https))(host(oauth.reddit.com))(path /r/ThirdRealm/about/contributors)(query((raw_json(1))))))(headers((authorization"bearer <ACCESS_TOKEN>")))))(response(((encoding(Fixed 284))(headers((accept-ranges bytes)(cache-control"private, s-maxage=0, max-age=0, must-revalidate, no-store, max-age=0, must-revalidate")(connection keep-alive)(content-length 284)(content-type"application/json; charset=UTF-8")(date"Sat, 19 Sep 2020 23:24:27 GMT")(expires -1)(server snooserv)(set-cookie"session_tracker=edljqrgdinoafnbfig.0.1600557867135.Z0FBQUFBQmZacE1yekFJZ3kwVDR5eFpOSmpLQi1HUFRyVk8wQWpjcFhoMVlESzVQR3dUeWpYaW5iMFVsOHAzVnRCMWZwSlROUmlwRTd3aWVkQzhWSkJENU1VUERrTVNTTVJZcEt6OXdvMlFxVWRsLTRuVVNoV2R5LWt4UkZOM1dpZjVWbnh2TGJ6ajY; Domain=reddit.com; Max-Age=7199; Path=/; expires=Sun, 20-Sep-2020 01:24:27 GMT; secure; SameSite=None; Secure")(set-cookie"redesign_optout=true; Domain=reddit.com; Max-Age=94607999; Path=/; expires=Tue, 19-Sep-2023 23:24:27 GMT; secure")(set-cookie"csv=1; Max-Age=63072000; Domain=.reddit.com; Path=/; Secure; SameSite=None")(set-cookie"edgebucket=RSBqbXic4JDhwaNMfW; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-ratelimit-remaining 599.0)(x-ratelimit-reset 333)(x-ratelimit-used 1)(x-ua-compatible IE=edge)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"kind\": \"Listing\", \"data\": {\"modhash\": null, \"dist\": null, \"children\": [{\"date\": 1508279509.0, \"rel_id\": \"rb_rktlv8\", \"name\": \"BJO_test_user\", \"id\": \"t2_xw1ym\"}, {\"date\": 1465092742.0, \"rel_id\": \"rb_g6xsft\", \"name\": \"BJO_test_mod\", \"id\": \"t2_xw27h\"}], \"after\": null, \"before\": null}}")))
