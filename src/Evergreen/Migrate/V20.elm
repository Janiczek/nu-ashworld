module Evergreen.Migrate.V20 exposing (..)

import Evergreen.V19.Data.Auth as AOld
import Evergreen.V19.Data.Fight as FOld
import Evergreen.V19.Data.HealthStatus as HOld
import Evergreen.V19.Data.Player as POld
import Evergreen.V19.Data.World as WOld
import Evergreen.V19.Frontend.Route as ROld
import Evergreen.V19.Types as Old
import Evergreen.V20.Data.Auth as ANew
import Evergreen.V20.Data.Fight as FNew
import Evergreen.V20.Data.HealthStatus as HNew
import Evergreen.V20.Data.Player as PNew
import Evergreen.V20.Data.World as WNew
import Evergreen.V20.Frontend.Route as RNew
import Evergreen.V20.Types as New
import Lamdera.Migrations exposing (..)
import Time


migratePassword : AOld.Password AOld.Verified -> ANew.Password ANew.Verified
migratePassword old =
    ANew.Password <| AOld.unwrap old


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

        ROld.CharCreation ->
            RNew.CharCreation


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


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , time = Time.millisToPosix 0
          , zone = old.zone
          , route = migrateRoute old.route
          , world = migrateWorld old.world
          , newChar = old.newChar
          , authError = old.authError
          }
        , Cmd.none
        )


migrateWorld : WOld.World -> WNew.World
migrateWorld old =
    case old of
        WOld.WorldNotInitialized _ ->
            WNew.WorldNotInitialized ANew.init

        WOld.WorldLoggedOut _ data ->
            WNew.WorldLoggedOut ANew.init <| migrateWorldLoggedOutData data

        WOld.WorldLoggedIn data ->
            WNew.WorldLoggedIn <| migrateWorldLoggedInData data


migrateWorldLoggedInData : WOld.WorldLoggedInData -> WNew.WorldLoggedInData
migrateWorldLoggedInData data =
    { player = migratePlayer identity data.player
    , otherPlayers = List.map migrateOtherPlayer data.otherPlayers
    }


migrateWorldLoggedOutData : WOld.WorldLoggedOutData -> WNew.WorldLoggedOutData
migrateWorldLoggedOutData data =
    { players = List.map migrateOtherPlayer data.players }


migrateSPlayer : POld.SPlayer -> PNew.SPlayer
migrateSPlayer old =
    { name = old.name
    , password = migratePassword old.password
    , hp = old.hp
    , maxHp = old.maxHp
    , xp = old.xp
    , special = old.special
    , availableSpecial = old.availableSpecial
    , caps = old.caps
    , ap = old.ap
    , wins = old.wins
    , losses = old.losses
    }


migratePlayer : (a -> b) -> POld.Player a -> PNew.Player b
migratePlayer fn old =
    case old of
        POld.NeedsCharCreated auth ->
            PNew.NeedsCharCreated ANew.init

        POld.Player player ->
            PNew.Player <| fn player


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    case old of
        Old.GetZone zone ->
            MsgMigrated ( New.GotZone zone, Cmd.none )

        _ ->
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
