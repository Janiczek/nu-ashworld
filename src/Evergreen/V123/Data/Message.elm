module Evergreen.V123.Data.Message exposing (..)

import Evergreen.V123.Data.Fight
import Evergreen.V123.Data.Player.PlayerName
import Evergreen.V123.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V123.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V123.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V123.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V123.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V123.Data.Quest.Name
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V123.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V123.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
