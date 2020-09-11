module Types.Player exposing
    ( COtherPlayer
    , CPlayer
    , SPlayer
    , generator
    , serverToClient
    , serverToClientOther
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
    }


type alias COtherPlayer =
    { hp : Int
    , level : Level
    , name : String
    }


type alias SPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : String
    , special : Special
    , availableSpecial : Int
    }


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , special = p.special
    , availableSpecial = p.availableSpecial
    }


serverToClientOther : SPlayer -> COtherPlayer
serverToClientOther p =
    { hp = p.hp
    , level = Xp.xpToLevel p.xp
    , name = p.name
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
