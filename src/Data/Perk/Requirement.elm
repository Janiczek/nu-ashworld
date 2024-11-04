module Data.Perk.Requirement exposing
    ( Requirement(..)
    , allApplicable
    , isApplicable
    , requirements
    )

import Data.Perk as Perk exposing (Perk(..))
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


type Requirement
    = ROneOf (List Requirement)
    | RLevel Int
    | RSpecial Special.Type Int
    | RSpecialLT Special.Type Int
    | RSkill Skill Int
    | RQuest Quest.Name


allApplicable :
    { r
        | level : Int
        , special : Special
        , addedSkillPercentages : SeqDict Skill Int
        , perks : SeqDict Perk Int
        , questsDone : SeqSet Quest.Name
    }
    ->
        { applicablePerks : List Perk
        , nonapplicablePerks : List Perk
        }
allApplicable r =
    let
        ( applicable, nonapplicable ) =
            Perk.all
                |> List.filter (\perk -> Perk.rank perk r.perks < Perk.maxRank perk)
                |> List.partition (isApplicable r)
    in
    { applicablePerks = applicable
    , nonapplicablePerks = nonapplicable
    }


isApplicable :
    { r
        | level : Int
        , special : Special
        , addedSkillPercentages : SeqDict Skill Int
        , questsDone : SeqSet Quest.Name
    }
    -> Perk
    -> Bool
isApplicable r perk =
    List.all (\req -> meetsRequirement req r) (requirements perk)


meetsRequirement :
    Requirement
    ->
        { r
            | level : Int
            , special : Special
            , addedSkillPercentages : SeqDict Skill Int
            , questsDone : SeqSet Quest.Name
        }
    -> Bool
meetsRequirement req r =
    case req of
        ROneOf reqs ->
            List.any (\req_ -> meetsRequirement req_ r) reqs

        RLevel lvl ->
            r.level >= lvl

        RSpecial special n ->
            Special.get special r.special >= n

        RSpecialLT special n ->
            Special.get special r.special < n

        RSkill skill n ->
            Skill.get r.special r.addedSkillPercentages skill >= n

        RQuest q ->
            SeqSet.member q r.questsDone


