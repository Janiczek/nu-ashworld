module Evergreen.V137.Data.Message exposing (..)

import Evergreen.V137.Data.Fight
import Evergreen.V137.Data.Player.PlayerName
import Evergreen.V137.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V137.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V137.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V137.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V137.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V137.Data.Quest.Quest
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V137.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V137.Data.Quest.GlobalReward
        }
    | OthersCompletedAQuest
        { quest : Evergreen.V137.Data.Quest.Quest
        , globalRewards : List Evergreen.V137.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
