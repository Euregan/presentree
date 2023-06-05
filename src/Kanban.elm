module Kanban exposing (..)

import DragState exposing (DragState)
import Html
import Html.Attributes
import Html.Events
import Note exposing (Note)
import Slide exposing (Slide)


type alias Kanban =
    { newSlideName : String
    , dragState : DragState
    }


init : Kanban
init =
    Kanban "" Nothing


type alias Actions msg =
    { onDrop : Maybe ( Slide, Int ) -> msg
    , onDragStart : Note -> ( Float, Float ) -> msg
    , onDelete : String -> msg
    , onTemporaryNewNoteChange : Slide -> String -> msg
    , onNewNote : Slide -> msg
    , onNewSlide : msg
    , onTemporaryNewSlideNameChange : String -> msg
    , onSwitchToPresentation : msg
    }


view : Actions msg -> List Slide.Slide -> Kanban -> Html.Html msg
view actions slides model =
    Html.div [ Html.Attributes.class "w-full h-full flex flex-col bg-slate-100 dark" ]
        [ Html.ul [ Html.Attributes.class "flex flex-row flex-1" ] <|
            List.map
                (\slide ->
                    Slide.kanbanView
                        { onDrop = \index -> actions.onDrop (Just ( slide, index ))
                        , onDragStart = actions.onDragStart
                        , onDelete = actions.onDelete
                        , onTemporaryNewNoteChange = actions.onTemporaryNewNoteChange slide
                        , onNewNote = actions.onNewNote slide
                        }
                        model.dragState
                        slide
                )
                slides
                ++ [ Html.li []
                        [ Html.form
                            [ Html.Events.onSubmit actions.onNewSlide
                            ]
                            [ Html.input
                                [ Html.Attributes.value model.newSlideName
                                , Html.Events.onInput actions.onTemporaryNewSlideNameChange
                                ]
                                []
                            ]
                        ]
                   , Html.li []
                        [ Html.button
                            [ Html.Events.onClick actions.onSwitchToPresentation
                            ]
                            [ Html.text "Present" ]
                        ]
                   ]
        ]
