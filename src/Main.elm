module Main exposing (..)

import Browser
import Html
import Html.Attributes exposing (..)
import Home.Types exposing(..)
import Home.State exposing(..)
import Home.Rest exposing(..)
import Home.View exposing(..)
import Html.Styled as Styled exposing (Html, div)

---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
