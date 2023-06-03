module Main exposing (..)

import Browser
import EventHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (Value)
import Message exposing (Msg(..))
import Models exposing (..)
import Slide
import Views exposing (..)


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown key ->
            if key == 13 then
                addNewData model

            else
                ( model, Cmd.none )

        TextInput content ->
            ( { model | dataInput = content }, Cmd.none )

        Move selectedData ->
            ( { model | movingData = Just selectedData }, Cmd.none )

        DragOver ->
            ( model, Cmd.none )

        DropData targetStatus ->
            moveData model targetStatus

        Delete content ->
            deleteData model content

        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        todos =
            getToDoDatas model

        ongoing =
            getOnGoingDatas model

        dones =
            getDoneDatas model

        actions =
            { onDrop = DropData
            , onDragOver = DragOver
            , onDragStart = Move
            , onDelete = Delete
            }
    in
    { title = "Presentree"
    , body =
        [ div [ class "w-full h-full flex flex-col bg-slate-100 dark" ]
            [ input
                [ type_ "text"
                , class "p-3 h-12 text-base border-none shadow-sm"
                , placeholder "What's on your mind right now?"
                , tabindex 0
                , onKeyDown KeyDown
                , onInput TextInput
                , value model.dataInput
                ]
                []
            , div [ class "flex flex-row flex-1" ]
                [ Slide.kanbanView actions "Todo" todos
                , Slide.kanbanView actions "OnGoing" ongoing
                , Slide.kanbanView actions "Done" dones
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
