module Slide exposing (..)

import Data exposing (Data)
import EventHelpers exposing (onDragOver, onDrop)
import Html exposing (Html)
import Html.Attributes


type alias Actions msg =
    { onDrop : String -> msg
    , onDragOver : msg
    , onDragStart : Data -> msg
    , onDelete : String -> msg
    }


kanbanView : Actions msg -> String -> List Data -> Html msg
kanbanView actions status list =
    Html.div
        [ Html.Attributes.class "flex-1 m-3 p-3"
        , onDrop <| actions.onDrop status
        , onDragOver <| actions.onDragOver
        ]
        [ Html.h2 [ Html.Attributes.class "m-0 p-0 text-base uppercase" ] [ Html.text status ]
        , Html.span [ Html.Attributes.class "text-sm text-gray-500" ] [ Html.text (String.fromInt (List.length list) ++ " item(s)") ]
        , Html.ul [ Html.Attributes.class "my-3 mx-0" ]
            (List.map
                (Data.kanbanView
                    { onDragStart = actions.onDragStart
                    , onDelete = actions.onDelete
                    }
                )
                list
            )
        ]
