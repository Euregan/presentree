module Message exposing (..)

import Browser
import Data exposing (Data)
import Url


type Msg
    = KeyDown Int
    | TextInput String
    | Move Data
    | DragOver
    | DropData String
    | Delete String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
