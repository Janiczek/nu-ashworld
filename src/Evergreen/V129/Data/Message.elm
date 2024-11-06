module Evergreen.V129.Data.Message exposing (..)

import Evergreen.V129.Data.Fight
import Evergreen.V129.Data.Player.PlayerName
import Evergreen.V129.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V129.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V129.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V129.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V129.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V129.Data.Quest.Name
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V129.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V129.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
