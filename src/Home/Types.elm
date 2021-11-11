module Home.Types exposing (..)

import Dict
import RemoteData exposing (RemoteData, WebData)
import Select exposing (Action(..))
import Toasty
import Toasty.Defaults
import Json.Decode as Decode

type alias Url =
    String


type alias PackageName =
    String


type Msg
    = FetchPackage
    | SelectPackage (Select.Msg Package)
    | ResponseOnFetchPackageName (WebData PackageInfo)
    | ToastyMsg (Toasty.Msg Toasty.Defaults.Toast)


    

type Package
    = Elm
    | Rust
    | Go


type alias ProjectUrl =
    { homePage : String }


type alias RequiresDist =
    String


type alias PackageInfo =
    { name : PackageName
    , releases : Dict.Dict String Decode.Value
    , projectUrls : ProjectUrl
    , dependencies : List RequiresDist
    }


type alias Model =
    { selectState : Select.State
    , items : List (Select.MenuItem Package)
    , selectedPackage : Maybe Package
    , reqPackage : WebData PackageInfo
    , toasties : Toasty.Stack Toasty.Defaults.Toast
    }

