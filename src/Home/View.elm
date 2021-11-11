module Home.View exposing (..)

import Css
import Dict
import Home.State exposing (..)
import Home.Types exposing (..)
import Html as H
import Html.Styled as Styled exposing (..)
import Html.Styled.Attributes as StyledAttribs exposing (..)
import Html.Styled.Events exposing (..)
import RemoteData exposing (RemoteData, WebData)
import Select exposing (MenuItem, initState, selectIdentifier, update)


selectedPackageToMenuItem : Package -> Select.MenuItem Package
selectedPackageToMenuItem package =
    case package of
        Elm ->
            { item = Elm, label = "Elm" }

        Rust ->
            { item = Rust, label = "Rust" }

        Go ->
            { item = Go, label = "Go" }


renderSelect : Model -> Styled.Html Msg
renderSelect model =
    Styled.map SelectPackage <|
        Select.view
            ((Select.single <| Maybe.map selectedPackageToMenuItem model.selectedPackage)
                |> Select.state model.selectState
                |> Select.menuItems model.items
                |> Select.placeholder "Please select any package"
                |> Select.clearable True
            )
            (selectIdentifier "PackageName")


view : Model -> H.Html Msg
view model =
    toUnstyled <|
        case model.reqPackage of
            RemoteData.NotAsked ->
                text ""

            RemoteData.Loading ->
                h3 [class "loader"] [ text "Loading..." ]

            RemoteData.Success resp ->
                viewPackageDetails model resp

            RemoteData.Failure httpError ->
                viewError (buildErrorMessage httpError)


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


viewPackageDetails : Model -> PackageInfo -> Html Msg
viewPackageDetails model resp =
    let
        _ =
            Debug.log "model" model.reqPackage
    in
    div
        [ class "container"
        ]
        [ renderSelect model
        , ul []
            [ li [ class "list" ]
                [ p []
                    [ span [ class "bold" ] [ text "Package Name:" ]
                    , span [] [ text resp.name ]
                    ]
                ]
            , li [ class "list" ]
                [ p []
                    [ span [ class "bold" ] [ text ("Related Links:" ++ "HomePage:") ]
                    , span [] [ text resp.projectUrls.homePage ]
                    ]
                ]
            , li [ class "list" ]
                [ p []
                    [ span [ class "bold" ] [ text "Dependencies:" ]
                    , span [] [ text <| String.join ", " resp.dependencies ]
                    ]
                ]
            , li [ class "list" ]
                [ p []
                    [ span [class "bold"] [ text "Versions:" ]
                    , span [] [ text <| String.join ", " (Dict.keys resp.releases) ]
                    ]
                ]
            ]
        ]
