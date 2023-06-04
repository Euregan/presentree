module DragState exposing (..)

import Note exposing (Note)


type alias DragState =
    Maybe
        { dragging : Note
        , position : ( Float, Float )
        }
