module Slide exposing (..)

import DragState exposing (DragState)
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
    , image : Maybe String
    , notes : List Note
    , sources : List Source
    , temporaryNewNote : String
    }


init : UUID -> String -> Slide
init id name =
    Slide id name Nothing [] [] ""


type alias Actions msg =
    { onDrop : Int -> msg
    , onDragStart : Note -> ( Float, Float ) -> msg
    , onDelete : String -> msg
    , onTemporaryNewNoteChange : String -> msg
    , onNewNote : msg
    }


kanbanView : Actions msg -> DragState -> Slide -> Html msg
kanbanView actions dragState slide =
    Html.li
        [ Html.Attributes.class "flex-1 m-3 p-3"
        , Html.Events.onMouseUp <| actions.onDrop <| List.length slide.notes + 1
        ]
        [ Html.h2 [ Html.Attributes.class "m-0 p-0 text-base uppercase" ] [ Html.text slide.title ]
        , case slide.image of
            Just image ->
                Html.img [ Html.Attributes.src image, Html.Attributes.class "w-64" ] []

            Nothing ->
                Html.text ""
        , Html.ul [ Html.Attributes.class "my-3 mx-0" ] <|
            List.indexedMap
                (\index note ->
                    let
                        position =
                            Maybe.andThen
                                (\state ->
                                    if state.dragging.id == note.id then
                                        Just state.position

                                    else
                                        Nothing
                                )
                                dragState
                    in
                    Html.li
                        [ Html.Attributes.class "group select-none"
                        , Html.Events.onMouseUp <| actions.onDrop index
                        ]
                        [ Html.div
                            [ Html.Attributes.class "h-3 transition-all w-full"
                            , Html.Attributes.class <|
                                if dragState /= Nothing then
                                    "group-hover:h-14"

                                else
                                    ""
                            ]
                            []
                        , Note.kanbanView
                            { onDragStart = actions.onDragStart note
                            , onDelete = actions.onDelete
                            }
                            position
                            note
                        ]
                )
                slide.notes
                ++ [ Html.li []
                        [ Html.form [ Html.Events.onSubmit actions.onNewNote ]
                            [ Html.input
                                [ Html.Attributes.value slide.temporaryNewNote
                                , Html.Events.onInput actions.onTemporaryNewNoteChange
                                , Html.Attributes.id <| UUID.toString slide.id
                                ]
                                []
                            ]
                        ]
                   ]
        ]


encode : Slide -> Json.Encode.Value
encode slide =
    let
        encodedImage =
            case slide.image of
                Just image ->
                    Json.Encode.string image

                Nothing ->
                    Json.Encode.null
    in
    Json.Encode.object
        [ ( "id", Json.Encode.string <| UUID.toString slide.id )
        , ( "title", Json.Encode.string slide.title )
        , ( "image", encodedImage )
        , ( "notes", Json.Encode.list Note.encode slide.notes )
        , ( "sources", Json.Encode.list Source.encode slide.sources )
        ]


decoder : Decoder Slide
decoder =
    Json.Decode.map6 Slide
        (Json.Decode.field "id" UUID.jsonDecoder)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "image" <| Json.Decode.nullable Json.Decode.string)
        (Json.Decode.field "notes" <| Json.Decode.list Note.decoder)
        (Json.Decode.field "sources" <| Json.Decode.list Source.decoder)
        (Json.Decode.succeed "")
