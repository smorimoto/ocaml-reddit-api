open! Core
open! Async

type 'a call =
  ?param_list_override:((string * string sexp_list) sexp_list
                        -> (string * string sexp_list) sexp_list)
  -> Connection.t
  -> 'a Deferred.t

let call_api ?(param_list_override = Fn.id) connection ~endpoint ~http_verb ~params =
  let params = param_list_override params in
  let uri = sprintf "https://oauth.reddit.com%s" endpoint |> Uri.of_string in
  match http_verb with
  | `GET ->
    let uri = Uri.add_query_params uri params in
    Connection.get connection uri
  | `POST -> Connection.post_form connection uri ~params
;;

let get = call_api ~http_verb:`GET
let post = call_api ~http_verb:`POST

module Param_dsl = struct
  type t = (string * string list) list

  let required f key values : t = [ key, List.map values ~f ]
  let required' f key value : t = [ key, [ f value ] ]

  let optional f key values_opt : t =
    Option.to_list values_opt |> List.bind ~f:(required f key)
  ;;

  let optional' f key value_opt : t =
    Option.to_list value_opt |> List.bind ~f:(required' f key)
  ;;

  let include_optional f value_opt : t = Option.to_list value_opt |> List.bind ~f
  let _ = optional
  let combine = List.join
  let bool = Bool.to_string
  let string = Fn.id
  let int = Int.to_string
  let fullname_ = Fullname.to_string
  let username_ = Username.to_string
  let json = Yojson.Safe.to_string
  let time = Time.to_string_iso8601_basic ~zone:Time.Zone.utc
end

let optional_subreddit_endpoint ?subreddit suffix =
  let subreddit_part =
    Option.value_map subreddit ~default:"" ~f:(sprintf !"/r/%{Subreddit_name}")
  in
  sprintf !"%s%s" subreddit_part suffix
;;

let simple_post_fullnames_as_id endpoint ~fullnames =
  let endpoint = sprintf "/api/%s" endpoint in
  post ~endpoint ~params:Param_dsl.(required fullname_ "id" fullnames)
;;

let simple_post_fullname_as_id ~fullname =
  simple_post_fullnames_as_id ~fullnames:[ fullname ]
;;

let simple_toggle verb =
  simple_post_fullnames_as_id verb, simple_post_fullnames_as_id ("un" ^ verb)
;;

let simple_toggle' verb =
  simple_post_fullname_as_id verb, simple_post_fullname_as_id ("un" ^ verb)
;;

module Listing_params = struct
  module Pagination = struct
    module Before_or_after = struct
      type t =
        | Before
        | After
      [@@deriving sexp]
    end

    type t =
      { before_or_after : Before_or_after.t
      ; index : Fullname.t
      ; count : int
      }
    [@@deriving sexp]

    let params_of_t { before_or_after; index; count } =
      [ ( (match before_or_after with
          | Before -> "before"
          | After -> "after")
        , [ Fullname.to_string index ] )
      ; "count", [ Int.to_string count ]
      ]
    ;;
  end

  type t =
    { pagination : Pagination.t option
    ; limit : int option
    ; show_all : bool
    }
  [@@deriving sexp]

  let params_of_t { pagination; limit; show_all } =
    let open Param_dsl in
    combine
      [ include_optional Pagination.params_of_t pagination
      ; optional' int "limit" limit
      ; optional' string "show" (Option.some_if show_all "all")
      ]
  ;;
end

let api_type : Param_dsl.t = [ "api_type", [ "json" ] ]
let me = get ~endpoint:"/api/v1/me" ~params:[]
let karma = get ~endpoint:"/api/v1/me/karma" ~params:[]
let trophies = get ~endpoint:"/api/v1/me/trophies" ~params:[]
let needs_captcha = get ~endpoint:"/api/v1/me/needs_captcha" ~params:[]

let prefs which ?listing_params ~subreddit_detail ~include_categories =
  let endpoint = sprintf "/api/%s" which in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' bool "include_categories" include_categories
      ]
  in
  post ~endpoint ~params
;;

let friends = prefs "friends"
let blocked = prefs "blocked"
let messaging = prefs "messaging"
let trusted = prefs "trusted"

let add_comment ?return_rtjson ?richtext_json ~parent ~text =
  let endpoint = "/api/comment" in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; required' fullname_ "thing_id" parent
      ; required' string "text" text
      ; optional' bool "return_rtjson" return_rtjson
      ; optional' json "richtext_json" richtext_json
      ]
  in
  post ~endpoint ~params
;;

let delete ~fullname =
  let endpoint = "/api/comment" in
  let params =
    let open Param_dsl in
    Param_dsl.combine [ required' fullname_ "id" fullname ]
  in
  post ~endpoint ~params
;;

let edit ?return_rtjson ?richtext_json ~fullname ~text =
  let endpoint = "/api/editusertext" in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; required' fullname_ "thing_id" fullname
      ; required' string "text" text
      ; optional' bool "return_rtjson" return_rtjson
      ; optional' json "richtext_json" richtext_json
      ]
  in
  post ~endpoint ~params
;;

let follow ~submission ~follow =
  let endpoint = "/api/follow_post" in
  let params =
    let open Param_dsl in
    combine [ required' fullname_ "fullname" submission; required' bool "follow" follow ]
  in
  post ~endpoint ~params
;;

let hide, unhide =
  let hide', unhide' = simple_toggle "hide" in
  ( (fun ~submissions -> hide' ~fullnames:submissions)
  , fun ~submissions -> unhide' ~fullnames:submissions )
;;

module Info_query = struct
  type t =
    | Id of Fullname.t list
    | Url of Uri_sexp.t
  [@@deriving sexp]

  let params_of_t t =
    match t with
    | Id fullnames -> [ "id", List.map fullnames ~f:Fullname.to_string ]
    | Url uri -> [ "url", [ Uri.to_string uri ] ]
  ;;
end

let info ?subreddit query =
  let endpoint = optional_subreddit_endpoint ?subreddit "/api/info" in
  let params = Info_query.params_of_t query in
  get ~endpoint ~params
;;

let lock, unlock = simple_toggle' "lock"
let mark_nsfw, unmark_nsfw = simple_toggle' "marknsfw"

module Comment_sort = struct
  type t =
    | Confidence
    | Top
    | New
    | Controversial
    | Old
    | Random
    | Q_and_a
    | Live
  [@@deriving sexp]

  let to_string t =
    match t with
    | Q_and_a -> "qa"
    | _ -> sexp_of_t t |> Sexp.to_string |> String.lowercase
  ;;
end

(* TODO: mutex *)
let more_children ?id ?limit_children ~submission ~children ~sort =
  let endpoint = "/api/morechildren" in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; required Id36.Comment.to_string "children" children
      ; required' fullname_ "link_id" submission
      ; optional' Id36.More_children.to_string "id" id
      ; optional' bool "limit_children" limit_children
      ; required' Comment_sort.to_string "sort" sort
      ]
  in
  get ~endpoint ~params
;;

module Report_target = struct
  type t =
    | Modmail_conversation of Id36.Modmail_conversation.t
    | Fullname of Fullname.t
  [@@deriving sexp]

  let params_of_t t =
    match t with
    | Modmail_conversation id ->
      [ "modmail_conv_id", [ Id36.Modmail_conversation.to_string id ] ]
    | Fullname fullname -> [ "thing_id", [ Fullname.to_string fullname ] ]
  ;;
end

let report
    ?from_modmail
    ?from_help_desk
    ?additional_info
    ?custom_text
    ?other_reason
    ?rule_reason
    ?site_reason
    ?sr_name
    ~target
    ~reason
  =
  let endpoint = "/api/report" in
  let params =
    let open Param_dsl in
    combine
      [ Report_target.params_of_t target
      ; api_type
      ; required' string "reason" reason
      ; optional' string "additional_info" additional_info
      ; optional' string "custom_text" custom_text
      ; optional' string "other_reason" other_reason
      ; optional' string "rule_reason" rule_reason
      ; optional' string "site_reason" site_reason
      ; optional' string "sr_name" sr_name
      ; optional' bool "from_modmail" from_modmail
      ; optional' bool "from_help_desk" from_help_desk
      ]
  in
  post ~endpoint ~params
;;

let report_award ~award_id =
  let endpoint = "/api/report_award" in
  let params = [ "award_id", [ award_id ] ] in
  post ~endpoint ~params
;;

let save ?category ~fullname =
  let endpoint = "/api/save" in
  let params =
    let open Param_dsl in
    combine [ required' fullname_ "id" fullname; optional' string "category" category ]
  in
  post ~endpoint ~params
;;

let unsave ~fullname =
  let endpoint = "/api/save" in
  let params = [ "id", [ Fullname.to_string fullname ] ] in
  post ~endpoint ~params
;;

let saved_categories = get ~endpoint:"/api/saved_categories" ~params:[]

let send_replies ~fullname ~enabled =
  let endpoint = "/api/sendreplies" in
  let params =
    let open Param_dsl in
    combine [ required' fullname_ "id" fullname; required' bool "state" enabled ]
  in
  post ~endpoint ~params
;;

let set_contest_mode ~fullname ~enabled =
  let endpoint = "/api/set_contest_mode" in
  let params =
    let open Param_dsl in
    combine
      [ api_type; required' fullname_ "id" fullname; required' bool "state" enabled ]
  in
  post ~endpoint ~params
;;

module Sticky_state = struct
  type t =
    | Sticky of { slot : int }
    | Unsticky
  [@@deriving sexp]

  let params_of_t t =
    match t with
    | Sticky { slot } ->
      [ "state", [ Bool.to_string true ]; "num", [ Int.to_string slot ] ]
    | Unsticky -> [ "state", [ Bool.to_string false ] ]
  ;;
end

let set_subreddit_sticky ?to_profile ~fullname ~sticky_state =
  let endpoint = "/api/set_subreddit_sticky" in
  let params =
    let open Param_dsl in
    combine
      [ Sticky_state.params_of_t sticky_state
      ; api_type
      ; required' fullname_ "id" fullname
      ; optional' bool "to_profile" to_profile
      ]
  in
  post ~endpoint ~params
;;

let set_suggested_sort ~fullname ~sort =
  let endpoint = "/api/set_suggested_sort" in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; required' fullname_ "id" fullname
      ; required'
          string
          "sort"
          (Option.value_map sort ~f:Comment_sort.to_string ~default:"blank")
      ]
  in
  post ~endpoint ~params
;;

let spoiler, unspoiler = simple_toggle' "spoiler"

let store_visits ~submissions =
  let endpoint = "/api/store_visits" in
  let params =
    let open Param_dsl in
    combine [ required Fullname.to_string "links" submissions ]
  in
  post ~endpoint ~params
;;

module Submission_kind = struct
  module Self_post_body = struct
    type t =
      | Markdown of string
      | Richtext_json of Json_derivers.Yojson.t
    [@@deriving sexp]
  end

  type t =
    | Link of { url : string }
    | Self of Self_post_body.t
    | Image
    | Video
    | Videogif
  [@@deriving sexp]

  let params_of_t t =
    match t with
    | Link { url } -> [ "kind", [ "link" ]; "url", [ url ] ]
    | Self body ->
      [ "kind", [ "link" ]
      ; ( "text"
        , [ (match body with
            | Markdown markdown -> markdown
            | Richtext_json json -> Yojson.Safe.to_string json)
          ] )
      ]
    (* TODO Should we disallow these? *)
    | Image | Video | Videogif -> assert false
  ;;
end

let submit
    ?ad
    ?nsfw
    ?resubmit
    ?sendreplies
    ?spoiler
    ?flair_id
    ?flair_text
    ?collection_id
    ?event_start
    ?event_end
    ?event_tz
    ~subreddit
    ~title
    ~kind
  =
  let endpoint = "/api/store_visits" in
  let params =
    let open Param_dsl in
    combine
      [ Submission_kind.params_of_t kind
      ; api_type
      ; required' Subreddit_name.to_string "sr" subreddit
      ; required' string "title" title
      ; optional' bool "ad" ad
      ; optional' bool "nsfw" nsfw
      ; optional' bool "resubmit" resubmit
      ; optional' bool "sendreplies" sendreplies
      ; optional' bool "spoiler" spoiler
      ; (* TODO Do these have to go together? *)
        optional' string "flair_id" flair_id
      ; optional' string "flair_text" flair_text
      ; optional' string "collection_id" collection_id
      ; optional' time "event_start" event_start
      ; optional' time "event_end" event_end
      ; optional' string "event_tz" event_tz
      ]
  in
  post ~endpoint ~params
;;

module Vote_direction = struct
  type t =
    | Up
    | Neutral
    | Down
  [@@deriving sexp]

  let int_of_t t =
    match t with
    | Up -> 1
    | Neutral -> 0
    | Down -> -1
  ;;

  let params_of_t t = [ "dir", [ int_of_t t |> Int.to_string ] ]
end

let vote ?rank ~direction ~fullname =
  let endpoint = "/api/vote" in
  let params =
    let open Param_dsl in
    combine
      [ Vote_direction.params_of_t direction
      ; required' fullname_ "fullname" fullname
      ; optional' int "rank" rank
      ]
  in
  post ~endpoint ~params
;;

let trending_subreddits = get ~endpoint:"/api/trending_subreddits" ~params:[]

let best ?include_categories ?listing_params ?subreddit_detail =
  let endpoint = "/best" in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "include_categories" include_categories
      ; optional' bool "sr_detail" subreddit_detail
      ]
  in
  get ~endpoint ~params
;;

let by_id ~fullnames =
  let endpoint =
    List.map fullnames ~f:Fullname.to_string
    |> String.concat ~sep:","
    |> sprintf "/by_id/%s"
  in
  get ~endpoint ~params:[]
;;

let comments
    ?subreddit
    ?comment
    ?context
    ?depth
    ?limit
    ?showedits
    ?showmore
    ?sort
    ?subreddit_detail
    ?threaded
    ?truncate
    ~submission
  =
  let endpoint =
    optional_subreddit_endpoint ?subreddit (Id36.Submission.to_string submission)
  in
  let params =
    let open Param_dsl in
    combine
      [ optional' Id36.Comment.to_string "comment" comment
      ; optional' int "context" context
      ; optional' int "depth" depth
      ; optional' int "limit" limit
      ; optional' bool "showedits" showedits
      ; optional' bool "showmore" showmore
      ; optional' Comment_sort.to_string "sort" sort
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' bool "threaded" threaded
      ; optional' int "truncate" truncate
      ]
  in
  get ~endpoint ~params
;;

module Duplicate_sort = struct
  type t =
    | Number_of_comments
    | New

  let params_of_t t =
    [ ( "sort"
      , match t with
        | Number_of_comments -> [ "number_of_comments" ]
        | New -> [ "new" ] )
    ]
  ;;
end

let duplicates ?crossposts_only ?listing_params ?subreddit_detail ?sort ~submission_id =
  let endpoint = sprintf !"/duplicates/%{Id36.Submission}" submission_id in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "crossposts_only" crossposts_only
      ; optional' bool "sr_detail" subreddit_detail
      ; include_optional Duplicate_sort.params_of_t sort
      ]
  in
  get ~endpoint ~params
;;

module Historical_span = struct
  module T = struct
    type t =
      | Hour
      | Day
      | Week
      | Month
      | Year
      | All
    [@@deriving sexp]
  end

  include T
  include Sexpable.To_stringable (T)

  let params_of_t t = [ "t", [ to_string t |> String.lowercase ] ]
end

let basic_post_listing
    endpoint_part
    ?include_categories
    ?listing_params
    ?subreddit_detail
    ?subreddit
    ~extra_params
  =
  let endpoint = optional_subreddit_endpoint ?subreddit endpoint_part in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "include_categories" include_categories
      ; optional' bool "sr_detail" subreddit_detail
      ; extra_params
      ]
  in
  get ~endpoint ~params
;;

let hot ?location =
  let extra_params =
    let open Param_dsl in
    optional' string "location" location
  in
  basic_post_listing "hot" ~extra_params
;;

let new_ = basic_post_listing "new" ~extra_params:[]
let rising = basic_post_listing "rising" ~extra_params:[]

let top ?since =
  let extra_params = Param_dsl.include_optional Historical_span.params_of_t since in
  basic_post_listing "top" ~extra_params
;;

let controversial ?since =
  let extra_params = Param_dsl.include_optional Historical_span.params_of_t since in
  basic_post_listing "controversial" ~extra_params
;;

let random ?subreddit =
  let endpoint = optional_subreddit_endpoint ?subreddit "/random" in
  get ~endpoint ~params:[]
;;

let block = simple_post_fullname_as_id "block"
let collapse_message, uncollapse_message = simple_toggle "collapse_message"

let compose ?g_recaptcha_response ?from_subreddit ~to_ ~subject ~text =
  let endpoint = "/api/compose" in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; optional' string "g-recaptcha-response" g_recaptcha_response
      ; optional' Subreddit_name.to_string "from_sr" from_subreddit
      ; required' username_ "to" to_
      ; required' string "subject" subject
      ; required' string "text" text
      ]
  in
  post ~endpoint ~params
;;

let delete_message = simple_post_fullname_as_id "del_msg"
let read_message, unread_message = simple_toggle "read_message"
let unblock_subreddit = simple_post_fullnames_as_id "unblock_subreddit"

let message_listing
    endpoint
    ?include_categories
    ?listing_params
    ?mid
    ?subreddit_detail
    ~mark_read
  =
  let endpoint = "/message/" ^ endpoint in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "include_categories" include_categories
      ; optional' string "mid" mid
      ; optional' bool "sr_detail" subreddit_detail
      ; required bool "mark" mark_read
      ]
  in
  get ~endpoint ~params
;;

let inbox = message_listing "inbox"
let unread = message_listing "unread"
let sent = message_listing "sent"

module Mod_filter = struct
  type t =
    | Moderators of Username.t list
    | Admin

  let params_of_t t =
    [ ( "mod"
      , match t with
        | Admin -> [ "a" ]
        | Moderators moderators -> List.map moderators ~f:Username.to_string )
    ]
  ;;
end

let log ?listing_params ?mod_filter ?subreddit_detail ?subreddit ?type_ =
  let endpoint = optional_subreddit_endpoint ?subreddit "/about/log" in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; include_optional Mod_filter.params_of_t mod_filter
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' string "type" type_
      ]
  in
  get ~endpoint ~params
;;

module Links_or_comments = struct
  type t =
    | Links
    | Comments

  let params_of_t t =
    [ ( "only"
      , match t with
        | Links -> [ "links" ]
        | Comments -> [ "comments" ] )
    ]
  ;;
end

let mod_listing ?listing_params ?location ?only ?subreddit ?subreddit_detail ~endpoint =
  let endpoint = optional_subreddit_endpoint ?subreddit endpoint in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; include_optional Links_or_comments.params_of_t only
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' string "location" location
      ]
  in
  get ~endpoint ~params
;;

let reports = mod_listing ~endpoint:"reports"
let spam = mod_listing ~endpoint:"spam"
let modqueue = mod_listing ~endpoint:"modqueue"
let unmoderated = mod_listing ~endpoint:"unmoderated"
let edited = mod_listing ~endpoint:"edited"

let accept_moderator_invite ~subreddit =
  let endpoint = sprintf !"/%{Subreddit_name}/api/accept_moderator_invite" subreddit in
  post ~endpoint ~params:api_type
;;

let approve = simple_post_fullname_as_id "approve"
let remove = simple_post_fullname_as_id "remove"

module How_to_distinguish = struct
  type t =
    | Mod
    | Admin
    | Special
    | Undistinguish

  let params_of_t t =
    [ ( "how"
      , [ (match t with
          | Mod -> "yes"
          | Admin -> "admin"
          | Special -> "special"
          | Undistinguish -> "no")
        ] )
    ]
  ;;
end

let distinguish ?sticky ~fullname ~how =
  let endpoint = "/api/distinguish" in
  let params =
    let open Param_dsl in
    combine
      [ How_to_distinguish.params_of_t how
      ; required' fullname_ "id" fullname
      ; optional' bool "sticky" sticky
      ]
  in
  post ~endpoint ~params
;;

let ignore_reports, unignore_reports = simple_toggle' "ignore_reports"
let leavecontributor = simple_post_fullname_as_id "leavecontributor"
let leavemoderator = simple_post_fullname_as_id "leavemoderator"
let mute_message_author, unmute_message_author = simple_toggle' "mute_message_author"

let stylesheet ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/stylesheet" subreddit in
  get ~endpoint ~params:[]
;;

module Search_sort = struct
  type t =
    | Relevance
    | Hot
    | Top
    | New
    | Comments

  let params_of_t t =
    [ ( "sort"
      , [ (match t with
          | Relevance -> "relevance"
          | Hot -> "hot"
          | Top -> "top"
          | New -> "new"
          | Comments -> "comments")
        ] )
    ]
  ;;
end

module Search_type = struct
  module T = struct
    type t =
      | Subreddit
      | Submission
      | User
    [@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)

  let to_string t =
    match t with
    | Subreddit -> "sr"
    | Submission -> "link"
    | User -> "user"
  ;;
end

let search
    ?category
    ?include_facets
    ?listing_params
    ?restrict_to_subreddit
    ?since
    ?sort
    ?subreddit_detail
    ?types
    ~query
  =
  let subreddit_part, restrict_param =
    match restrict_to_subreddit with
    | None -> "", []
    | Some subreddit ->
      sprintf !"/r/%{Subreddit_name}" subreddit, [ "restrict_sr", [ "true" ] ]
  in
  let endpoint = sprintf !"%s/search" subreddit_part in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' string "category" category
      ; optional' bool "include_facets" include_facets
      ; required' string "q" query
      ; include_optional Historical_span.params_of_t since
      ; include_optional Search_sort.params_of_t sort
      ; optional' bool "sr_detail" subreddit_detail
      ; optional
          Search_type.to_string
          "type"
          (Option.map types ~f:Search_type.Set.to_list)
      ; restrict_param
      ]
  in
  get ~endpoint ~params
;;

let about_endpoint
    endpoint
    ?include_categories
    ?listing_params
    ?subreddit_detail
    ?user
    ~subreddit
  =
  let endpoint = sprintf !"/r/%{Subreddit_name}/about/%s" subreddit endpoint in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "include_categories" include_categories
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' username_ "user" user
      ]
  in
  get ~endpoint ~params
;;

let banned = about_endpoint "banned"
let muted = about_endpoint "muted"
let wiki_banned = about_endpoint "wikibanned"
let contributors = about_endpoint "contributors"
let wiki_contributors = about_endpoint "wikicontributors"
let moderators = about_endpoint "moderators"

let removal_endpoints ?(extra_params = []) ~subreddit endpoint =
  let endpoint = sprintf !"%{Subreddit_name}/api/%s" subreddit endpoint in
  post ~endpoint ~params:(Param_dsl.combine [ api_type; extra_params ])
;;

let delete_subreddit_banner = removal_endpoints "delete_sr_banner"
let delete_subreddit_header = removal_endpoints "delete_sr_header"
let delete_subreddit_icon = removal_endpoints "delete_sr_icon"

