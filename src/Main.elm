module Main exposing (..)

import Browser
import Browser.Events
import EventHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Kanban
import Message exposing (Msg(..))
import Mode exposing (Mode(..))
import Models exposing (..)
import Note
import Presentation
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
        Grab note position ->
            case model.mode of
                Kanban kanban ->
                    ( { model
                        | mode =
                            Kanban
                                { kanban
                                    | dragState =
                                        Just
                                            { dragging = note
                                            , position = position
                                            }
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        MouseMoved newPosition ->
            case model.mode of
                Kanban kanban ->
                    case kanban.dragState of
                        Just dragState ->
                            ( { model
                                | mode =
                                    Kanban
                                        { kanban
                                            | dragState =
                                                Just
                                                    { dragState
                                                        | position = newPosition
                                                    }
                                        }
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DropNote maybeTarget ->
            case model.mode of
                Kanban kanban ->
                    case ( maybeTarget, kanban.dragState ) of
                        ( Just ( targetSlide, targetIndex ), Just dragState ) ->
                            let
                                updatedModel =
                                    { model
                                        | mode =
                                            Kanban
                                                { kanban
                                                    | dragState = Nothing
                                                }
                                        , slides =
                                            model.slides
                                                |> List.map
                                                    (\slide ->
                                                        { slide
                                                            | notes =
                                                                List.filter
                                                                    (\note -> note.id /= dragState.dragging.id)
                                                                    slide.notes
                                                        }
                                                    )
                                                |> List.map
                                                    (\slide ->
                                                        if slide.id == targetSlide.id then
                                                            { slide
                                                                | notes =
                                                                    if targetIndex > List.length slide.notes then
                                                                        slide.notes ++ [ dragState.dragging ]

                                                                    else
                                                                        List.indexedMap
                                                                            (\index note ->
                                                                                if index == targetIndex then
                                                                                    [ dragState.dragging, note ]

                                                                                else
                                                                                    [ note ]
                                                                            )
                                                                            slide.notes
                                                                            |> List.concat
                                                            }

                                                        else
                                                            slide
                                                    )
                                    }
                            in
                            ( updatedModel, save updatedModel )

                        _ ->
                            ( { model | mode = Kanban { kanban | dragState = Nothing } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Delete _ ->
            ( model, Cmd.none )

        TemporaryNewSlideNameChanged name ->
            case model.mode of
                Kanban kanban ->
                    ( { model
                        | mode =
                            Kanban
                                { kanban | newSlideName = name }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        NewSlide ->
            case model.mode of
                Kanban kanban ->
                    let
                        ( id, newSeed ) =
                            UUID.step model.seed

                        updatedModel =
                            { model
                                | mode = Kanban { kanban | newSlideName = "" }
                                , slides = model.slides ++ [ Slide.init id kanban.newSlideName ]
                                , seed = newSeed
                            }
                    in
                    ( updatedModel
                    , save updatedModel
                    )

                _ ->
                    ( model, Cmd.none )

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
                                        slide
                                )
                                model.slides
                        , seed = newSeed
                    }
            in
            ( updatedModel, save updatedModel )

        PastedImage { slideId, image } ->
            let
                updatedModel =
                    { model
                        | slides =
                            List.map
                                (\slide ->
                                    if Ok slide.id == UUID.fromString slideId then
                                        { slide | image = Just image }

                                    else
                                        slide
                                )
                                model.slides
                    }
            in
            ( updatedModel, save updatedModel )

        SwitchMode mode ->
            ( { model | mode = mode }, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Presentree"
    , body =
        [ case model.mode of
            Kanban kanban ->
                Kanban.view
                    { onDrop = DropNote
                    , onDragStart = Grab
                    , onDelete = Delete
                    , onTemporaryNewNoteChange = TemporaryNewNoteChanged
                    , onNewNote = NewNote
                    , onNewSlide = NewSlide
                    , onTemporaryNewSlideNameChange = TemporaryNewSlideNameChanged
                    , onSwitchToPresentation = SwitchMode Presentation
                    }
                    model.slides
                    kanban

            Presentation ->
                Presentation.view model
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.mode of
        Kanban kanban ->
            [ Maybe.map
                (\_ -> Browser.Events.onMouseUp <| Json.Decode.succeed <| DropNote Nothing)
                kanban.dragState
            , Maybe.map
                (\_ ->
                    Browser.Events.onMouseMove <|
                        Json.Decode.map2 (\x y -> MouseMoved ( x, y ))
                            (Json.Decode.field "clientX" Json.Decode.float)
                            (Json.Decode.field "clientY" Json.Decode.float)
                )
                kanban.dragState
            , Just (pastedImage PastedImage)
            ]
                |> List.foldl
                    (\maybeSubscription acc ->
                        case maybeSubscription of
                            Just subscription ->
                                acc ++ [ subscription ]

                            Nothing ->
                                acc
                    )
                    []
                |> Sub.batch

        Presentation ->
            Sub.none
