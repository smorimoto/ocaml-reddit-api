    ((request(Post_form(uri((scheme(https))(host(www.reddit.com))(path /api/v1/access_token)))(headers((authorization <AUTHORIZATION>)))(params((grant_type(password))(username(<USERNAME>))(password(<PASSWORD>))))))(response(((encoding(Fixed 114))(headers((accept-ranges bytes)(cache-control"max-age=0, must-revalidate")(connection keep-alive)(content-length 114)(content-type"application/json; charset=UTF-8")(date"Thu, 03 Sep 2020 12:19:57 GMT")(server snooserv)(set-cookie"edgebucket=e33wJC9YbqO6kQa2L4; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"access_token\": \"<ACCESS_TOKEN>\", \"token_type\": \"bearer\", \"expires_in\": 3600, \"scope\": \"*\"}")))((request(Get(uri((scheme(https))(host(oauth.reddit.com))(path /message/sent)(query((raw_json(1))(limit(2))(mark(true))))))(headers((authorization"bearer <ACCESS_TOKEN>")))))(response(((encoding(Fixed 1485))(headers((accept-ranges bytes)(cache-control"private, s-maxage=0, max-age=0, must-revalidate, no-store, max-age=0, must-revalidate")(connection keep-alive)(content-length 1485)(content-type"application/json; charset=UTF-8")(date"Thu, 03 Sep 2020 12:19:58 GMT")(expires -1)(server snooserv)(set-cookie"session_tracker=fqdraonbnnrljhbfha.0.1599135597858.Z0FBQUFBQmZVTjl1M1h6dDl0bnhLSEQwdTBNTVc1b19QZ0xMeW02RHZSSW55cW1nNUVVZi1WXzFoQnM5N0M1T1BxU2s2dFU2MC1kWXcwSFdaNFpmdld3S2MzQzNoal83UnNEeEdoVDMwSVZDdmVEbjI5VEVSemNraE1oU0FrSU52cncxakdNWXhjU2c; Domain=reddit.com; Max-Age=7199; Path=/; expires=Thu, 03-Sep-2020 14:19:58 GMT; secure; SameSite=None; Secure")(set-cookie"redesign_optout=true; Domain=reddit.com; Max-Age=94607999; Path=/; expires=Sun, 03-Sep-2023 12:19:57 GMT; secure")(set-cookie"csv=1; Max-Age=63072000; Domain=.reddit.com; Path=/; Secure; SameSite=None")(set-cookie"edgebucket=GtEIq4UvQ6Oe5FrP9X; Domain=reddit.com; Max-Age=63071999; Path=/;  secure")(strict-transport-security"max-age=15552000; includeSubDomains; preload")(vary accept-encoding)(via"1.1 varnish")(x-content-type-options nosniff)(x-frame-options SAMEORIGIN)(x-moose majestic)(x-ratelimit-remaining 598.0)(x-ratelimit-reset 3)(x-ratelimit-used 2)(x-ua-compatible IE=edge)(x-xss-protection"1; mode=block")))(version HTTP_1_1)(status OK)(flush false))"{\"kind\": \"Listing\", \"data\": {\"modhash\": null, \"dist\": 2, \"children\": [{\"kind\": \"t4\", \"data\": {\"first_message\": null, \"first_message_name\": null, \"subreddit\": null, \"likes\": null, \"replies\": \"\", \"id\": \"rdkr3p\", \"subject\": \"A self message\", \"associated_awarding_id\": null, \"score\": 0, \"author\": \"L72_Elite_Kraken\", \"num_comments\": null, \"parent_id\": null, \"subreddit_name_prefixed\": null, \"new\": false, \"type\": \"unknown\", \"body\": \"Weird!\", \"dest\": \"L72_Elite_Kraken\", \"body_html\": \"\\u003C!-- SC_OFF --\\u003E\\u003Cdiv class=\\\"md\\\"\\u003E\\u003Cp\\u003EWeird!\\u003C/p\\u003E\\n\\u003C/div\\u003E\\u003C!-- SC_ON --\\u003E\", \"was_comment\": false, \"name\": \"t4_rdkr3p\", \"created\": 1599163780.0, \"created_utc\": 1599134980.0, \"context\": \"\", \"distinguished\": null}}, {\"kind\": \"t4\", \"data\": {\"first_message\": null, \"first_message_name\": null, \"subreddit\": null, \"likes\": null, \"replies\": \"\", \"id\": \"rdk8sp\", \"subject\": \"This is a message\", \"associated_awarding_id\": null, \"score\": 0, \"author\": \"L72_Elite_Kraken\", \"num_comments\": null, \"parent_id\": null, \"subreddit_name_prefixed\": null, \"new\": false, \"type\": \"unknown\", \"body\": \"This is its body\", \"dest\": \"BJO_test_user\", \"body_html\": \"\\u003C!-- SC_OFF --\\u003E\\u003Cdiv class=\\\"md\\\"\\u003E\\u003Cp\\u003EThis is its body\\u003C/p\\u003E\\n\\u003C/div\\u003E\\u003C!-- SC_ON --\\u003E\", \"was_comment\": false, \"name\": \"t4_rdk8sp\", \"created\": 1599162285.0, \"created_utc\": 1599133485.0, \"context\": \"\", \"distinguished\": null}}], \"after\": \"t4_rdk8sp\", \"before\": null}}")))
