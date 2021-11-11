module Main exposing (..)

import Browser
import Home.Rest exposing (..)
import Home.State exposing (..)
import Home.Types exposing (..)
import Home.View exposing (..)
import Html.Attributes exposing (..)
import Html.Styled exposing (..)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
