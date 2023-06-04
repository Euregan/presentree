module Kanban exposing (..)

import Html
import Html.Attributes
import Html.Events
import Message exposing (Msg(..))
import Models exposing (Mode(..), Model)
import Slide


view : Model -> Html.Html Msg
view model =
    Html.div [ Html.Attributes.class "w-full h-full flex flex-col bg-slate-100 dark" ]
        [ Html.ul [ Html.Attributes.class "flex flex-row flex-1" ] <|
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
                   , Html.li [] [ Html.button [ Html.Events.onClick (SwitchMode Presentation) ] [ Html.text "Present" ] ]
                   ]
        ]
