module Evergreen.Migrate.V17 exposing (..)

import Dict
import Evergreen.V16.Types as Old
import Evergreen.V17.Data.Auth as ANew
import Evergreen.V17.Data.NewChar as NNew
import Evergreen.V17.Data.World as WNew
import Evergreen.V17.Frontend.Route as RNew
import Evergreen.V17.Types as New
import Lamdera
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , route = RNew.News
          , world = WNew.WorldNotInitialized ANew.init
          , zone = old.zone
          , newChar = NNew.init
          }
        , Lamdera.sendToBackend New.RefreshPlease
        )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { players = Dict.empty
          , loggedInPlayers = Dict.empty
          }
        , Cmd.none
        )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgOldValueIgnored


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgOldValueIgnored


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgOldValueIgnored


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgOldValueIgnored
