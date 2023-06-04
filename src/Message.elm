module Message exposing (..)

import Browser
import Note exposing (Note)
import Slide exposing (Slide)
import Url


type Msg
    = Move Note
    | DragOver
    | DropNote (Maybe ( Slide, Int ))
    | Delete String
    | TemporaryNewSlideNameChanged String
    | NewSlide
    | TemporaryNewNoteChanged Slide String
    | NewNote Slide
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
