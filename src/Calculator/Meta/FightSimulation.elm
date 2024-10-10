module Calculator.Meta.FightSimulation exposing (generator)

import Calculator.Meta.Individual exposing (Individual)
import Data.Fight.Generator as FightGen
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Perk exposing (Perk)
import Data.Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp
import Dict exposing (Dict)
import Logic
import Random
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import Time


generator : Individual -> Individual -> Random.Generator FightGen.Fight
generator individual1 individual2 =
    let
        player1 : SPlayerSubset
        player1 =
            individualToPlayer True individual1

        player2 : SPlayerSubset
        player2 =
            individualToPlayer False individual2
    in
    FightGen.generator
        { attacker = FightGen.playerOpponent player1
        , target = FightGen.playerOpponent player2
        , currentTime = Time.millisToPosix 0 -- Use a constant time for consistency
        }


type alias SPlayerSubset =
    { name : String
    , special : Special
    , perks : SeqDict Perk Int
    , traits : SeqSet Trait
    , hp : Int
    , maxHp : Int
    , xp : Int
    , caps : Int
    , addedSkillPercentages : SeqDict Skill Int
    , equippedArmor : Maybe Item
    , equippedWeapon : Maybe Item
    , preferredAmmo : Maybe ItemKind.Kind
    , fightStrategy : FightStrategy
    , items : Dict Item.Id Item
    }


individualToPlayer : Bool -> Individual -> SPlayerSubset
individualToPlayer isFirst individual =
    let
        xp =
            0

        level =
            Data.Xp.currentLevel xp

        hp =
            Logic.hitpoints
                { level = level
                , special = individual.special
                , lifegiverPerkRanks = 0
                }

        addedSkillPercentages =
            Logic.addedSkillPercentages
                { taggedSkills = individual.taggedSkills
                , hasGiftedTrait = SeqSet.member Trait.Gifted individual.traits
                }
    in
    { name =
        if isFirst then
            "P1"

        else
            "P2"
    , xp = xp
    , hp = hp
    , maxHp = hp
    , traits = individual.traits
    , perks = SeqDict.empty
    , special = individual.special
    , caps = 0
    , items = Dict.empty
    , equippedArmor = Nothing
    , equippedWeapon = Nothing
    , preferredAmmo = Nothing
    , addedSkillPercentages = addedSkillPercentages
    , fightStrategy = individual.fightStrategy
    }
