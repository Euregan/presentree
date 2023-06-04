module Source exposing (..)

import Json.Decode exposing (Decoder)
import Json.Encode


type Metadata
    = Loading


type alias Source =
    { url : String
    , metadata : Metadata
    }


encode : Source -> Json.Encode.Value
encode source =
    let
        encodeMetadata : Metadata -> Json.Encode.Value
        encodeMetadata metadata =
            case metadata of
                Loading ->
                    Json.Encode.null
    in
    Json.Encode.object
        [ ( "url", Json.Encode.string source.url )
        , ( "metadata", encodeMetadata source.metadata )
        ]


decoder : Decoder Source
decoder =
    let
        metadataDecoder : Decoder Metadata
        metadataDecoder =
            Json.Decode.succeed Loading
    in
    Json.Decode.map2 Source
        (Json.Decode.field "url" Json.Decode.string)
        (Json.Decode.field "metadata" metadataDecoder)
