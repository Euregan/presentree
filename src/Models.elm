port module Models exposing (..)

import Browser.Navigation
import Data exposing (Data, DataType(..))
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Url


type alias Model =
    { dataInput : String
    , datas : List Data
    , movingData : Maybe Data
    }



-- PORTS


port setStorage : Value -> Cmd msg


encode : Model -> Value
encode model =
    Json.Encode.list Data.encode model.datas


save : Model -> Cmd msg
save model =
    setStorage <| encode model



-- INITIAL FUNCTION


type alias Flags =
    Json.Decode.Value


decoder : Decoder Model
decoder =
    Json.Decode.map3 Model
        (Json.Decode.succeed "")
        (Json.Decode.list Data.decoder)
        (Json.Decode.succeed Nothing)


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd msg )
init flags url key =
    case Json.Decode.decodeValue decoder flags of
        Ok model ->
            ( model, Cmd.none )

        Err _ ->
            ( Model "" [] Nothing, Cmd.none )



-- ADD TASK


addNewData : Model -> ( Model, Cmd msg )
addNewData model =
    let
        newModel =
            { model
                | datas = model.datas ++ [ Data.init model.dataInput ]
                , dataInput = ""
            }
    in
    ( newModel, save newModel )



-- CHANGE TASK STATUS


moveDataToStatus : Data -> String -> List Data -> List Data
moveDataToStatus dataToFind newDataStatus datas =
    List.map
        (\t ->
            if t.title == dataToFind.title then
                { t | slide = newDataStatus }

            else
                t
        )
        datas


moveData : Model -> String -> ( Model, Cmd msg )
moveData model targetStatus =
    let
        newDatas =
            case model.movingData of
                Just data ->
                    moveDataToStatus data targetStatus model.datas

                Nothing ->
                    model.datas

        newModel =
            { model | datas = newDatas, movingData = Nothing }
    in
    ( newModel, save newModel )



-- DELETE TASK


deleteData : Model -> String -> ( Model, Cmd msg )
deleteData model name =
    let
        newModel =
            { model | datas = List.filter (\x -> x.title /= name) model.datas }
    in
    ( newModel, save newModel )



-- GET TASKS BY STATUS


getOnGoingDatas : Model -> List Data
getOnGoingDatas model =
    List.filter (\t -> t.slide == "OnGoing") model.datas


getToDoDatas : Model -> List Data
getToDoDatas model =
    List.filter (\t -> t.slide == "Todo") model.datas


getDoneDatas : Model -> List Data
getDoneDatas model =
    List.filter (\t -> t.slide == "Done") model.datas
