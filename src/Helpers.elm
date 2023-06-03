module Helpers exposing (..)


isUrl : String -> Bool
isUrl string =
    String.startsWith "http" string && not (String.contains " " string)
