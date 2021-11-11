module Home.View exposing (..)

import Css
import Home.Types exposing (..)
import Html as H
import Html.Styled as Styled exposing (Html, div, toUnstyled)
import Html.Styled.Attributes as StyledAttribs exposing (..)
import Html.Styled.Events exposing (..)
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
                |> Select.placeholder "Placeholder"
                |> Select.clearable True
            )
            (selectIdentifier "PackageName")


view : Model -> H.Html Msg
view model =
    let
        _ =
            Debug.log "model" model.reqPackage
    in
    Styled.toUnstyled <| renderSelect model
