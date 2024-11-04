module Evergreen.V124.Data.Message exposing (..)

import Evergreen.V124.Data.Fight
import Evergreen.V124.Data.Player.PlayerName
import Evergreen.V124.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V124.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V124.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V124.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V124.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V124.Data.Quest.Name
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V124.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V124.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