requirements : Perk -> List Requirement
requirements perk =
    case perk of
        EarlierSequence ->
            [ RLevel 3
            , RSpecial Special.Perception 6
            ]

        Tag ->
            [ RLevel 12
            ]

        Educated ->
            [ RLevel 6
            , RSpecial Special.Intelligence 6
            ]

        BonusHthDamage ->
            [ RLevel 3
            , RSpecial Special.Strength 6
            , RSpecial Special.Agility 6
            ]

        MasterTrader ->
            [ RLevel 12
            , RSpecial Special.Charisma 7
            , RSkill Skill.Barter 75
            ]

        NightVision ->
            [ RLevel 3
            , RSpecial Special.Perception 6
            ]

        Awareness ->
            [ RLevel 3
            , RSpecial Special.Perception 5
            ]

        CautiousNature ->
            [ RLevel 3
            , RSpecial Special.Perception 6
            ]

        Comprehension ->
            [ RLevel 3
            , RSpecial Special.Intelligence 6
            ]

        FasterHealing ->
            [ RLevel 3
            , RSpecial Special.Endurance 6
            ]

        HereAndNow ->
            [ RLevel 3
            ]

        Survivalist ->
            [ RLevel 3
            , RSpecial Special.Endurance 6
            , RSpecial Special.Intelligence 6
            , RSkill Skill.Outdoorsman 40
            ]

        GainStrength ->
            [ RLevel 12
            , RSpecialLT Special.Strength 10
            ]

        GainPerception ->
            [ RLevel 12
            , RSpecialLT Special.Perception 10
            ]

        GainEndurance ->
            [ RLevel 12
            , RSpecialLT Special.Endurance 10
            ]

        GainCharisma ->
            [ RLevel 12
            , RSpecialLT Special.Charisma 10
            ]

        GainIntelligence ->
            [ RLevel 12
            , RSpecialLT Special.Intelligence 10
            ]

        GainAgility ->
            [ RLevel 12
            , RSpecialLT Special.Agility 10
            ]

        GainLuck ->
            [ RLevel 12
            , RSpecialLT Special.Luck 10
            ]

        Sniper ->
            [ RLevel 24
            , RSpecial Special.Agility 8
            , RSpecial Special.Perception 8
            , RSkill Skill.SmallGuns 80
            ]

        Slayer ->
            [ RLevel 24
            , RSpecial Special.Agility 8
            , RSpecial Special.Strength 8
            , RSkill Skill.Unarmed 80
            ]

        MoreCriticals ->
            [ RLevel 6
            , RSpecial Special.Luck 6
            ]

        BetterCriticals ->
            [ RLevel 9
            , RSpecial Special.Luck 6
            , RSpecial Special.Perception 6
            , RSpecial Special.Agility 4
            ]

        SwiftLearner ->
            [ RLevel 3
            , RSpecial Special.Intelligence 4
            ]

        Thief ->
            [ RLevel 3
            ]

        Toughness ->
            [ RLevel 3
            , RSpecial Special.Endurance 6
            , RSpecial Special.Luck 6
            ]

        AdrenalineRush ->
            [ RLevel 6
            , RSpecialLT Special.Strength 10
            ]

        FortuneFinder ->
            [ RLevel 6
            , RSpecial Special.Luck 8
            ]

        Gambler ->
            [ RLevel 6
            , RSkill Skill.Gambling 50
            ]

        Negotiator ->
            [ RLevel 6
            , RSkill Skill.Barter 50
            , RSkill Skill.Speech 50
            ]

        Pathfinder ->
            [ RLevel 6
            , RSpecial Special.Endurance 6
            , RSkill Skill.Outdoorsman 40
            ]

        Ranger ->
            [ RLevel 6
            , RSpecial Special.Perception 6
            ]

        Salesman ->
            [ RLevel 6
            , RSkill Skill.Barter 50
            ]

        Dodger ->
            [ RLevel 9
            , RSpecial Special.Agility 6
            ]

        Speaker ->
            [ RLevel 9
            , RSkill Skill.Speech 50
            ]

        ActionBoy ->
            [ RLevel 12
            , RSpecial Special.Agility 5
            ]

        HthEvade ->
            [ RLevel 12
            , RSkill Skill.Unarmed 75
            ]

        Lifegiver ->
            [ RLevel 12
            , RSpecial Special.Endurance 4
            ]

        LivingAnatomy ->
            [ RLevel 12
            , RSkill Skill.Doctor 60
            ]

        MasterThief ->
            [ RLevel 12
            , RSkill Skill.Lockpick 50
            , RSkill Skill.Steal 50
            ]

        Medic ->
            [ RLevel 12
            , ROneOf
                [ RSkill Skill.FirstAid 40
                , RSkill Skill.Doctor 40
                ]
            ]

        MrFixit ->
            [ RLevel 12
            , ROneOf
                [ RSkill Skill.Science 40
                , RSkill Skill.Repair 40
                ]
            ]

        BonusHthAttacks ->
            [ RLevel 15
            , RSpecial Special.Agility 6
            ]

        BonusRateOfFire ->
            [ RLevel 15
            , RSpecial Special.Perception 6
            , RSpecial Special.Intelligence 6
            , RSpecial Special.Agility 7
            ]

        GeckoSkinning ->
            [ RQuest Quest.ToxicCavesRescueSmileyTrapper
            ]

        BonusRangedDamage ->
            [ RLevel 6
            , RSpecial Special.Agility 6
            , RSpecial Special.Luck 6
            ]

        QuickRecovery ->
            [ RLevel 6
            , RSpecial Special.Agility 5
            ]
