module Home.State exposing (buildErrorMessage, init, update, dropdownConfig)

import Home.Rest exposing (..)
import Home.Types exposing (..)
import Http
import Maybe.Extra as Maybe
import RemoteData
import Select exposing (Action(..))
import Task
import Dropdown
import Element exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font

init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { selectState = Select.initState
            , packages = packages
            , dropdownState = Dropdown.init "dropdown"
            , selectedPackage = Nothing
            , reqPackage = RemoteData.NotAsked
            }
    in
    ( model
    , Cmd.none
    )

packages : List PackageName
packages = ["Elm", "Rust", "Go"]
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- ChoosePackage package ->
        --     ( { model | selectedPackage = Just package }, httpCommand <| showPackage package )

        -- FetchPackage ->
        --     let
        --         packageName =
        --             Maybe.map showPackage model.selectedPackage
        --     in
        --     ( { model
        --         | reqPackage =
        --             if Maybe.isNothing packageName then
        --                 RemoteData.NotAsked

        --             else
        --                 RemoteData.Loading
        --       }
        --     , Maybe.withDefault Cmd.none <| Maybe.map httpCommand packageName
        --     )

        ResponseOnFetchPackageName response ->
            ( { model | reqPackage = response }, Cmd.none )

        -- SelectPackage sm ->
        --     let
        --         ( maybeAction, selectState, cmds ) =
        --             Select.update sm model.selectState

        --         updatedSelectedItem =
        --             case maybeAction of
        --                 Just (Select.Select i) ->
        --                     Just i

        --                 Just Select.ClearSingleSelectItem ->
        --                     Nothing

        --                 _ ->
        --                     model.selectedPackage
        --     in
        --     ( { model | selectState = selectState, selectedPackage = updatedSelectedItem }
        --     , Cmd.batch
        --         [ Cmd.map SelectPackage cmds
        --         , run FetchPackage
        --         ]
        --     )
        OptionPicked option ->
            ( { model | selectedPackage = option }, Cmd.none )

        DropdownMsg subMsg ->
            let
                ( state, cmd ) =
                    Dropdown.update dropdownConfig subMsg model model.dropdownState
            in
            ( { model | dropdownState = state }, cmd )

        _ -> (model,Cmd.none)

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



dropdownConfig1 : Dropdown.Config PackageName Msg Model
dropdownConfig1 =
    let
        itemToPrompt item =
            text item

        itemToElement selected highlighted item =
            text item
    in
    Dropdown.basic
        { itemsFromModel = always packages
        , selectionFromModel = .selectedPackage
        , dropdownMsg = DropdownMsg
        , onSelectMsg = OptionPicked
        , itemToPrompt = itemToPrompt
        , itemToElement = itemToElement
        }




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
            [ Border.width 1
            , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 5, bottomRight = 5 }
            , width fill
            , spacing 5
            ]

        itemToPrompt item =
            text item

        itemToElement selected highlighted i =
            let
                bgColor =
                    if highlighted then
                        rgb255 0 0 255

                    else if selected then
                        rgb255 100 100 100

                    else
                        rgb 255 51 51
            in
            row
                [ Background.color bgColor
                , padding 8
                , spacing 10
                , width fill
                ]
                [ el [] (text "-")
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

run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())


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
