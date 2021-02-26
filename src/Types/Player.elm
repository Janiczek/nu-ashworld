module Types.Player exposing
    ( COtherPlayer
    , CPlayer
    , SPlayer
    , generator
    , serverToClient
    , serverToClientOther
    , clientToClientOther
    )

import Random exposing (Generator)
import Random.Extra
import Types.Special exposing (Special)
import Types.Xp as Xp exposing (Level, Xp)


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : String
    , special : Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias COtherPlayer =
    { hp : Int
    , level : Level
    , name : String
    , wins : Int
    , losses : Int
    }


type alias SPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : String
    , special : Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , special = p.special
    , availableSpecial = p.availableSpecial
    , cash = p.cash
    , ap = p.ap
    , wins = p.wins
    , losses = p.losses
    }


serverToClientOther : SPlayer -> COtherPlayer
serverToClientOther p =
    { hp = p.hp
    , level = Xp.xpToLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    }

clientToClientOther : CPlayer -> COtherPlayer
clientToClientOther p =
    { hp = p.hp
    , level = Xp.xpToLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    }

generator : Generator SPlayer
generator =
    Random.int 10 100
        |> Random.andThen
            (\maxHp ->
                Random.constant SPlayer
                    |> Random.Extra.andMap (Random.int 0 maxHp)
                    |> Random.Extra.andMap (Random.constant maxHp)
                    |> Random.Extra.andMap (Random.int 0 10000)
                    |> Random.Extra.andMap nameGenerator
                    |> Random.Extra.andMap specialGenerator
                    |> Random.Extra.andMap (Random.int 0 15)
                    |> Random.Extra.andMap (Random.int 1 9999)
                    |> Random.Extra.andMap (Random.int 1 20)
                    |> Random.Extra.andMap (Random.int 0 300)
                    |> Random.Extra.andMap (Random.int 0 300)
            )


nameGenerator : Generator String
nameGenerator =
    Random.uniform
        "Killian95"
        [ "Falloutma111"
        , "DJetelina"
        , "M Janiczek"
        , "Zzzzzzzaros"
        , "Willdy Mage"
        , "WildRanger"
        , "iScr3Am"
        ]


specialGenerator : Generator Special
specialGenerator =
    Random.constant Special
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
        |> Random.Extra.andMap (Random.int 1 10)
