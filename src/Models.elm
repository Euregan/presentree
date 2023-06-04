port module Models exposing (..)

import Browser.Navigation
import DragState exposing (DragState)
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Random
import Slide exposing (Slide)
import UUID exposing (Seeds)
import Url


type alias Model =
    { dataInput : String
    , newSlideName : String
    , slides : List Slide
    , dragState : DragState
    , seed : Seeds
    }


port setStorage : Value -> Cmd msg


encode : Model -> Value
encode model =
    Json.Encode.list Slide.encode model.slides


save : Model -> Cmd msg
save model =
    setStorage <| encode model



-- INITIAL FUNCTION


type alias Flags =
    { model : Json.Decode.Value
    , seed : Int
    }


initialSeeds : Int -> Seeds
initialSeeds seed =
    Random.map4 Seeds
        (Random.int 0 3684687 |> Random.map Random.initialSeed)
        (Random.int 0 3487532 |> Random.map Random.initialSeed)
        (Random.int 0 63374 |> Random.map Random.initialSeed)
        (Random.int 0 65483 |> Random.map Random.initialSeed)
        |> (\generator -> Random.step generator (Random.initialSeed seed))
        |> Tuple.first


decoder : Int -> Decoder Model
decoder seed =
    Json.Decode.map5 Model
        (Json.Decode.succeed "")
        (Json.Decode.succeed "")
        (Json.Decode.list Slide.decoder)
        (Json.Decode.succeed Nothing)
        (Json.Decode.succeed <| initialSeeds seed)


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd msg )
init flags _ _ =
    case Json.Decode.decodeValue (decoder flags.seed) flags.model of
        Ok model ->
            ( model, Cmd.none )

        Err _ ->
            ( Model "" "" [] Nothing (initialSeeds flags.seed), Cmd.none )


port pastedImage : ({ slideId : String, image : String } -> msg) -> Sub msg
