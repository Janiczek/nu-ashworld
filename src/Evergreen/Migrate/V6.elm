module Evergreen.Migrate.V6 exposing (..)

import Evergreen.V3.Frontend.Route as ROld
import Evergreen.V3.Types as Old
import Evergreen.V3.Types.World as WOld
import Evergreen.V6.Frontend.Route as RNew
import Evergreen.V6.Types as New
import Evergreen.V6.Types.World as WNew
import Lamdera.Migrations exposing (..)
import Task
import Time


migrateRoute : ROld.Route -> RNew.Route
migrateRoute route =
    case route of
        ROld.Character ->
            RNew.Character

        ROld.Map ->
            RNew.Map

        ROld.Ladder ->
            RNew.Ladder

        ROld.Town ->
            RNew.Town

        ROld.Settings ->
            RNew.Settings

        ROld.FAQ ->
            RNew.FAQ

        ROld.About ->
            RNew.About

        ROld.News ->
            RNew.News


migrateWorld : WOld.World -> WNew.World
migrateWorld world =
    case world of
        WOld.WorldNotInitialized ->
            WNew.WorldNotInitialized

        WOld.WorldLoggedOut data ->
            WNew.WorldLoggedOut data

        WOld.WorldLoggedIn data ->
            WNew.WorldLoggedIn data


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , zone = Time.utc
          , route = migrateRoute old.route
          , world = migrateWorld old.world
          }
        , Task.perform New.GetZone Time.here
        )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgUnchanged
