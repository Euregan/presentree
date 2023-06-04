module Presentation exposing (..)

import Html exposing (Html)
import Html.Attributes
import Message exposing (Msg)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    case model.slides of
        slide :: _ ->
            case slide.image of
                Just image ->
                    Html.div [ Html.Attributes.class "w-full h-full" ]
                        [ Html.img
                            [ Html.Attributes.src image
                            , Html.Attributes.class "w-full h-full"
                            ]
                            []
                        ]

                _ ->
                    Html.text ""

        _ ->
            Html.text ""
