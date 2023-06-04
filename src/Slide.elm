module Slide exposing (..)

import EventHelpers exposing (onDragOver, onDrop)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode exposing (Decoder)
import Json.Encode
import Note exposing (Note)
import Source exposing (Source)
import UUID exposing (UUID)


type alias Slide =
    { id : UUID
    , title : String
    , notes : List Note
    , sources : List Source
    , temporaryNewNote : String
    }


init : UUID -> String -> Slide
init id name =
    Slide id name [] [] ""


type alias Actions msg =
    { onDrop : Int -> msg
    , onDragOver : msg
    , onDragStart : Note -> msg
    , onDelete : String -> msg
    , onTemporaryNewNoteChange : String -> msg
    , onNewNote : msg
    }


kanbanView : Actions msg -> Bool -> Slide -> Html msg
kanbanView actions movingNote slide =
    Html.li
        [ Html.Attributes.class "flex-1 m-3 p-3"
        , Html.Events.onMouseUp <| actions.onDrop <| List.length slide.notes + 1
        ]
        [ Html.h2 [ Html.Attributes.class "m-0 p-0 text-base uppercase" ] [ Html.text slide.title ]
        , Html.ul [ Html.Attributes.class "my-3 mx-0" ] <|
            List.indexedMap
                (\index note ->
                    Html.li
                        [ Html.Attributes.class "group"
                        , Html.Events.onMouseUp <| actions.onDrop index
                        ]
                        [ Html.div
                            [ Html.Attributes.class "h-3 transition-all w-full"
                            , Html.Attributes.class <|
                                if movingNote then
                                    "group-hover:h-14"

                                else
                                    ""
                            ]
                            []
                        , Note.kanbanView
                            { onDragStart = actions.onDragStart
                            , onDelete = actions.onDelete
                            }
                            note
                        ]
                )
                slide.notes
                ++ [ Html.li []
                        [ Html.form [ Html.Events.onSubmit actions.onNewNote ]
                            [ Html.input
                                [ Html.Attributes.value slide.temporaryNewNote
                                , Html.Events.onInput actions.onTemporaryNewNoteChange
                                ]
                                []
                            ]
                        ]
                   ]
        ]


encode : Slide -> Json.Encode.Value
encode slide =
    Json.Encode.object
        [ ( "id", Json.Encode.string <| UUID.toString slide.id )
        , ( "title", Json.Encode.string slide.title )
        , ( "notes", Json.Encode.list Note.encode slide.notes )
        , ( "sources", Json.Encode.list Source.encode slide.sources )
        ]


decoder : Decoder Slide
decoder =
    Json.Decode.map5 Slide
        (Json.Decode.field "id" UUID.jsonDecoder)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "notes" <| Json.Decode.list Note.decoder)
        (Json.Decode.field "sources" <| Json.Decode.list Source.decoder)
        (Json.Decode.succeed "")
