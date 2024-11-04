module Evergreen.V125.Data.Message exposing (..)

import Evergreen.V125.Data.Fight
import Evergreen.V125.Data.Player.PlayerName
import Evergreen.V125.Data.Quest
import Time


type alias Id =
    Int


type Content
    = Welcome
    | YouAdvancedLevel
        { newLevel : Int
        }
    | YouWereAttacked
        { attacker : Evergreen.V125.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V125.Data.Fight.Info
        }
    | YouAttacked
        { target : Evergreen.V125.Data.Player.PlayerName.PlayerName
        , fightInfo : Evergreen.V125.Data.Fight.Info
        }
    | YouCompletedAQuest
        { quest : Evergreen.V125.Data.Quest.Name
        , xpReward : Int
        , playerReward : Maybe (List Evergreen.V125.Data.Quest.PlayerReward)
        , globalRewards : List Evergreen.V125.Data.Quest.GlobalReward
        }


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Time.Posix
    }
