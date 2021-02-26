module Evergreen.Migrate.V3 exposing (..)

import Evergreen.V1.Frontend.Route as ROld
import Evergreen.V1.Types as Old
import Evergreen.V1.Types.World as WOld
import Evergreen.V3.Frontend.Route as RNew
import Evergreen.V3.Types as New
import Evergreen.V3.Types.World as WNew
import Lamdera.Migrations exposing (..)


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


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , route = migrateRoute old.route
          , world =
                case old.world of
                    Nothing ->
                        WNew.WorldNotInitialized

                    Just world ->
                        WNew.WorldLoggedIn world
          }
        , Cmd.none
        )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgMigrated <|
        ( case old of
            Old.GoToRoute route ->
                New.GoToRoute <| migrateRoute route

            -- rest is copypaste
            Old.UrlClicked url ->
                New.UrlClicked url

            Old.UrlChanged url ->
                New.UrlChanged url

            Old.Logout ->
                New.Logout

            Old.Login ->
                New.Login

            Old.NoOp ->
                New.NoOp
        , Cmd.none
        )


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgMigrated
        ( case old of
            Old.YourCurrentWorld world ->
                New.YourCurrentWorld world
        , Cmd.none
        )