let delete_subreddit_image ~image_name =
  let extra_params = Param_dsl.(required' string "img_name" image_name) in
  removal_endpoints "delete_sr_img" ~extra_params
;;

let recommended ?over_18 ~subreddits =
  let endpoint =
    List.map subreddits ~f:Subreddit_name.to_string
    |> String.concat ~sep:","
    |> sprintf "/api/recommend/sr/%s"
  in
  let params = Param_dsl.(optional' bool "over_18" over_18) in
  get ~endpoint ~params
;;

let search_subreddit_names ?exact ?include_over_18 ?include_unadvertisable ~query =
  let endpoint = "/api/search_reddit_names" in
  let params =
    let open Param_dsl in
    combine
      [ required' string "query" query
      ; optional' bool "exact" exact
      ; optional' bool "include_over_18" include_over_18
      ; optional' bool "include_unadvertisable" include_unadvertisable
      ]
  in
  get ~endpoint ~params
;;

module Link_type = struct
  type t =
    | Any
    | Link
    | Self

  let params_of_t t =
    [ ( "link_type"
      , [ (match t with
          | Any -> "any"
          | Link -> "link"
          | Self -> "self")
        ] )
    ]
  ;;
end

module Spam_level = struct
  type t =
    | Low
    | High
    | All

  let to_string t =
    match t with
    | Low -> "low"
    | High -> "high"
    | All -> "all"
  ;;
end

module Subreddit_type = struct
  type t =
    | Gold_restricted
    | Archived
    | Restricted
    | Employees_only
    | Gold_only
    | Private
    | User
    | Public

  let to_string t =
    match t with
    | Gold_restricted -> "gold_restricted"
    | Archived -> "archived"
    | Restricted -> "restricted"
    | Employees_only -> "employees_only"
    | Gold_only -> "gold_only"
    | Private -> "private"
    | User -> "user"
    | Public -> "public"
  ;;
end

module Wiki_mode = struct
  type t =
    | Disabled
    | Mod_only
    | Anyone

  let to_string t =
    match t with
    | Disabled -> "disabled"
    | Mod_only -> "modonly"
    | Anyone -> "anyone"
  ;;
end

let create_or_edit_subreddit
    ?comment_score_hide_mins
    ?wiki_edit_age
    ?wiki_edit_karma
    ~all_original_content
    ~allow_discovery
    ~allow_images
    ~allow_post_crossposts
    ~allow_top
    ~allow_videos
    ~api_type
    ~collapse_deleted_comments
    ~crowd_control_mode
    ~description
    ~disable_contributor_requests
    ~exclude_banned_modqueue
    ~free_form_reports
    ~g_recaptcha_response
    ~header_title
    ~hide_ads
    ~key_color
    ~lang
    ~link_type
    ~name
    ~original_content_tag_enabled
    ~over_18
    ~public_description
    ~restrict_commenting
    ~restrict_posting
    ~show_media
    ~show_media_preview
    ~spam_comments
    ~spam_links
    ~spam_selfposts
    ~spoilers_enabled
    ~subreddit
    ~submit_link_label
    ~submit_text
    ~submit_text_label
    ~suggested_comment_sort
    ~title
    ~type_
    ~wiki_mode
  =
  let endpoint = "/api/site_admin" in
  let params =
    let open Param_dsl in
    combine
      [ optional' int "comment_score_hide_mins" comment_score_hide_mins
      ; optional' int "wiki_edit_age" wiki_edit_age
      ; optional' int "wiki_edit_karma" wiki_edit_karma
      ; required' bool "all_original_content" all_original_content
      ; required' bool "allow_discovery" allow_discovery
      ; required' bool "allow_images" allow_images
      ; required' bool "allow_post_crossposts" allow_post_crossposts
      ; required' bool "allow_top" allow_top
      ; required' bool "allow_videos" allow_videos
      ; api_type
      ; required' bool "collapse_deleted_comments" collapse_deleted_comments
      ; required' bool "crowd_control_mode" crowd_control_mode
      ; required' string "description" description
      ; required' bool "disable_contributor_requests" disable_contributor_requests
      ; required' bool "exclude_banned_modqueue" exclude_banned_modqueue
      ; required' bool "free_form_reports" free_form_reports
      ; optional' string "g_recaptcha_response" g_recaptcha_response
      ; required' string "header_title" header_title
      ; required' bool "hide_ads" hide_ads
      ; required' string "key_color" key_color
      ; required' string "lang" lang
      ; Link_type.params_of_t link_type
      ; required' string "name" name
      ; required' bool "original_content_tag_enabled" original_content_tag_enabled
      ; required' bool "over_18" over_18
      ; required' string "public_description" public_description
      ; required' bool "restrict_commenting" restrict_commenting
      ; required' bool "restrict_posting" restrict_posting
      ; required' bool "show_media" show_media
      ; required' bool "show_media_preview" show_media_preview
      ; required' Spam_level.to_string "spam_comments" spam_comments
      ; required' Spam_level.to_string "spam_links" spam_links
      ; required' Spam_level.to_string "spam_selfposts" spam_selfposts
      ; required' bool "spoilers_enabled" spoilers_enabled
      ; required' Subreddit_name.to_string "sr" subreddit
      ; required' string "submit_link_label" submit_link_label
      ; required' string "submit_text" submit_text
      ; required' string "submit_text_label" submit_text_label
      ; required' Comment_sort.to_string "suggested_comment_sort" suggested_comment_sort
      ; required' string "title" title
      ; required' Subreddit_type.to_string "type_" type_
      ; required' Wiki_mode.to_string "wikimode" wiki_mode
      ]
  in
  post ~endpoint ~params
;;

let submit_text ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/api/submit_text" subreddit in
  get ~endpoint ~params:[]
;;

let subreddit_autocomplete ?include_over_18 ?include_profiles ~query =
  let endpoint = "/api/subreddit_autocomplete" in
  let params =
    let open Param_dsl in
    combine
      [ optional' bool "include_over_18" include_over_18
      ; optional' bool "include_profiles" include_profiles
      ; required' string "query" query
      ]
  in
  get ~endpoint ~params
;;

let subreddit_autocomplete_v2
    ?limit
    ?include_categories
    ?include_over_18
    ?include_profiles
    ~query
  =
  let endpoint = "/api/subreddit_autocomplete_v2" in
  let params =
    let open Param_dsl in
    combine
      [ optional' int "limit" limit
      ; optional' bool "include_categories" include_categories
      ; optional' bool "include_over_18" include_over_18
      ; optional' bool "include_profiles" include_profiles
      ; required' string "query" query
      ]
  in
  get ~endpoint ~params
;;

module Stylesheet_operation = struct
  type t =
    | Save
    | Preview
  [@@deriving sexp]

  let to_string t =
    match t with
    | Save -> "save"
    | Preview -> "preview"
  ;;
end

let subreddit_stylesheet ?reason ~operation ~stylesheet_contents ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/api/subreddit_stylesheet" subreddit in
  let params =
    let open Param_dsl in
    combine
      [ api_type
      ; optional' string "reason" reason
      ; required' Stylesheet_operation.to_string "op" operation
      ; required' string "stylesheet_contents" stylesheet_contents
      ]
  in
  post ~endpoint ~params
;;

module Subscription_action = struct
  type t =
    | Subscribe
    | Unsubscribe

  let to_string t =
    match t with
    | Subscribe -> "sub"
    | Unsubscribe -> "unsub"
  ;;
end

let subscribe ?skip_initial_defaults ~action =
  let endpoint = "/api/subscribe" in
  let params =
    let open Param_dsl in
    combine
      [ required' Subscription_action.to_string "action" action
      ; optional' bool "skip_initial_defaults" skip_initial_defaults
      ]
  in
  post ~endpoint ~params
;;

module Image_type = struct
  type t =
    | Png
    | Jpg

  let to_string t =
    match t with
    | Png -> "png"
    | Jpg -> "jpg"
  ;;
end

module Upload_type = struct
  type t =
    | Image
    | Header
    | Icon
    | Banner

  let to_string t =
    match t with
    | Image -> "img"
    | Header -> "header"
    | Icon -> "icon"
    | Banner -> "banner"
  ;;
end

let upload_sr_img ?form_id ~file ~header ~image_type ~name ~subreddit ~upload_type =
  let endpoint = sprintf !"/r/%{Subreddit_name}/api/upload_sr_img" subreddit in
  let params =
    let header = Bool.to_int header in
    let open Param_dsl in
    combine
      [ optional' string "formid" form_id
      ; required' string "file" file
      ; required' int "header" header
      ; required' Image_type.to_string "img_type" image_type
      ; required' string "name" name
      ; required' Upload_type.to_string "upload_type" upload_type
      ]
  in
  post ~endpoint ~params
;;

module Subreddit_search_sort = struct
  type t =
    | Relevance
    | Activity

  let to_string t =
    match t with
    | Relevance -> "relevance"
    | Activity -> "activity"
  ;;
end

let search_profiles ?listing_params ?subreddit_detail ?sort ~query =
  let endpoint = "/profiles/search" in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "sr_detail" subreddit_detail
      ; required' string "q" query
      ; optional' Subreddit_search_sort.to_string "sort" sort
      ]
  in
  get ~endpoint ~params
;;

let about ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/about" subreddit in
  get ~endpoint ~params:[]
;;

let subreddit_about ?(params = []) ~subreddit endpoint =
  let endpoint = sprintf !"/r/%{Subreddit_name}/about/%s" subreddit endpoint in
  get ~endpoint ~params
;;

let subreddit_settings ?created ?location =
  let params =
    let open Param_dsl in
    combine [ optional' bool "created" created; optional' string "location" location ]
  in
  subreddit_about ~params "edit"
;;

let subreddit_rules = subreddit_about "rules"
let subreddit_traffic = subreddit_about "traffic"
let subreddit_sidebar = subreddit_about "sidebar"

let sticky ?number ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/sticky" subreddit in
  let params =
    let open Param_dsl in
    combine [ optional' int "num" number ]
  in
  get ~endpoint ~params
;;

module Subreddit_relationship = struct
  type t =
    | Subscriber
    | Contributor
    | Moderator
    | Stream_subscriber

  let to_string t =
    match t with
    | Subscriber -> "subscriber"
    | Contributor -> "contributor"
    | Moderator -> "moderator"
    | Stream_subscriber -> "streams"
  ;;
end

let get_subreddits ?include_categories ?listing_params ?subreddit_detail ~relationship =
  let endpoint = sprintf !"/subreddits/mine/%{Subreddit_relationship}" relationship in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' string "sr_detail" subreddit_detail
      ; optional' bool "include_categories" include_categories
      ]
  in
  get ~endpoint ~params
;;

let search_subreddits ?listing_params ?show_users ?sort ?subreddit_detail ~query =
  let endpoint = "/subreddits/search" in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' bool "show_users" show_users
      ; required' string "q" query
      ; optional' Subreddit_search_sort.to_string "sort" sort
      ]
  in
  get ~endpoint ~params
