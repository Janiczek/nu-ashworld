module Evergreen.Migrate.V8 exposing (..)

import Evergreen.V6.Frontend.Route as ROld
import Evergreen.V6.Types as Old
import Evergreen.V6.Types.Player as POld
import Evergreen.V6.Types.World as WOld
import Evergreen.V8.Frontend.Route as RNew
import Evergreen.V8.Types as New
import Evergreen.V8.Types.Player as PNew
import Evergreen.V8.Types.World as WNew
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


migrateWorld : WOld.World -> WNew.World
migrateWorld old =
    case old of
        WOld.WorldNotInitialized ->
            WNew.WorldNotInitialized

        WOld.WorldLoggedOut data ->
            WNew.WorldLoggedOut <|
                migrateWorldLoggedOutData data

        WOld.WorldLoggedIn data ->
            WNew.WorldLoggedIn <|
                migrateWorldLoggedInData data


migrateWorldLoggedInData : WOld.WorldLoggedInData -> WNew.WorldLoggedInData
migrateWorldLoggedInData data =
    { player = migrateCPlayer data.player
    , otherPlayers = data.otherPlayers
    }


migrateWorldLoggedOutData : WOld.WorldLoggedOutData -> WNew.WorldLoggedOutData
migrateWorldLoggedOutData data =
    { players = data.players }


migrateCPlayer : POld.CPlayer -> PNew.CPlayer
migrateCPlayer old =
    { hp = old.hp
    , maxHp = old.maxHp
    , xp = old.xp
    , name = old.name
    , special = old.special
    , availableSpecial = old.availableSpecial
    , caps = old.cash
    , ap = old.ap
    , wins = old.wins
    , losses = old.losses
    }


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , zone = old.zone
          , route = migrateRoute old.route
          , world = migrateWorld old.world
          }
        , Cmd.none
        )


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
    case old of
        Old.LogMeIn ->
            MsgMigrated ( New.LogMeIn, Cmd.none )

        Old.GiveMeCurrentWorld ->
            MsgOldValueIgnored


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    case old of
        Old.Connected sId cId ->
            MsgMigrated ( New.Connected sId cId, Cmd.none )

        Old.GeneratedPlayer cId sPlayer ->
            -- probably not OK but who cares at this stage
            MsgOldValueIgnored


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgMigrated
        ( case old of
            Old.YourCurrentWorld w ->
                New.YourCurrentWorld <| migrateWorldLoggedInData w

            Old.CurrentWorld w ->
                New.CurrentWorld w
        , Cmd.none
        )
