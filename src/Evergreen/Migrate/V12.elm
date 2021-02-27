module Evergreen.Migrate.V12 exposing (..)

import Dict
import Evergreen.V10.Frontend.Route as ROld
import Evergreen.V10.Types as Old
import Evergreen.V10.Types.Fight as FOld
import Evergreen.V10.Types.Player as POld
import Evergreen.V10.Types.World as WOld
import Evergreen.V12.Data.Fight as FNew
import Evergreen.V12.Data.HealthStatus exposing (HealthStatus(..))
import Evergreen.V12.Data.Player as PNew
import Evergreen.V12.Data.World as WNew
import Evergreen.V12.Frontend.Route as RNew
import Evergreen.V12.Types as New
import Lamdera.Migrations exposing (..)


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
    { hp = old.hp
    , level = old.level
    , name = old.name
    , wins = old.wins
    , losses = old.losses
    , healthStatus = Unknown
    }


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
    , winnerXpGained = old.winnerXpGained
    , winnerCapsGained = old.winnerCapsGained
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
    -- We're dropping the database!
    ModelMigrated
        ( { players = Dict.empty }
        , Cmd.none
        )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    case old of
        Old.UrlClicked _ ->
            MsgUnchanged

        Old.UrlChanged _ ->
            MsgUnchanged

        Old.GoToRoute route ->
            MsgMigrated
                ( New.GoToRoute <| migrateRoute route
                , Cmd.none
                )

        Old.Logout ->
            MsgUnchanged

        Old.Login ->
            MsgUnchanged

        Old.NoOp ->
            MsgUnchanged

        Old.GetZone _ ->
            MsgUnchanged

        Old.AskToFight _ ->
            MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    case old of
        Old.Connected _ _ ->
            MsgUnchanged

        Old.GeneratedPlayerLogHimIn _ _ _ ->
            MsgUnchanged

        Old.GeneratedFight _ _ _ ->
            MsgOldValueIgnored


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    case old of
        Old.YourCurrentWorld data ->
            MsgMigrated
                ( New.YourCurrentWorld <| migrateWorldLoggedInData data
                , Cmd.none
                )

        Old.CurrentWorld data ->
            MsgMigrated
                ( New.CurrentWorld <| migrateWorldLoggedOutData data
                , Cmd.none
                )

        Old.YourFightResult fight ->
            MsgOldValueIgnored
