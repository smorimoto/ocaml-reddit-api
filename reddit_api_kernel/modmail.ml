open! Core_kernel

module Conversation = struct
  include Json_object.Utils

  module Id = struct
    include Id36

    include Identifiable.Make (struct
      include Id36

      let module_name = "Modmail.Conversation.Id"
    end)
  end

  let id =
    required_field "conversation" (fun json ->
        Json.find json [ "id" ] |> string |> Id.of_string)
  ;;
end
