module Mode exposing (..)

import Kanban exposing (Kanban)


type Mode
    = Kanban Kanban
    | Presentation
