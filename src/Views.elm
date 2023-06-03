module Views exposing (..)

import EventHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)



-- CARD VIEW


taskItemView : Int -> Task -> Html Msg
taskItemView index task =
    li
        [ class "relative cursor-move rounded shadow bg-white p-4 pr-10 mb-3 text-sm"
        , attribute "draggable" "true"
        , onDragStart <| Move task
        , attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
        ]
        [ enrichItemContent task.name
        , button
            [ class "block bg-red-700 text-white w-5 h-5 border-none rounded-xl absolute top-1/2 right-2.5 -translate-y-1/2 rotate-45 opacity-5 hover:opacity-100 cursor-pointer transition-opacity text-2xl leading-5"
            , style "font-family" "initial"
            , onClick <| Delete task.name
            ]
            [ text "+" ]
        ]


enrichItemContent : String -> Html Msg
enrichItemContent str =
    List.map
        (\word ->
            if String.startsWith "http" word then
                a [ target "_blank", href word ] [ text word ]

            else
                text word
        )
        (String.words str)
        |> List.intersperse (text " ")
        |> Html.div []



-- COLUMN VIEW


taskColumnView : String -> List Task -> Html Msg
taskColumnView status list =
    div
        [ class "flex-1 m-3 p-3"
        , onDrop <| DropTask status
        , onDragOver <| DragOver
        ]
        [ h2 [ class "m-0 p-0 text-base uppercase" ] [ text status ]
        , span [ class "text-sm text-gray-500" ] [ text (String.fromInt (List.length list) ++ " item(s)") ]
        , ul [ class "my-3 mx-0" ] (List.indexedMap taskItemView list)
        ]
