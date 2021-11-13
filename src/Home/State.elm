module Home.State exposing (buildErrorMessage, init, update)

import Home.Rest exposing (..)
import Home.Types exposing (..)
import Http
import Maybe.Extra as Maybe
import RemoteData
import Select exposing (Action(..))
import Task


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { selectState = Select.initState
            , packages =
                [ { item = Elm, label = "Elm" }
                , { item = Rust, label = "Rust" }
                , { item = Go, label = "Go" }
                ]
            , selectedPackage = Nothing
            , reqPackage = RemoteData.NotAsked
            }
    in
    ( model
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPackage ->
            let
                packageName =
                    Maybe.map showPackage model.selectedPackage
            in
            ( { model
                | reqPackage =
                    if Maybe.isNothing packageName then
                        RemoteData.NotAsked

                    else
                        RemoteData.Loading
              }
            , Maybe.withDefault Cmd.none <| Maybe.map httpCommand packageName
            )

        ResponseOnFetchPackageName response ->
            ( { model | reqPackage = response }, Cmd.none )

        SelectPackage sm ->
            let
                ( maybeAction, selectState, cmds ) =
                    Select.update sm model.selectState

                updatedSelectedItem =
                    case maybeAction of
                        Just (Select.Select i) ->
                            Just i

                        Just Select.ClearSingleSelectItem ->
                            Nothing

                        _ ->
                            model.selectedPackage
            in
            ( { model | selectState = selectState, selectedPackage = updatedSelectedItem }
            , Cmd.batch
                [ Cmd.map SelectPackage cmds
                , run FetchPackage
                ]
            )


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
