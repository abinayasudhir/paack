module Home.State exposing (init, update,buildErrorMessage)

import Home.Rest exposing (..)
import Home.Toast exposing (addToast, toastFailure, toastResult)
import Home.Types exposing (..)
import Http
import Maybe.Extra as Maybe
import RemoteData
import Select exposing (Action(..))
import Toasty
import Toasty.Defaults


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { selectState = Select.initState
            , items =
                [ { item = Elm, label = "Elm" }
                , { item = Rust, label = "Rust" }
                , { item = Go, label = "Go" }
                ]
            , selectedPackage = Nothing
            , reqPackage = RemoteData.NotAsked
            , toasties = Toasty.initialState
            }
    in
    ( model
    , Cmd.batch
        [ httpCommand ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPackage ->
            ( { model | reqPackage = RemoteData.Loading }, httpCommand )

        ResponseOnFetchPackageName response ->
            ( { model | reqPackage = response }, Cmd.none )
                |> toastResult response "FetchPackage" ToastyMsg

        ToastyMsg subMsg ->
            Toasty.update Toasty.Defaults.config ToastyMsg subMsg model

        SelectPackage sm ->
            let
                ( maybeAction, selectState, cmds ) =
                    Select.update sm model.selectState

                updatedSelectedItem =
                    case maybeAction of
                        Just (Select.Select i) ->
                            Just i |> Debug.log "Selected"
                        
                        Just Select.ClearSingleSelectItem ->
                            Nothing

                        _ ->
                            model.selectedPackage
            in
            ( { model | selectState = selectState, selectedPackage = updatedSelectedItem }, Cmd.map SelectPackage cmds )

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
