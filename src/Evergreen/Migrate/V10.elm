module Evergreen.Migrate.V10 exposing (..)

import Evergreen.V10.Frontend.Route as RNew
import Evergreen.V10.Types as New
import Evergreen.V8.Frontend.Route as ROld
import Evergreen.V8.Types as Old
import Lamdera.Migrations exposing (..)


migrateRoute : ROld.Route -> RNew.Route
migrateRoute old =
    case old of
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

        ROld.Fight fightInfo ->
            -- we have no way of getting the rest of the info ¯\_(ツ)_/¯
            RNew.News


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgMigrated
        ( case old of
            Old.UrlClicked url ->
                New.UrlClicked url

            Old.UrlChanged url ->
                New.UrlChanged url

            Old.GoToRoute route ->
                New.GoToRoute <| migrateRoute route

            Old.Logout ->
                New.Logout

            Old.Login ->
                New.Login

            Old.NoOp ->
                New.NoOp

            Old.GetZone zone ->
                New.GetZone zone
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
    MsgUnchanged
