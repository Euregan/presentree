module EventHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Json.Decode as Decode


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    Html.Events.on "keydown" (Decode.map tagger Html.Events.keyCode)


onDragStart : msg -> Attribute msg
onDragStart message =
    Html.Events.on "dragstart" (Decode.succeed message)


onDragEnd : msg -> Attribute msg
onDragEnd message =
    Html.Events.on "dragend" (Decode.succeed message)


onDragOver : msg -> Attribute msg
onDragOver message =
    Html.Events.custom "dragover"
        (Decode.succeed { message = message, stopPropagation = False, preventDefault = True })


onDrop : msg -> Attribute msg
onDrop message =
    Html.Events.custom "drop"
        (Decode.succeed { message = message, stopPropagation = False, preventDefault = True })
