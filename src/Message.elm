module Message exposing (..)

import Browser
import Models exposing (Mode)
import Note exposing (Note)
import Slide exposing (Slide)
import Url


type Msg
    = Grab Note ( Float, Float )
    | MouseMoved ( Float, Float )
    | DropNote (Maybe ( Slide, Int ))
    | Delete String
    | PastedImage { slideId : String, image : String }
    | SwitchMode Mode
    | TemporaryNewSlideNameChanged String
    | NewSlide
    | TemporaryNewNoteChanged Slide String
    | NewNote Slide
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
