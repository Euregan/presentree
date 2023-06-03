module Views exposing (..)

import EventHelpers exposing (..)
import Helpers exposing (isUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- CARD VIEW


enrichItemContent : String -> Html msg
enrichItemContent str =
    List.map
        (\word ->
            if isUrl word then
                a [ target "_blank", href word ] [ text word ]

            else
                text word
        )
        (String.words str)
        |> List.intersperse (text " ")
        |> Html.div []