;;

module Subreddit_listing_sort = struct
  type t =
    | Popular
    | New
    | Gold
    | Default

  let to_string t =
    match t with
    | Popular -> "popular"
    | New -> "new"
    | Gold -> "gold"
    | Default -> "default"
  ;;
end

let list_subreddits
    ?listing_params
    ?subreddit_detail
    ?include_categories
    ?show_users
    ~sort
  =
  let endpoint = sprintf !"/subreddits/%{Subreddit_listing_sort}" sort in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' bool "include_categories" include_categories
      ; optional' bool "show_users" show_users
      ]
  in
  get ~endpoint ~params
;;

module User_subreddit_sort = struct
  type t =
    | Popular
    | New

  let to_string t =
    match t with
    | Popular -> "popular"
    | New -> "new"
  ;;
end

let list_user_subreddits ?listing_params ?subreddit_detail ?include_categories ~sort =
  let endpoint = sprintf !"/users/%{User_subreddit_sort}" sort in
  let params =
    let open Param_dsl in
    combine
      [ include_optional Listing_params.params_of_t listing_params
      ; optional' bool "sr_detail" subreddit_detail
      ; optional' bool "include_categories" include_categories
      ]
  in
  get ~endpoint ~params
;;

module Relationship = struct
  module Duration = struct
    type t =
      | Permanent
      | Days of int
    [@@deriving sexp]

    let params_of_t t =
      [ ( "duration"
        , match t with
          | Permanent -> []
          | Days days -> [ Int.to_string days ] )
      ]
    ;;
  end

  type t =
    | Friend
    | Moderator
    | Moderator_invite
    | Contributor
    | Banned
    | Muted
    | Wiki_banned
    | Wiki_contributor
  [@@deriving sexp]

  let to_string t =
    match t with
    | Friend -> "friend"
    | Moderator -> "moderator"
    | Moderator_invite -> "moderator_invite"
    | Contributor -> "contributor"
    | Banned -> "banned"
    | Muted -> "muted"
    | Wiki_banned -> "wikibanned"
    | Wiki_contributor -> "wikicontributor"
  ;;

  let params_of_t t = [ "type", [ to_string t ] ]
end

let add_relationship
    ~relationship
    ~username
    ~subreddit
    ~duration
    ?note
    ?ban_reason
    ?ban_message
    ?ban_context
  =
  let endpoint = sprintf !"/r/%{Subreddit_name}/api/unfriend" subreddit in
  let params =
    Relationship.Duration.params_of_t duration
    @ Relationship.params_of_t relationship
    @
    let open Param_dsl in
    combine
      [ Relationship.Duration.params_of_t duration
      ; Relationship.params_of_t relationship
      ; api_type
      ; required' username_ "name" username
      ; optional' string "note" note
      ; optional' string "ban_reason" ban_reason
      ; optional' string "ban_message" ban_message
      ; optional' fullname_ "ban_context" ban_context
      ]
  in
  post ~endpoint ~params
;;

let remove_relationship ~relationship ~username ~subreddit =
  let endpoint = sprintf !"/r/%{Subreddit_name}/api/unfriend" subreddit in
  let params =
    let open Param_dsl in
    combine
      [ Relationship.params_of_t relationship
      ; api_type
      ; required' username_ "name" username
      ]
  in
  post ~endpoint ~params
;;
