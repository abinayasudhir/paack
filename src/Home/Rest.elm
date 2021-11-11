module Home.Rest exposing(..)
import Home.Types as Types exposing (..)
import Http
import Http.Detailed
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (RemoteData, WebData)
import Json.Decode.Pipeline exposing (requiredAt)
-- import RemoteData exposing (RemoteData(..))


-- decoderRelease : Decode.Decoder Release
-- decoderRelease =
--     Decode.succeed Release
--         |> required "version" string
        

decoderProjectUrl : Decode.Decoder ProjectUrl
decoderProjectUrl =
    Decode.succeed ProjectUrl
        |> required "Homepage" string 

packageInfoDecoder : Decoder PackageInfo
packageInfoDecoder =
    Decode.succeed PackageInfo
        |> requiredAt ["info","name"] string
        |> required "releases" (Decode.dict Decode.value)
        |> requiredAt ["info","project_urls"] decoderProjectUrl
        |> requiredAt["info", "requires_dist"] (Decode.list Decode.string)


httpCommand : Cmd Msg
httpCommand =
    Http.get
        { url = "https://pypi.org/pypi/RUST/json"
        , expect =
         Http.expectJson (RemoteData.fromResult >> ResponseOnFetchPackageName) packageInfoDecoder
        }