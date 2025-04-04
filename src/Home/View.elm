module Home.View exposing (buildErrorMessage, view)

import Dict
import Dropdown
import Element as E
import Home.State exposing (..)
import Home.Types exposing (..)
import Html as H
import Html.Styled as Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Http
import RemoteData


view : Model -> H.Html Msg
view model =
    toUnstyled <|
        div
            [ class "container"
            ]
            [ E.column [ E.padding 20, E.spacing 20 ]
                [ Dropdown.view dropdownConfig model model.dropdownState
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
    div []
        [ p []
            [ span [ class "bold" ] [ text "Package Name : " ]
            , span [] [ text resp.name ]
            ]
        , p []
            [ span [ class "bold" ] [ text "Related Links" ]
            ]
        , ul [] <| List.map (\( k, v ) -> li [ class "list" ] [ text k, text " : ", text v ]) (Dict.toList resp.projectUrls)
        , p []
            [ span [ class "bold" ] [ text "Dependencies : " ]
            ]
        , ul [] <| List.map (\dep -> li [ class "list" ] [ text dep ]) resp.dependencies
        , p []
            [ span [ class "bold" ] [ text "Versions : " ]
            ]
        , ul [] <| List.map (\version -> li [ class "list" ] [ text version ]) (Dict.keys resp.releases)
        ]


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message
