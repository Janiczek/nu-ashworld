module TestHelpers exposing (..)

import AssocList as Dict_
import AssocSet as Set_
import Data.Enemy as Enemy
import Data.Fight as Fight
    exposing
        ( Opponent
        , OpponentType
        )
import Data.Item as Item
import Data.Perk as Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Fuzz exposing (Fuzzer)
import Fuzz.Extra as Fuzz
import Logic exposing (AttackStats)
import Maybe.Extra as Maybe
import Random
import Time exposing (Posix)


oneOfValues : List a -> Fuzzer a
oneOfValues values =
    Fuzz.oneOf <| List.map Fuzz.constant values


playerNameFuzzer : Fuzzer PlayerName
playerNameFuzzer =
    oneOfValues
        [ "janiczek"
        , "djetelina"
        , "Athano"
        , "somebodyelse"
        ]


opponentTypeFuzzer : Fuzzer OpponentType
opponentTypeFuzzer =
    Fuzz.oneOf
        [ Fuzz.map Fight.Npc enemyTypeFuzzer
        , Fuzz.map Fight.Player playerNameFuzzer
        ]


hpFuzzer : Fuzzer Int
hpFuzzer =
    Fuzz.intRange 0 200


maxHpFuzzer : Fuzzer Int
maxHpFuzzer =
    Fuzz.intRange 1 200


maxApFuzzer : Fuzzer Int
maxApFuzzer =
    Fuzz.intRange 5 20


sequenceFuzzer : Fuzzer Int
sequenceFuzzer =
    Fuzz.intRange 1 20


opponentFuzzer : Fuzzer Opponent
opponentFuzzer =
    Fuzz.constant Opponent
        |> Fuzz.andMap opponentTypeFuzzer
        |> Fuzz.andMap hpFuzzer
        |> Fuzz.andMap maxHpFuzzer
        |> Fuzz.andMap maxApFuzzer
        |> Fuzz.andMap sequenceFuzzer
        |> Fuzz.andMap traitsFuzzer
        |> Fuzz.andMap perksFuzzer
        |> Fuzz.andMap capsFuzzer
        |> Fuzz.andMap equippedArmorKindFuzzer
        |> Fuzz.andMap naturalArmorClassFuzzer
        |> Fuzz.andMap attackStatsFuzzer
        |> Fuzz.andMap addedSkillPercentagesFuzzer
        |> Fuzz.andMap specialFuzzer
        -- sanitization:
        |> Fuzz.map (\o -> { o | hp = min o.hp o.maxHp })


posixFuzzer : Fuzzer Posix
posixFuzzer =
    -- 2000/01/01 .. 2021/01/01
    Fuzz.intRange 946684800000 1609459200000
        |> Fuzz.map Time.millisToPosix


randomSeedFuzzer : Fuzzer Random.Seed
randomSeedFuzzer =
    Fuzz.intRange Random.minInt Random.maxInt
        |> Fuzz.map Random.initialSeed


enemyTypeFuzzer : Fuzzer Enemy.Type
enemyTypeFuzzer =
    oneOfValues Enemy.allTypes


traitsFuzzer : Fuzzer (Set_.Set Trait)
traitsFuzzer =
    Trait.all
        |> List.map (Fuzz.maybe << Fuzz.constant)
        |> Fuzz.sequence
        |> Fuzz.map
            (\maybes ->
                maybes
                    |> Maybe.values
                    |> List.take 2
                    |> Set_.fromList
            )


perksFuzzer : Fuzzer (Dict_.Dict Perk Int)
perksFuzzer =
    Perk.all
        |> List.map
            (\perk ->
                Fuzz.maybe <|
                    Fuzz.map
                        (Tuple.pair perk)
                        (Fuzz.intRange 1 (Perk.maxRank perk))
            )
        |> Fuzz.sequence
        |> Fuzz.map
            (\maybes ->
                maybes
                    |> Maybe.values
                    |> List.foldl
                        (\( perk, rank ) ( accAvailableRanks, accResult ) ->
                            if accAvailableRanks <= 0 then
                                ( accAvailableRanks, accResult )

                            else
                                let
                                    ranksUsed =
                                        min accAvailableRanks rank
                                in
                                ( accAvailableRanks - ranksUsed
                                , ( perk, ranksUsed ) :: accResult
                                )
                        )
                        ( 33, [] )
                    |> Tuple.second
                    |> Dict_.fromList
            )


capsFuzzer : Fuzzer Int
capsFuzzer =
    Fuzz.intRange 0 99999


equippedArmorKindFuzzer : Fuzzer (Maybe Item.Kind)
equippedArmorKindFuzzer =
    Fuzz.maybe armorKindFuzzer


armorKindFuzzer : Fuzzer Item.Kind
armorKindFuzzer =
    Item.allKinds
        |> List.filter (\kind -> Item.equippableType kind == Just Item.Armor)
        |> oneOfValues


naturalArmorClassFuzzer : Fuzzer Int
naturalArmorClassFuzzer =
    Fuzz.intRange 0 10


attackStatsFuzzer : Fuzzer AttackStats
attackStatsFuzzer =
    Fuzz.constant AttackStats
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 30)
        |> Fuzz.andMap (Fuzz.intRange 0 40)
        -- sanitize:
        |> Fuzz.map (\s -> { s | maxDamage = max s.minDamage s.maxDamage })


addedSkillPercentagesFuzzer : Fuzzer (Dict_.Dict Skill Int)
addedSkillPercentagesFuzzer =
    Skill.all
        |> List.map
            (\skill ->
                Fuzz.map
                    (Tuple.pair skill)
                    (Fuzz.intRange -10 300)
            )
        |> Fuzz.sequence
        |> Fuzz.map Dict_.fromList


specialFuzzer : Fuzzer Special
specialFuzzer =
    Fuzz.constant Special
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
        |> Fuzz.andMap (Fuzz.intRange 1 10)
