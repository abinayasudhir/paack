module Home.View exposing (..)

import Dict
import Dropdown
import Element as E
import Home.State exposing (..)
import Home.Types exposing (..)
import Html as H
import Html.Styled as Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import RemoteData
import Select exposing (selectIdentifier)



-- selectedPackageToMenuItem : Package -> Select.MenuItem Package
-- selectedPackageToMenuItem package =
--     case package of
--         Elm ->
--             { item = Elm, label = "Elm" }
--         Rust ->
--             { item = Rust, label = "Rust" }
--         Go ->
--             { item = Go, label = "Go" }


view : Model -> H.Html Msg
view model =
    toUnstyled <|
        div
            [ class "container"
            ]
            [ E.column [ E.padding 20, E.spacing 20 ]
                [ E.el [] <| E.text <| "Selected Option: " ++ (model.selectedPackage |> Maybe.withDefault "Nothing")
                , Dropdown.view dropdownConfig model model.dropdownState
                ]
                |> E.layout []
                |> Styled.fromUnstyled
            , case model.reqPackage of
                RemoteData.NotAsked ->
                    text ""

                RemoteData.Loading ->
                    h3 [ class "loader" ] []

                RemoteData.Success resp ->
                    viewPackageDetails resp

                RemoteData.Failure httpError ->
                    viewError (buildErrorMessage httpError)
            ]


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewPackageDetails : PackageInfo -> Html Msg
viewPackageDetails resp =
    ul []
        [ li [ class "list" ]
            [ p []
                [ span [ class "bold" ] [ text "Package Name : " ]
                , span [] [ text resp.name ]
                ]
            ]
        , li [ class "list" ]
            [ p []
                [ span [ class "bold" ] [ text ("Related Links : " ++ "HomePage : ") ]
                , span [] [ text resp.projectUrls.homePage ]
                ]
            ]
        , li [ class "list" ]
            [ p []
                [ span [ class "bold" ] [ text "Dependencies : " ]
                , span [] [ text <| String.join ", " resp.dependencies ]
                ]
            ]
        , li [ class "list" ]
            [ p []
                [ span [ class "bold" ] [ text "Versions : " ]
                , span [] [ text <| String.join ", " (Dict.keys resp.releases) ]
                ]
            ]
        ]
