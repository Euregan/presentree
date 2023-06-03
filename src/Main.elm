module Main exposing (..)

import Browser
import EventHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Views exposing (..)


main : Program (Maybe Model) Model Msg
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
                addNewTask model

            else
                ( model, Cmd.none )

        TextInput content ->
            ( { model | taskInput = content }, Cmd.none )

        Move selectedTask ->
            ( { model | movingTask = Just selectedTask }, Cmd.none )

        DragOver ->
            ( model, Cmd.none )

        DropTask targetStatus ->
            moveTask model targetStatus

        Delete content ->
            deleteTask model content

        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        todos =
            getToDoTasks model

        ongoing =
            getOnGoingTasks model

        dones =
            getDoneTasks model
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
                , value model.taskInput
                ]
                []
            , div [ class "flex flex-row flex-1" ]
                [ taskColumnView "Todo" todos
                , taskColumnView "OnGoing" ongoing
                , taskColumnView "Done" dones
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
