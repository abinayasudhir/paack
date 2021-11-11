module Home.Toast exposing
    ( addToast
    , toastFailure
    , toastMsg
    , toastResult
    , toastyConfig
    , toastyView
    )
import Http
import Home.Rest as Rest
import Home.Types as Types
import Html.Attributes as HA
import Html.Styled exposing (Html, fromUnstyled)
import RemoteData
import Toasty
import Toasty.Defaults
import RemoteData exposing (RemoteData(..), WebData)
import Http.Detailed

addToast :
    a
    -> (Toasty.Msg a -> msg)
    -> ( { m | toasties : Toasty.Stack a }, Cmd msg )
    -> ( { m | toasties : Toasty.Stack a }, Cmd msg )
addToast toast toastymsg ( model, cmd ) =
    Toasty.addToast toastyConfig toastymsg toast ( model, cmd )



-- Toasty.addToast Toasty.Defaults.config toastymsg toast ( model, cmd )


toastFailure :
    WebData a
    -> String
    -> (Toasty.Msg Toasty.Defaults.Toast -> msg)
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
toastFailure resp title toastymsg mc =
    mc
        |> (case resp of
                RemoteData.Failure error ->
                    addToast
                        (Toasty.Defaults.Error title <| boundMsg <| buildErrorMessage error)
                        toastymsg

                _ ->
                    identity
           )


toastResult :
    WebData a
    -> String
    -> (Toasty.Msg Toasty.Defaults.Toast -> msg)
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
toastResult resp title toastymsg mc =
    mc
        |> (case resp of
                RemoteData.Success _ ->
                    addToast
                        (Toasty.Defaults.Success title "Operation completed successfully")
                        toastymsg

                RemoteData.Failure error ->
                    addToast
                        (Toasty.Defaults.Error title <| boundMsg <| buildErrorMessage error)
                        toastymsg

                _ ->
                    identity
           )


toastMsg :
    WebData { a | msg : String }
    -> String
    -> (Toasty.Msg Toasty.Defaults.Toast -> msg)
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
    -> ( { m | toasties : Toasty.Stack Toasty.Defaults.Toast }, Cmd msg )
toastMsg resp title toastymsg mc =
    mc
        |> (case resp of
                RemoteData.Success data ->
                    addToast
                        (Toasty.Defaults.Success title data.msg)
                        toastymsg

                RemoteData.Failure error ->
                    addToast
                        (Toasty.Defaults.Error title <| boundMsg <| buildErrorMessage error)
                        toastymsg

                _ ->
                    identity
           )


{-| Wrapper for Toasty.view to add Style
-}
toastyView :
    (Toasty.Msg Toasty.Defaults.Toast -> msg)
    -> Toasty.Stack Toasty.Defaults.Toast
    -> Html msg
toastyView msg toasts =
    Toasty.view toastyConfig Toasty.Defaults.view msg toasts |> fromUnstyled


{-| Use same defaults for containerAttrs except the z-index property added to
put toasts on top of navbars and panels
-}
toastyConfig : Toasty.Config msg
toastyConfig =
    Toasty.Defaults.config
        |> Toasty.delay 10000
        |> Toasty.containerAttrs
            [ HA.style "position" "fixed"
            , HA.style "top" "50" -- avoid overlap with navbar
            , HA.style "right" "0"
            , HA.style "width" "100%"
            , HA.style "max-width" "400px"
            , HA.style "list-style-type" "none"
            , HA.style "padding" "0"
            , HA.style "margin" "0"
            , HA.style "z-index" "10000"
            ]


boundMsg : String -> String
boundMsg =
    headAndTail 500


{-| NOTE: Only exported for testing purposes, should use boundMsg instead
-}
headAndTail : Int -> String -> String
headAndTail len txt =
    if String.length txt <= len then
        txt

    else
        let
            mid =
                (len // 2) - 1
        in
        String.left mid txt ++ "..." ++ String.right mid txt

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