module Data.Fight.GeneratorTest exposing (suite)

import Data.Fight as Fight exposing (Action, Opponent, Who)
import Data.Fight.AttackStyle as AttackStyle
import Data.Fight.Generator exposing (Fight)
import Data.FightStrategy exposing (..)
import Data.Item as Item
import Data.Special as Special
import Dict
import Expect
import Fuzz exposing (Fuzzer)
import Logic
import Random
import SeqDict
import SeqSet
import Test exposing (Test)
import TestHelpers exposing (..)
import Time


suite : Test
suite =
    Test.describe "Data.Fight.Generator"
        [ damageNeverNegative
        , meleeAttackAtDistance2WithRange2
        ]


damageNeverNegative : Test
damageNeverNegative =
    Test.fuzz randomFightFuzzer "Damage in fight should never be negative" <|
        \fight ->
            fight.fightInfo.log
                |> List.map (Tuple.second >> Fight.attackDamage)
                |> List.filter (\damage -> damage < 0)
                |> List.isEmpty
                |> Expect.equal True
                |> Expect.onFail "Expected the list of negative damage actions in a fight to be empty"


meleeAttackAtDistance2WithRange2 : Test
meleeAttackAtDistance2WithRange2 =
    let
        strategy : FightStrategy
        strategy =
            If
                { condition = Operator { lhs = Distance, op = GT_, rhs = Number 2 }
                , then_ = Command MoveForward
                , else_ = Command AttackRandomly
                }
    in
    Test.test "Melee combat at distance 2 with weapon with range 2 should work" <|
        \() ->
            let
                opponent =
                    { type_ = Fight.Player { name = "Opponent", xp = 0 }, hp = 100, maxHp = 100, maxAp = 10, sequence = 5, traits = SeqSet.empty, perks = SeqDict.empty, caps = 50, items = Dict.empty, drops = [], equippedArmor = Nothing, equippedWeapon = Just Item.SuperSledge, equippedAmmo = Nothing, naturalArmorClass = 5, attackStats = Logic.unarmedAttackStats { special = Special.init, unarmedSkill = 50, traits = SeqSet.empty, perks = SeqDict.empty, level = 1, npcExtraBonus = 0 }, addedSkillPercentages = SeqDict.empty, special = Special.init, fightStrategy = strategy }

                result =
                    Random.step
                        (Data.Fight.Generator.attack_
                            Fight.Attacker
                            { distanceHexes = 2
                            , attacker = opponent
                            , attackerAp = 10
                            , attackerItemsUsed = SeqDict.empty
                            , target = opponent
                            , targetAp = 10
                            , targetItemsUsed = SeqDict.empty
                            , reverseLog = []
                            , actionsTaken = 0
                            }
                            AttackStyle.MeleeUnaimed
                            4
                        )
                        (Random.initialSeed 3)
                        |> Tuple.first
            in
            result.ranCommandSuccessfully
                |> Expect.equal True
                |> Expect.onFail "Expected the attack to succeed"


fightFuzzer :
    { attacker : Fuzzer Opponent
    , target : Fuzzer Opponent
    }
    -> Fuzzer Fight
fightFuzzer r =
    Fuzz.constant
        (\a t currentTime seed ->
            Random.step
                (Data.Fight.Generator.generator
                    { attacker = a
                    , target = t
                    , currentTime = currentTime
                    }
                )
                seed
        )
        |> Fuzz.andMap r.attacker
        |> Fuzz.andMap r.target
        |> Fuzz.andMap posixFuzzer
        |> Fuzz.andMap randomSeedFuzzer
        |> Fuzz.map Tuple.first


randomFightFuzzer : Fuzzer Fight
randomFightFuzzer =
    fightFuzzer
        { attacker = opponentFuzzer
        , target = opponentFuzzer
        }



-- TODO items in inventory decrease after finished fight where they were used
-- TODO thrown items decrease after throwing
-- TODO ammo decreases after using
-- TODO fallback ammo used
-- TODO unarmed combat after all ammo used
