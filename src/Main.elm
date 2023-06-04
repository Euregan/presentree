module Main exposing (..)

import Browser
import Browser.Events
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
        Grab note position ->
            ( { model
                | dragState =
                    Just
                        { dragging = note
                        , position = position
                        }
              }
            , Cmd.none
            )

        MouseMoved newPosition ->
            case model.dragState of
                Just dragState ->
                    ( { model | dragState = Just { dragState | position = newPosition } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DropNote maybeTarget ->
            case ( maybeTarget, model.dragState ) of
                ( Just ( targetSlide, targetIndex ), Just dragState ) ->
                    let
                        updatedModel =
                            { model
                                | dragState = Nothing
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
                    ( { model | dragState = Nothing }, Cmd.none )

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
                                        slide
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
                            { onDrop = \index -> DropNote (Just ( slide, index ))
                            , onDragStart = Grab
                            , onDelete = Delete
                            , onTemporaryNewNoteChange = TemporaryNewNoteChanged slide
                            , onNewNote = NewNote slide
                            }
                            model.dragState
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
    [ Maybe.map
        (\_ -> Browser.Events.onMouseUp <| Json.Decode.succeed <| DropNote Nothing)
        model.dragState
    , Maybe.map
        (\_ ->
            Browser.Events.onMouseMove <|
                Json.Decode.map2 (\x y -> MouseMoved ( x, y ))
                    (Json.Decode.field "clientX" Json.Decode.float)
                    (Json.Decode.field "clientY" Json.Decode.float)
        )
        model.dragState
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
