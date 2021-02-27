module Evergreen.Migrate.V13 exposing (..)

import Evergreen.V12.Data.Fight as FOld
import Evergreen.V12.Data.HealthStatus as HOld
import Evergreen.V12.Data.Player as POld
import Evergreen.V12.Data.World as WOld
import Evergreen.V12.Frontend.Route as ROld
import Evergreen.V12.Types as Old
import Evergreen.V13.Data.Fight as FNew
import Evergreen.V13.Data.HealthStatus as HNew
import Evergreen.V13.Data.Player as PNew
import Evergreen.V13.Data.World as WNew
import Evergreen.V13.Frontend.Route as RNew
import Evergreen.V13.Types as New
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
            RNew.Fight <| migrateFightInfo fightInfo


migrateFightInfo : FOld.FightInfo -> FNew.FightInfo
migrateFightInfo old =
    { attacker = old.attacker
    , target = old.target
    , result =
        case old.result of
            FOld.AttackerWon ->
                FNew.AttackerWon

            FOld.TargetWon ->
                FNew.TargetWon

            FOld.TargetAlreadyDead ->
                FNew.TargetAlreadyDead
    , winnerXpGained = old.winnerXpGained
    , winnerCapsGained = old.winnerCapsGained
    }


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
    { player = data.player
    , otherPlayers = List.map migrateOtherPlayer data.otherPlayers
    }


migrateWorldLoggedOutData : WOld.WorldLoggedOutData -> WNew.WorldLoggedOutData
migrateWorldLoggedOutData data =
    { players = List.map migrateOtherPlayer data.players }


migrateOtherPlayer : POld.COtherPlayer -> PNew.COtherPlayer
migrateOtherPlayer old =
    { level = old.level
    , name = old.name
    , wins = old.wins
    , losses = old.losses
    , healthStatus = migrateHealthStatus old.healthStatus
    }


migrateHealthStatus : HOld.HealthStatus -> HNew.HealthStatus
migrateHealthStatus old =
    case old of
        HOld.ExactHp x ->
            HNew.ExactHp x

        HOld.Unhurt ->
            HNew.Unhurt

        HOld.SlightlyWounded ->
            HNew.SlightlyWounded

        HOld.Wounded ->
            HNew.Wounded

        HOld.SeverelyWounded ->
            HNew.SeverelyWounded

        HOld.AlmostDead ->
            HNew.AlmostDead

        HOld.Dead ->
            HNew.Dead

        HOld.Alive ->
            HNew.Alive

        HOld.Unknown ->
            HNew.Unknown


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
    MsgUnchanged


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
                New.YourCurrentWorld <| migrateWorldLoggedInData world

            Old.CurrentWorld world ->
                New.CurrentWorld <| migrateWorldLoggedOutData world

            Old.YourFightResult ( fightInfo, world ) ->
                New.YourFightResult
                    ( migrateFightInfo fightInfo
                    , migrateWorldLoggedInData world
                    )
        , Cmd.none
        )
