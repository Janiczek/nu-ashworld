module TestHelpers exposing (..)

import Data.Enemy as Enemy
import Data.Fight as Fight
    exposing
        ( Opponent
        , OpponentType
        , PlayerOpponent
        )
import Data.Fight.AttackStyle exposing (AttackStyle(..))
import Data.Fight.ShotType as ShotType
import Data.FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , IfData
        , Operator(..)
        , OperatorData
        , Value(..)
        )
import Data.Item as Item exposing (Item)
import Data.Perk as Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Logic exposing (AttackStats)
import Maybe.Extra as Maybe
import Parser as P exposing (Parser, Problem(..))
import Random
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import String.Extra as String
import Test exposing (Test)
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
        , Fuzz.map Fight.Player playerOpponentFuzzer
        ]


playerOpponentFuzzer : Fuzzer PlayerOpponent
playerOpponentFuzzer =
    Fuzz.constant PlayerOpponent
        |> Fuzz.andMap playerNameFuzzer
        |> Fuzz.andMap xpFuzzer


xpFuzzer : Fuzzer Int
xpFuzzer =
    Fuzz.intRange 0 4851000


hpFuzzer : Fuzzer Int
hpFuzzer =
    Fuzz.intRange 1 200


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
        |> Fuzz.andMap itemsFuzzer
        |> Fuzz.andMap dropsFuzzer
        |> Fuzz.andMap equippedArmorKindFuzzer
        |> Fuzz.andMap equippedWeaponKindFuzzer
        |> Fuzz.andMap naturalArmorClassFuzzer
        |> Fuzz.andMap attackStatsFuzzer
        |> Fuzz.andMap addedSkillPercentagesFuzzer
        |> Fuzz.andMap specialFuzzer
        |> Fuzz.andMap (fightStrategyFuzzer { maxDepth = 5 })
        -- sanitization:
        |> Fuzz.map (\o -> { o | hp = min o.hp o.maxHp })


itemsFuzzer : Fuzzer (Dict Item.Id Item)
itemsFuzzer =
    Fuzz.list itemFuzzer
        |> Fuzz.map
            (List.map (\item -> ( item.id, item ))
                >> Dict.fromList
            )


fightStrategyFuzzer : { maxDepth : Int } -> Fuzzer FightStrategy
fightStrategyFuzzer r =
    if r.maxDepth == 0 then
        Fuzz.map Command commandFuzzer

    else
        Fuzz.oneOf
            [ Fuzz.map If (ifDataFuzzer r)
            , Fuzz.map Command commandFuzzer
            ]


commandFuzzer : Fuzzer Command
commandFuzzer =
    Fuzz.oneOf
        [ Fuzz.map Attack attackStyleFuzzer
        , Fuzz.constant AttackRandomly
        , Fuzz.map Heal healingItemKindFuzzer
        , Fuzz.constant HealWithAnything
        , Fuzz.constant MoveForward
        , Fuzz.constant DoWhatever
        , Fuzz.constant SkipTurn
        ]


conditionFuzzer : { maxDepth : Int } -> Fuzzer Condition
conditionFuzzer r =
    if r.maxDepth <= 0 then
        Fuzz.map Operator operatorDataFuzzer

    else
        let
            conditionFuzzer_ =
                conditionFuzzer { maxDepth = r.maxDepth - 1 }
        in
        Fuzz.oneOf
            [ Fuzz.map2 Or conditionFuzzer_ conditionFuzzer_
            , Fuzz.map2 And conditionFuzzer_ conditionFuzzer_
            , Fuzz.map Operator operatorDataFuzzer
            , Fuzz.constant OpponentIsPlayer
            , Fuzz.constant OpponentIsNPC
            ]


operatorFuzzer : Fuzzer Operator
operatorFuzzer =
    [ LT_
    , LTE
    , EQ_
    , NE
    , GTE
    , GT_
    ]
        |> List.map Fuzz.constant
        |> Fuzz.oneOf


ifDataFuzzer : { maxDepth : Int } -> Fuzzer IfData
ifDataFuzzer r =
    Fuzz.constant IfData
        |> Fuzz.andMap (conditionFuzzer { maxDepth = 3 })
        |> Fuzz.andMap (fightStrategyFuzzer { maxDepth = r.maxDepth - 1 })
        |> Fuzz.andMap (fightStrategyFuzzer { maxDepth = r.maxDepth - 1 })


operatorDataFuzzer : Fuzzer OperatorData
operatorDataFuzzer =
    Fuzz.constant OperatorData
        |> Fuzz.andMap valueFuzzer
        |> Fuzz.andMap operatorFuzzer
        |> Fuzz.andMap valueFuzzer


valueFuzzer : Fuzzer Value
valueFuzzer =
    Fuzz.oneOf
        [ Fuzz.constant MyHP
        , Fuzz.constant MyMaxHP
        , Fuzz.constant MyAP
        , Fuzz.map MyItemCount healingItemKindFuzzer
        , Fuzz.constant MyHealingItemCount
        , Fuzz.map ItemsUsed healingItemKindFuzzer
        , Fuzz.constant HealingItemsUsed
        , Fuzz.map ChanceToHit attackStyleFuzzer
        , Fuzz.map RangeNeeded attackStyleFuzzer
        , Fuzz.constant Distance
        , Fuzz.map Number Fuzz.int
        ]


