module Evergreen.Migrate.V19 exposing (..)

import Dict
import Evergreen.V18.Data.Auth as AOld
import Evergreen.V18.Data.HealthStatus as HOld
import Evergreen.V18.Data.Player as POld
import Evergreen.V18.Data.World as WOld
import Evergreen.V18.Types as Old
import Evergreen.V19.Data.Auth as ANew
import Evergreen.V19.Data.HealthStatus as HNew
import Evergreen.V19.Data.NewChar as NNew
import Evergreen.V19.Data.Player as PNew
import Evergreen.V19.Data.World as WNew
import Evergreen.V19.Frontend.Route as RNew
import Evergreen.V19.Types as New
import Lamdera.Migrations exposing (..)


migratePassword : AOld.Password AOld.Verified -> ANew.Password ANew.Verified
migratePassword old =
    ANew.Password <| AOld.unwrap old


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
          , route = RNew.News
          , world = migrateWorld old.world
          , newChar = NNew.init
          , authError = Nothing
          }
        , Cmd.none
        )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { players = Dict.map (always (migratePlayer migrateSPlayer)) old.players
          , loggedInPlayers = old.loggedInPlayers
          , nextWantedTick = Nothing
          }
        , Cmd.none
        )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgOldValueIgnored


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgOldValueIgnored
