module LogicTest exposing (test)

import Data.Fight.AttackStyle as AttackStyle
import Data.Special as Special
import Expect
import Logic
import SeqDict
import Test exposing (Test)


test : Test
test =
    Test.describe "Logic"
        [ Test.describe "chanceToHit"
            [ Test.test "Unarmed + good range" <|
                \() ->
                    Logic.chanceToHit
                        { attackerAddedSkillPercentages = SeqDict.empty
                        , attackerPerks = SeqDict.empty
                        , attackerSpecial = Special.init
                        , distanceHexes = 1
                        , equippedWeapon = Nothing
                        , equippedAmmo = Nothing
                        , targetArmorClass = 0
                        , attackStyle = AttackStyle.UnarmedUnaimed
                        }
                        |> Expect.greaterThan 0
            ]
        ]
