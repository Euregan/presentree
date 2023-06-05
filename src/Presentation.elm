module Presentation exposing (..)

import Html exposing (Html)
import Html.Attributes
import Message exposing (Msg)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    case model.slides of
        slide :: _ ->
            Html.div
                [ Html.Attributes.class "flex w-full h-full bg-cover bg-center"
                , Html.Attributes.style "background-image" <|
                    case slide.image of
                        Just image ->
                            "url(" ++ image ++ ")"

                        Nothing ->
                            ""
                ]
                []

        _ ->
            Html.text ""
