module Home.Types exposing (..)

import Dict
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Select exposing (Action(..))
import Dropdown


type alias Url =
    String


type alias PackageName =
    String


type Msg
    = FetchPackage
    | SelectPackage (Select.Msg Package)
    | ResponseOnFetchPackageName (WebData PackageInfo)
    -- | ChoosePackage Package
    | OptionPicked (Maybe PackageName)
    | DropdownMsg (Dropdown.Msg PackageName)
    | NoOp


type Package
    = Elm
    | Rust
    | Go


showPackage : Package -> String
showPackage package =
    case package of
        Elm ->
            "elm"

        Rust ->
            "RUST"

        Go ->
            "go"


type alias ProjectUrl =
    { homePage : String }


type alias Dependency =
    String


type alias PackageInfo =
    { name : PackageName
    , releases : Dict.Dict String Decode.Value
    , projectUrls : ProjectUrl
    , dependencies : List Dependency
    }


type alias Model =
    { selectState : Select.State                              -- to be removed
    , packages : List PackageName
    , selectedPackage : Maybe PackageName
    , dropdownState : Dropdown.State PackageName
    , reqPackage : WebData PackageInfo
    }
