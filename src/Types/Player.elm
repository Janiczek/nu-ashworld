module Types.Player exposing
    ( COtherPlayer
    , CPlayer
    , PlayerName
    , SPlayer
    , clientToClientOther
    , generator
    , serverToClient
    , serverToClientOther
    )

import Random exposing (Generator)
import Random.Extra as Random
import Set exposing (Set)
import Types.Special exposing (Special)
import Types.Xp as Xp exposing (Level, Xp)


type alias PlayerName =
    String


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : PlayerName
    , special : Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias COtherPlayer =
    { hp : Int
    , level : Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    }


type alias SPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : PlayerName
    , special : Special
    , availableSpecial : Int
    , caps : Int
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
    , caps = p.caps
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


generator : Set PlayerName -> Generator SPlayer
generator existingNames =
    Random.int 10 100
        |> Random.andThen
            (\maxHp ->
                Random.constant SPlayer
                    |> Random.andMap (Random.int 0 maxHp)
                    |> Random.andMap (Random.constant maxHp)
                    |> Random.andMap (Random.int 0 10000)
                    |> Random.andMap (nameGenerator existingNames)
                    |> Random.andMap specialGenerator
                    |> Random.andMap (Random.int 0 15)
                    |> Random.andMap (Random.int 1 9999)
                    |> Random.andMap (Random.int 1 20)
                    |> Random.andMap (Random.int 0 300)
                    |> Random.andMap (Random.int 0 300)
            )


nameGenerator : Set PlayerName -> Generator PlayerName
nameGenerator existingNames =
    let
        initial =
            Random.uniform
                "Killian95"
                [ "Falloutma111"
                , "DJetelina"
                , "M Janiczek"
                , "Zzzzzzzaros"
                , "Willdy Mage"
                , "WildRanger"
                , "iScrE4m"
                ]

        enforceUnique : PlayerName -> Generator PlayerName
        enforceUnique name =
            if Set.member name existingNames then
                Random.int 0 9
                    |> Random.map
                        (\n ->
                            name ++ String.fromInt n
                        )
                    |> Random.andThen enforceUnique

            else
                Random.constant name
    in
    initial
        |> Random.andThen enforceUnique


specialGenerator : Generator Special
specialGenerator =
    Random.constant Special
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
        |> Random.andMap (Random.int 1 10)
