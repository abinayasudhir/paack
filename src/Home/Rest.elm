module Home.Rest exposing (..)

import Home.Types exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optionalAt, required, requiredAt)
import RemoteData


decoderProjectUrl : Decode.Decoder ProjectUrl
decoderProjectUrl =
    Decode.succeed ProjectUrl
        |> required "Homepage" string


packageInfoDecoder : Decoder PackageInfo
packageInfoDecoder =
    Decode.succeed PackageInfo
        |> requiredAt [ "info", "name" ] string
        |> required "releases" (Decode.dict Decode.value)
        |> requiredAt [ "info", "project_urls" ] decoderProjectUrl
        |> optionalAt [ "info", "requires_dist" ] (Decode.list Decode.string) []


httpCommand : PackageName -> Cmd Msg
httpCommand name =
    -- "https://pypi.org/pypi/RUST/json"
    Http.get
        { url = "https://pypi.org/pypi/" ++ name ++ "/json"
        , expect =
            Http.expectJson (RemoteData.fromResult >> ResponseOnFetchPackageName) packageInfoDecoder
        }
