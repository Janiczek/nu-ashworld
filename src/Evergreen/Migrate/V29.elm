module Evergreen.Migrate.V29 exposing (..)

import Dict
import Evergreen.V27.Data.Auth as AOld
import Evergreen.V27.Data.Fight as FOld
import Evergreen.V27.Data.HealthStatus as HOld
import Evergreen.V27.Data.Player as POld
import Evergreen.V27.Data.World as WOld
import Evergreen.V27.Frontend.Route as ROld
import Evergreen.V27.Types as Old
import Evergreen.V29.Data.Auth as ANew
import Evergreen.V29.Data.Fight as FNew
import Evergreen.V29.Data.HealthStatus as HNew
import Evergreen.V29.Data.Player as PNew
import Evergreen.V29.Data.World as WNew
import Evergreen.V29.Frontend.Route as RNew
import Evergreen.V29.Types as New
import Lamdera.Migrations exposing (..)
import Set


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


migratePlayer : (a -> b) -> POld.Player a -> PNew.Player b
migratePlayer fn old =
    case old of
        POld.NeedsCharCreated auth ->
            PNew.NeedsCharCreated ANew.init

        POld.Player player ->
            PNew.Player <| fn player


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
    , location = old.location
    , knownMapTiles = old.knownMapTiles
    }


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


migrateWorldLoggedOutData : WOld.WorldLoggedOutData -> WNew.WorldLoggedOutData
migrateWorldLoggedOutData data =
    { players = List.map migrateOtherPlayer data.players }


migrateWorldLoggedInData : WOld.WorldLoggedInData -> WNew.WorldLoggedInData
migrateWorldLoggedInData data =
    { player = migratePlayer migrateCPlayer data.player
    , otherPlayers = List.map migrateOtherPlayer data.otherPlayers
    }


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
          , time = old.time
          , zone = old.zone
          , route = migrateRoute old.route
          , world = migrateWorld old.world
          , newChar = old.newChar
          , authError = old.authError
          , mapMouseCoords = Nothing
          }
        , Cmd.none
        )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { players = Dict.map (always (migratePlayer migrateSPlayer)) old.players
          , loggedInPlayers = old.loggedInPlayers
          , nextWantedTick = old.nextWantedTick
          }
        , Cmd.none
        )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    case old of
        Old.UrlClicked _ ->
            MsgUnchanged

        Old.UrlChanged _ ->
            MsgUnchanged

        Old.GoToRoute _ ->
            MsgUnchanged

        Old.Logout ->
            MsgUnchanged

        Old.Login ->
            MsgUnchanged

        Old.Register ->
            MsgUnchanged

        Old.NoOp ->
            MsgUnchanged

        Old.GotZone _ ->
            MsgUnchanged

        Old.GotTime _ ->
            MsgUnchanged

        Old.AskToFight _ ->
            MsgUnchanged

        Old.Refresh ->
            MsgUnchanged

        Old.AskToIncSpecial _ ->
            MsgUnchanged

        Old.SetAuthName _ ->
            MsgUnchanged

        Old.SetAuthPassword _ ->
            MsgUnchanged

        Old.CreateChar ->
            MsgUnchanged

        Old.NewCharIncSpecial _ ->
            MsgUnchanged

        Old.NewCharDecSpecial _ ->
            MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    case old of
        Old.LogMeIn _ ->
            MsgUnchanged

        Old.RegisterMe _ ->
            MsgUnchanged

        Old.CreateNewChar _ ->
            MsgUnchanged

        Old.LogMeOut ->
            MsgUnchanged

        Old.Fight _ ->
            MsgUnchanged

        Old.RefreshPlease ->
            MsgUnchanged

        Old.IncSpecial _ ->
            MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    case old of
        Old.Connected _ _ ->
            MsgUnchanged

        Old.Disconnected _ _ ->
            MsgUnchanged

        Old.GeneratedFight _ _ _ ->
            MsgUnchanged

        Old.Tick _ ->
            MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    case old of
        Old.YourCurrentWorld _ ->
            MsgUnchanged

        Old.CurrentWorld _ ->
            MsgUnchanged

        Old.YourFightResult _ ->
            MsgUnchanged

        Old.YoureLoggedIn _ ->
            MsgUnchanged

        Old.YoureRegistered _ ->
            MsgUnchanged

        Old.YouHaveCreatedChar _ ->
            MsgUnchanged

        Old.YoureLoggedOut _ ->
            MsgUnchanged

        Old.AuthError _ ->
            MsgUnchanged


migrateCPlayer : POld.CPlayer -> PNew.CPlayer
migrateCPlayer old =
    { name = old.name
    , hp = old.hp
    , maxHp = old.maxHp
    , xp = old.xp
    , special = old.special
    , availableSpecial = old.availableSpecial
    , caps = old.caps
    , ap = old.ap
    , wins = old.wins
    , losses = old.losses
    , location = old.location
    , knownMapTiles = old.knownMapTiles
    }
