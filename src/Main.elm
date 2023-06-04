module Main exposing (..)

import Browser
import EventHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (Value)
import Message exposing (Msg(..))
import Models exposing (..)
import Note
import Slide
import UUID
import Views exposing (..)


main : Program Flags Model Msg
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
        Move note ->
            ( model, Cmd.none )

        DragOver ->
            ( model, Cmd.none )

        DropNote targetSlide ->
            ( model, Cmd.none )

        Delete content ->
            ( model, Cmd.none )

        TemporaryNewSlideNameChanged name ->
            ( { model | newSlideName = name }, Cmd.none )

        NewSlide ->
            let
                ( id, newSeed ) =
                    UUID.step model.seed

                updatedModel =
                    { model
                        | newSlideName = ""
                        , slides = model.slides ++ [ Slide.init id model.newSlideName ]
                        , seed = newSeed
                    }
            in
            ( updatedModel
            , save updatedModel
            )

        TemporaryNewNoteChanged noteSlide newContent ->
            ( { model
                | slides =
                    List.map
                        (\slide ->
                            if noteSlide.id == slide.id then
                                { slide | temporaryNewNote = newContent }

                            else
                                slide
                        )
                        model.slides
              }
            , Cmd.none
            )

        NewNote noteSlide ->
            let
                ( id, newSeed ) =
                    UUID.step model.seed

                updatedModel =
                    { model
                        | slides =
                            List.map
                                (\slide ->
                                    if noteSlide.id == slide.id then
                                        { slide
                                            | temporaryNewNote = ""
                                            , notes = slide.notes ++ [ Note.init id slide.temporaryNewNote ]
                                        }

                                    else
                                        noteSlide
                                )
                                model.slides
                        , seed = newSeed
                    }
            in
            ( updatedModel, save updatedModel )

        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Presentree"
    , body =
        [ div [ class "w-full h-full flex flex-col bg-slate-100 dark" ]
            [ ul [ class "flex flex-row flex-1" ] <|
                List.map
                    (\slide ->
                        Slide.kanbanView
                            { onDrop = DropNote slide
                            , onDragOver = DragOver
                            , onDragStart = Move
                            , onDelete = Delete
                            , onTemporaryNewNoteChange = TemporaryNewNoteChanged slide
                            , onNewNote = NewNote slide
                            }
                            slide
                    )
                    model.slides
                    ++ [ Html.li []
                            [ Html.form
                                [ Html.Events.onSubmit NewSlide
                                ]
                                [ Html.input
                                    [ Html.Attributes.value model.newSlideName
                                    , Html.Events.onInput TemporaryNewSlideNameChanged
                                    ]
                                    []
                                ]
                            ]
                       ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
