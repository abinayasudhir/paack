module Home.State exposing (dropdownConfig, init, update)

import Dropdown
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Home.Rest exposing (..)
import Home.Types exposing (..)
import Maybe.Extra as Maybe
import RemoteData


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { packages = packages
            , dropdownState = Dropdown.init "dropdown"
            , selectedPackage = Nothing
            , reqPackage = RemoteData.NotAsked
            }
    in
    ( model
    , Cmd.none
    )


packages : List PackageName
packages =
    [ "Elm", "Rust", "Go" ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseOnFetchPackageName response ->
            ( { model | reqPackage = response }, Cmd.none )

        OptionPicked option ->
            ( { model | selectedPackage = option, reqPackage = RemoteData.Loading }, Maybe.map httpCommand option |> Maybe.withDefault Cmd.none )

        DropdownMsg subMsg ->
            let
                ( state, cmd ) =
                    Dropdown.update dropdownConfig subMsg model model.dropdownState
            in
            ( { model | dropdownState = state }, cmd )


dropdownConfig : Dropdown.Config PackageName Msg Model
dropdownConfig =
    let
        containerAttrs =
            [ width (px 300) ]

        selectAttrs =
            [ Border.width 1, Border.rounded 5, paddingXY 16 8, spacing 10, width fill ]

        searchAttrs =
            [ Border.width 0, padding 0 ]

        listAttrs =
            [ Background.color <| rgb 255 255 255
            , Border.width 1
            , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 5, bottomRight = 5 }
            , width fill
            , spacing 5
            ]

        itemToPrompt item =
            text item

        itemToElement selected _ i =
            let
                bgColor =
                    if selected then
                        rgb255 200 200 200

                    else
                        rgb 255 51 51
            in
            row
                [ Background.color bgColor
                , padding 8
                , spacing 10
                , width fill
                , pointer
                ]
                [ el [] (text "")
                , el [ Font.size 16 ] (text i)
                ]
    in
    Dropdown.filterable
        { itemsFromModel = always packages
        , selectionFromModel = .selectedPackage
        , dropdownMsg = DropdownMsg
        , onSelectMsg = OptionPicked
        , itemToPrompt = itemToPrompt
        , itemToElement = itemToElement
        , itemToText = identity
        }
        |> Dropdown.withContainerAttributes containerAttrs
        |> Dropdown.withPromptElement (el [] (text "Select option"))
        |> Dropdown.withFilterPlaceholder "Type for option"
        |> Dropdown.withSelectAttributes selectAttrs
        |> Dropdown.withListAttributes listAttrs
        |> Dropdown.withSearchAttributes searchAttrs
