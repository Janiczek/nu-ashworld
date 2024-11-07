module Evergreen.V132.Data.Message exposing (..)

import Evergreen.V132.Data.Fight
import Evergreen.V132.Data.Player.PlayerName
import Evergreen.V132.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V132.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V132.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V132.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V132.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V132.Data.Quest.Quest
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V132.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V132.Data.Quest.GlobalReward
        }
    | OthersCompletedAQuest
        { quest : Evergreen.V132.Data.Quest.Quest
        , globalRewards : List Evergreen.V132.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
