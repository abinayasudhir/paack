module Home.Types exposing (..)

import Dict
import Dropdown
import Json.Decode as Decode
import RemoteData exposing (WebData)


type alias PackageName =
    String


type alias Dependency =
    String


type alias PackageInfo =
    { name : PackageName
    , releases : Dict.Dict String Decode.Value
    , projectUrls : Dict.Dict String String
    , dependencies : List Dependency
    }


type alias Model =
    { packages : List PackageName
    , selectedPackage : Maybe PackageName
    , dropdownState : Dropdown.State PackageName
    , reqPackage : WebData PackageInfo
    }


type Msg
    = ResponseOnFetchPackageName (WebData PackageInfo)
    | OptionPicked (Maybe PackageName)
    | DropdownMsg (Dropdown.Msg PackageName)
