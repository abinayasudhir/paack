module Home.Rest exposing (httpCommand)

import Home.Types exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optionalAt, required, requiredAt)
import RemoteData


packageInfoDecoder : Decoder PackageInfo
packageInfoDecoder =
    Decode.succeed PackageInfo
        |> requiredAt [ "info", "name" ] string
        |> required "releases" (Decode.dict Decode.value)
        |> requiredAt [ "info", "project_urls" ] (Decode.dict Decode.string)
        |> optionalAt [ "info", "requires_dist" ] (Decode.list Decode.string) []


httpCommand : PackageName -> Cmd Msg
httpCommand name =
    Http.get
        { url = "https://pypi.org/pypi/" ++ name ++ "/json"
        , expect =
            Http.expectJson (RemoteData.fromResult >> ResponseOnFetchPackageName) packageInfoDecoder
        }