attackStyleFuzzer : Fuzzer AttackStyle
attackStyleFuzzer =
    Fuzz.oneOfValues
        (ShootBurst
            :: UnarmedUnaimed
            :: MeleeUnaimed
            :: ThrowUnaimed
            :: ShootSingleUnaimed
            :: List.concatMap (\toAimed -> List.map toAimed ShotType.allAimed)
                [ UnarmedAimed
                , MeleeAimed
                , ThrowAimed
                , ShootSingleAimed
                ]
        )


itemKindFuzzer : Fuzzer Item.Kind
itemKindFuzzer =
    Item.all
        |> List.map Fuzz.constant
        |> Fuzz.oneOf


healingItemKindFuzzer : Fuzzer Item.Kind
healingItemKindFuzzer =
    Item.allHealing
        |> List.map Fuzz.constant
        |> Fuzz.oneOf


mostlyHealingItemKindFuzzer : Fuzzer Item.Kind
mostlyHealingItemKindFuzzer =
    Fuzz.frequency
        [ ( 9, healingItemKindFuzzer )
        , ( 1, itemKindFuzzer )
        ]


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


traitsFuzzer : Fuzzer (SeqSet Trait)
traitsFuzzer =
    Trait.all
        |> List.map (Fuzz.maybe << Fuzz.constant)
        |> Fuzz.sequence
        |> Fuzz.map
            (\maybes ->
                maybes
                    |> Maybe.values
                    |> List.take 2
                    |> SeqSet.fromList
            )


perksFuzzer : Fuzzer (SeqDict Perk Int)
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
                    |> SeqDict.fromList
            )


capsFuzzer : Fuzzer Int
capsFuzzer =
    Fuzz.intRange 0 99999


dropsFuzzer : Fuzzer (List Item)
dropsFuzzer =
    Fuzz.list itemFuzzer


equippedArmorKindFuzzer : Fuzzer (Maybe Item.Kind)
equippedArmorKindFuzzer =
    Fuzz.maybe armorKindFuzzer


equippedWeaponKindFuzzer : Fuzzer (Maybe Item.Kind)
equippedWeaponKindFuzzer =
    Fuzz.maybe weaponKindFuzzer


armorKindFuzzer : Fuzzer Item.Kind
armorKindFuzzer =
    Item.all
        |> List.filter Item.isArmor
        |> oneOfValues


weaponKindFuzzer : Fuzzer Item.Kind
weaponKindFuzzer =
    Item.all
        |> List.filter Item.isWeapon
        |> oneOfValues


itemFuzzer : Fuzzer Item
itemFuzzer =
    Fuzz.map3 Item
        (Fuzz.intRange 0 99999)
        (oneOfValues Item.all)
        (Fuzz.intRange 1 500)


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


addedSkillPercentagesFuzzer : Fuzzer (SeqDict Skill Int)
addedSkillPercentagesFuzzer =
    Skill.all
        |> List.map
            (\skill ->
                Fuzz.map
                    (Tuple.pair skill)
                    (Fuzz.intRange -10 300)
            )
        |> Fuzz.sequence
        |> Fuzz.map SeqDict.fromList


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


parserTest : String -> Parser a -> List ( String, String, Maybe a ) -> Test
parserTest label parser examples =
    let
        runTest ( description, input, output ) =
            Test.test description <|
                \() ->
                    input
                        |> P.run parser
                        |> expectEqualParseResult input output
    in
    Test.describe label <|
        List.map runTest examples


expectEqualParseResult :
    String
    -> Maybe a
    -> Result (List P.DeadEnd) a
    -> Expectation
expectEqualParseResult input expected actual =
    case ( actual, expected ) of
        ( Err _, Nothing ) ->
            Expect.pass

        ( Err deadEnds, Just _ ) ->
            Expect.fail
                (String.join "\n"
                    (input
                        :: "===>"
                        :: "Err"
                        :: List.map deadEndToString deadEnds
                    )
                )

        ( Ok actual_, Nothing ) ->
            Expect.fail
                (String.join "\n"
                    [ input, "===> should have failed but parsed into ==>", "Ok", "    " ++ Debug.toString actual_ ]
                )

        ( Ok actual_, Just expected_ ) ->
            actual_
                |> Expect.equal expected_


deadEndToString : P.DeadEnd -> String
deadEndToString deadend =
    problemToString deadend.problem ++ " at row " ++ String.fromInt deadend.row ++ ", col " ++ String.fromInt deadend.col


problemToString : P.Problem -> String
problemToString p =
    case p of
        Expecting s ->
            "expecting '" ++ s ++ "'"

        ExpectingInt ->
            "expecting int"

        ExpectingHex ->
            "expecting hex"

        ExpectingOctal ->
            "expecting octal"

        ExpectingBinary ->
            "expecting binary"

        ExpectingFloat ->
            "expecting float"

        ExpectingNumber ->
            "expecting number"

        ExpectingVariable ->
            "expecting variable"

        ExpectingSymbol s ->
            "expecting symbol '" ++ s ++ "'"

        ExpectingKeyword s ->
            "expecting keyword '" ++ s ++ "'"

        ExpectingEnd ->
            "expecting end"

        UnexpectedChar ->
            "unexpected char"

        Problem s ->
            "problem " ++ s

        BadRepeat ->
            "bad repeat"


multilineInput : String -> String
multilineInput string =
    string
        |> String.unindent
        |> removeNewlinesAtEnds


removeNewlinesAtEnds : String -> String
removeNewlinesAtEnds string =
    if String.startsWith "\n" string then
        removeNewlinesAtEnds (String.dropLeft 1 string)

    else if String.endsWith "\n" string then
        removeNewlinesAtEnds (String.dropRight 1 string)

    else
        string
