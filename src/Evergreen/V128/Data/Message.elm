module Evergreen.V128.Data.Message exposing (..)

import Evergreen.V128.Data.Fight
import Evergreen.V128.Data.Player.PlayerName
import Evergreen.V128.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V128.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V128.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V128.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V128.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V128.Data.Quest.Name
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V128.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V128.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
