module Data exposing (..)

import EventHelpers exposing (onDragStart)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode exposing (Decoder)
import Json.Encode
import Views exposing (enrichItemContent)


type DataType
    = Source


type alias Data =
    { title : String
    , slide : String
    , kind : DataType
    }


type alias Actions msg =
    { onDragStart : Data -> msg
    , onDelete : String -> msg
    }


kanbanView : Actions msg -> Data -> Html msg
kanbanView actions data =
    Html.li
        [ Html.Attributes.class "relative cursor-move rounded shadow bg-white p-4 pr-10 mb-3 text-sm"
        , Html.Attributes.attribute "draggable" "true"
        , onDragStart <| actions.onDragStart data
        , Html.Attributes.attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
        ]
        [ enrichItemContent data.title
        , Html.button
            [ Html.Attributes.class "block bg-red-700 text-white w-5 h-5 border-none rounded-xl absolute top-1/2 right-2.5 -translate-y-1/2 rotate-45 opacity-5 hover:opacity-100 cursor-pointer transition-opacity text-2xl leading-5"
            , Html.Attributes.style "font-family" "initial"
            , Html.Events.onClick <| actions.onDelete data.title
            ]
            [ Html.text "+" ]
        ]


encode : Data -> Json.Encode.Value
encode data =
    let
        encodeType : DataType -> Json.Encode.Value
        encodeType kind =
            case kind of
                Source ->
                    Json.Encode.string "source"
    in
    Json.Encode.object
        [ ( "title", Json.Encode.string data.title )
        , ( "slide", Json.Encode.string data.slide )
        , ( "kind", encodeType data.kind )
        ]


decoder : Decoder Data
decoder =
    let
        typeDecoder : Decoder DataType
        typeDecoder =
            Json.Decode.string
                |> Json.Decode.andThen
                    (\raw ->
                        case raw of
                            "source" ->
                                Json.Decode.succeed Source

                            unknownType ->
                                Json.Decode.fail <| "Data type " ++ unknownType ++ " is unknown"
                    )
    in
    Json.Decode.map3 Data
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "slide" Json.Decode.string)
        (Json.Decode.field "kind" typeDecoder)
