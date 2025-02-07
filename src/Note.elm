module Note exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode exposing (Decoder)
import Json.Encode
import UUID exposing (UUID)
import Views exposing (enrichItemContent)


type alias Note =
    { id : UUID
    , content : String
    }


type alias Actions msg =
    { onDragStart : ( Float, Float ) -> msg
    , onDelete : String -> msg
    }


init : UUID -> String -> Note
init id content =
    Note
        id
        content


kanbanView : Actions msg -> Maybe ( Float, Float ) -> Note -> Html msg
kanbanView actions position note =
    let
        attributes =
            case position of
                Just ( x, y ) ->
                    [ Html.Attributes.class "absolute rotate-3"
                    , Html.Attributes.style "left" <| String.fromFloat x ++ "px"
                    , Html.Attributes.style "top" <| String.fromFloat y ++ "px"
                    ]

                Nothing ->
                    [ Html.Attributes.class "relative"
                    ]
    in
    Html.div
        ([ Html.Attributes.class "transition-transform cursor-move rounded shadow bg-white p-4 pr-10 text-sm w-64"
         , Html.Events.on
            "mousedown"
           <|
            Json.Decode.map2
                (\x y -> actions.onDragStart ( x, y ))
                (Json.Decode.field "clientX" Json.Decode.float)
                (Json.Decode.field "clientY" Json.Decode.float)
         ]
            ++ attributes
        )
        [ enrichItemContent note.content
        , Html.button
            [ Html.Attributes.class "block bg-red-700 text-white w-5 h-5 border-none rounded-xl absolute top-1/2 right-2.5 -translate-y-1/2 rotate-45 opacity-5 hover:opacity-100 cursor-pointer transition-opacity text-2xl leading-5"
            , Html.Attributes.style "font-family" "initial"
            , Html.Events.onClick <| actions.onDelete note.content
            ]
            [ Html.text "+" ]
        ]


encode : Note -> Json.Encode.Value
encode note =
    Json.Encode.object
        [ ( "id", Json.Encode.string <| UUID.toString note.id )
        , ( "content", Json.Encode.string note.content )
        ]


decoder : Decoder Note
decoder =
    Json.Decode.map2 Note
        (Json.Decode.field "id" UUID.jsonDecoder)
        (Json.Decode.field "content" Json.Decode.string)
