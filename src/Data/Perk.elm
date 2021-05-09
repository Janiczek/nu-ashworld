module Data.Perk exposing
    ( Perk(..)
    , all
    , allApplicable
    , decoder
    , encode
    , isApplicable
    , maxRank
    , name
    , rank
    )

import AssocList as Dict_
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE



{- TODO go through
   https://fallout.fandom.com/wiki/Fallout_2_perks
   and implement all missing and applicable
-}


type Perk
    = -- lvl 3
      BonusHthDamage
    | Awareness
    | CautiousNature
    | Comprehension
    | EarlierSequence
    | FasterHealing
      -- TODO Healer - needs usage of First Aid / Doctor skills
    | HereAndNow
      -- TODO Kama Sutra Master - probably not...
      -- TODO Night Vision - needs darkness tracked and to play a role in fights
      -- TODO Presence - would need dialog with NPCs
      -- TODO Quick Pockets - would need inventory handling in combat
      -- TODO Scout - what should it do in NuAshworld?
      -- TODO Smooth Talker - would need dialog with NPCs
      -- TODO Stonewall - would need knockback in combat
      -- TODO Strong Back - would need carry weight implemented
    | Survivalist
    | SwiftLearner
    | Thief
    | Toughness
      -- lvl 6
    | AdrenalineRush
      -- TODO Bonus Move -- would need move-only APs and some intelligent use of movement in combat
      -- TODO Bonus Ranged Damage -- would need ranged combat
    | Educated
      -- TODO Empathy -- would need dialogues
    | FortuneFinder
    | Gambler
      -- TODO Ghost -- would need darkness tracking
      -- TODO Harmless -- would need Karma (or maybe we can decide to ignore that req)
      -- TODO Heave Ho! -- would need ranged combat
      -- TODO Magnetic Personality -- would need party members
    | MoreCriticals
    | Negotiator
      -- TODO Pack Rat -- would need carry weight
    | Pathfinder
      -- TODO Quick Recovery -- would need knockdown effect implemented
      -- TODO Rad Resistance -- would need rad resistance stat tracked
    | Ranger
    | Salesman
      -- TODO Silent Running -- probably not applicable in the game? maybe with some sneak mechanics
      -- TODO Snakeater -- would need poinson resistance stat tracked
      -- lvl 9
    | BetterCriticals
      -- TODO Demolition Expert -- would need traps implemented
    | Dodger
      -- TODO Explorer -- probably not applicable, or perhaps might give x% chance that wandering or fighting won't consume a tick?
      -- TODO Karma Beacon -- would need karma tracked
      -- TODO Light Step -- would need traps implemented
      -- TODO Mutate -- just a bit tricky to implement (char screen forcing player to choose one)
      -- TODO Mysterious Stranger -- would need combat to allow more than 2 opponents
      -- TODO Pyromaniac -- would need fire ranged combat
      -- TODO Scrounger -- would need ammo drops from combat
      -- TODO Sharpshooter -- would need ranged combat
    | Speaker
      -- lvl 12
    | ActionBoy
      -- TODO Cult of Personality -- probably not applicable (or would need quests)
    | GainStrength
    | GainPerception
    | GainEndurance
    | GainCharisma
    | GainIntelligence
    | GainAgility
    | GainLuck
    | HthEvade
    | Lifegiver
    | LivingAnatomy
    | MasterThief
    | MasterTrader
    | Medic
    | Tag
      -- lvl 24
    | Slayer


all : List Perk
all =
    [ AdrenalineRush
    , ActionBoy
    , Awareness
    , BetterCriticals
    , BonusHthDamage
    , CautiousNature
    , Comprehension
    , Dodger
    , EarlierSequence
    , Educated
    , FasterHealing
    , FortuneFinder
    , GainAgility
    , GainCharisma
    , GainEndurance
    , GainIntelligence
    , GainLuck
    , GainPerception
    , GainStrength
    , Gambler
    , HereAndNow
    , HthEvade
    , Lifegiver
    , LivingAnatomy
    , MasterThief
    , MasterTrader
    , Medic
    , MoreCriticals
    , Negotiator
    , Pathfinder
    , Ranger
    , Salesman
    , Slayer
    , Speaker
    , Survivalist
    , SwiftLearner
    , Tag
    , Thief
    , Toughness
    ]


name : Perk -> String
name perk =
    case perk of
        EarlierSequence ->
            "Earlier Sequence"

        Tag ->
            "Tag!"

        Educated ->
            "Educated"

        BonusHthDamage ->
            "Bonus HtH Damage"

        MasterTrader ->
            "Master Trader"

        Awareness ->
            "Awareness"

        CautiousNature ->
            "Cautious Nature"

        Comprehension ->
            "Comprehension"

        FasterHealing ->
            "Faster Healing"

        HereAndNow ->
            "Here and Now"

        Survivalist ->
            "Survivalist"

        GainStrength ->
            "Gain Strength"

        GainPerception ->
            "Gain Perception"

        GainEndurance ->
            "Gain Endurance"

        GainCharisma ->
            "Gain Charisma"

        GainIntelligence ->
            "Gain Intelligence"

        GainAgility ->
            "Gain Agility"

        GainLuck ->
            "Gain Luck"

        Slayer ->
            "Slayer"

        MoreCriticals ->
            "More Criticals"

        BetterCriticals ->
            "Better Criticals"

        SwiftLearner ->
            "Swift Learner"

        Thief ->
            "Thief"

        Toughness ->
            "Toughness"

        AdrenalineRush ->
            "Adrenaline Rush"

        FortuneFinder ->
            "Fortune Finder"

        Gambler ->
            "Gambler"

        Negotiator ->
            "Negotiator"

        Pathfinder ->
            "Pathfinder"

        Ranger ->
            "Ranger"

        Salesman ->
            "Salesman"

        Dodger ->
            "Dodger"

        Speaker ->
            "Speaker"

        ActionBoy ->
            "Action Boy"

        HthEvade ->
            "HtH Evade"

        Lifegiver ->
            "Lifegiver"

        LivingAnatomy ->
            "Living Anatomy"

        MasterThief ->
            "Master Thief"

        Medic ->
            "Medic"


multipleRankPerks : Dict_.Dict Perk Int
multipleRankPerks =
    -- https://fallout.fandom.com/wiki/Fallout_2_perks
    Dict_.fromList
        [ ( EarlierSequence, 3 )
        , ( Educated, 3 )
        , ( BonusHthDamage, 3 )
        , ( FasterHealing, 3 )
        , ( MoreCriticals, 3 )
        , ( SwiftLearner, 3 )
        , ( Toughness, 3 )
        , ( Pathfinder, 2 )
        , ( ActionBoy, 2 )
        , ( Lifegiver, 2 )
        ]


maxRank : Perk -> Int
maxRank perk =
    Dict_.get perk multipleRankPerks
        |> Maybe.withDefault 1


encode : Perk -> JE.Value
encode perk =
    JE.string <|
        case perk of
            EarlierSequence ->
                "earlier-sequence"

            Tag ->
                "tag"

            Educated ->
                "educated"

            BonusHthDamage ->
                "bonus-hth-damage"

            MasterTrader ->
                "master-trader"

            Awareness ->
                "awareness"

            CautiousNature ->
                "cautious-nature"

            Comprehension ->
                "comprehension"

            FasterHealing ->
                "faster-healing"

            HereAndNow ->
                "here-and-now"

            Survivalist ->
                "survivalist"

            GainStrength ->
                "gain-strength"

            GainPerception ->
                "gain-perception"

            GainEndurance ->
                "gain-endurance"

            GainCharisma ->
                "gain-charisma"

            GainIntelligence ->
                "gain-intelligence"

            GainAgility ->
                "gain-agility"

            GainLuck ->
                "gain-luck"

            Slayer ->
                "slayer"

            MoreCriticals ->
                "more-criticals"

            BetterCriticals ->
                "better-criticals"

            SwiftLearner ->
                "swift-learner"

            Thief ->
                "thief"

            Toughness ->
                "toughness"

            AdrenalineRush ->
                "adrenaline-rush"

            FortuneFinder ->
                "fortune-finder"

            Gambler ->
                "gambler"

            Negotiator ->
                "negotiator"

            Pathfinder ->
                "pathfinder"

            Ranger ->
                "ranger"

            Salesman ->
                "salesman"

            Dodger ->
                "dodger"

            Speaker ->
                "speaker"

            ActionBoy ->
                "action-boy"

            HthEvade ->
                "hth-evade"

            Lifegiver ->
                "lifegiver"

            LivingAnatomy ->
                "living-anatomy"

            MasterThief ->
                "master-thief"

            Medic ->
                "medic"


decoder : Decoder Perk
decoder =
    JD.string
        |> JD.andThen
            (\perk ->
                case perk of
                    "earlier-sequence" ->
                        JD.succeed EarlierSequence

                    "tag" ->
                        JD.succeed Tag

                    "educated" ->
                        JD.succeed Educated

                    "bonus-hth-damage" ->
                        JD.succeed BonusHthDamage

                    "master-trader" ->
                        JD.succeed MasterTrader

                    "awareness" ->
                        JD.succeed Awareness

                    "cautious-nature" ->
                        JD.succeed CautiousNature

                    "comprehension" ->
                        JD.succeed Comprehension

                    "faster-healing" ->
                        JD.succeed FasterHealing

                    "here-and-now" ->
                        JD.succeed HereAndNow

                    "survivalist" ->
                        JD.succeed Survivalist

                    "gain-strength" ->
                        JD.succeed GainStrength

                    "gain-perception" ->
                        JD.succeed GainPerception

                    "gain-endurance" ->
                        JD.succeed GainEndurance

                    "gain-charisma" ->
                        JD.succeed GainCharisma

                    "gain-intelligence" ->
                        JD.succeed GainIntelligence

                    "gain-agility" ->
                        JD.succeed GainAgility

                    "gain-luck" ->
                        JD.succeed GainLuck

                    "slayer" ->
                        JD.succeed Slayer

                    "more-criticals" ->
                        JD.succeed MoreCriticals

                    "better-criticals" ->
                        JD.succeed BetterCriticals

                    "swift-learner" ->
                        JD.succeed SwiftLearner

                    "thief" ->
                        JD.succeed Thief

                    "toughness" ->
                        JD.succeed Toughness

                    "adrenaline-rush" ->
                        JD.succeed AdrenalineRush

                    "fortune-finder" ->
                        JD.succeed FortuneFinder

                    "gambler" ->
                        JD.succeed Gambler

                    "negotiator" ->
                        JD.succeed Negotiator

                    "pathfinder" ->
                        JD.succeed Pathfinder

                    "ranger" ->
                        JD.succeed Ranger

                    "salesman" ->
                        JD.succeed Salesman

                    "dodger" ->
                        JD.succeed Dodger

                    "speaker" ->
                        JD.succeed Speaker

                    "action-boy" ->
                        JD.succeed ActionBoy

                    "hth-evade" ->
                        JD.succeed HthEvade

                    "lifegiver" ->
                        JD.succeed Lifegiver

                    "living-anatomy" ->
                        JD.succeed LivingAnatomy

                    "master-thief" ->
                        JD.succeed MasterThief

                    "medic" ->
                        JD.succeed Medic

                    _ ->
                        JD.fail <| "unknown Perk: '" ++ perk ++ "'"
            )


rank : Perk -> Dict_.Dict Perk Int -> Int
rank perk perks =
    Dict_.get perk perks
        |> Maybe.withDefault 0


allApplicable :
    { level : Int
    , special : Special
    , addedSkillPercentages : Dict_.Dict Skill Int
    , perks : Dict_.Dict Perk Int
    }
    -> List Perk
allApplicable r =
    List.filter (isApplicable r) all


isApplicable :
    { level : Int
    , special : Special
    , addedSkillPercentages : Dict_.Dict Skill Int
    , perks : Dict_.Dict Perk Int
    }
    -> Perk
    -> Bool
isApplicable r perk =
    let
        skill : Skill -> Int
        skill =
            Skill.get r.special r.addedSkillPercentages

        s =
            r.special

        currentRank : Int
        currentRank =
            rank perk r.perks
    in
    (currentRank < maxRank perk)
        && (case perk of
                EarlierSequence ->
                    r.level >= 3 && s.perception >= 6

                Tag ->
                    r.level >= 12

                Educated ->
                    r.level >= 6 && s.intelligence >= 6

                BonusHthDamage ->
                    r.level >= 3 && s.strength >= 6 && s.agility >= 6

                MasterTrader ->
                    r.level >= 12 && s.charisma >= 7 && skill Skill.Barter >= 75

                Awareness ->
                    r.level >= 3 && s.perception >= 5

                CautiousNature ->
                    r.level >= 3 && s.perception >= 6

                Comprehension ->
                    r.level >= 3 && s.intelligence >= 6

                FasterHealing ->
                    r.level >= 3 && s.endurance >= 6

                HereAndNow ->
                    r.level >= 3

                Survivalist ->
                    r.level >= 3 && s.endurance >= 6 && s.intelligence >= 6 && skill Skill.Outdoorsman >= 40

                GainStrength ->
                    r.level >= 12 && s.strength < 10

                GainPerception ->
                    r.level >= 12 && s.perception < 10

                GainEndurance ->
                    r.level >= 12 && s.endurance < 10

                GainCharisma ->
                    r.level >= 12 && s.charisma < 10

                GainIntelligence ->
                    r.level >= 12 && s.intelligence < 10

                GainAgility ->
                    r.level >= 12 && s.agility < 10

                GainLuck ->
                    r.level >= 12 && s.luck < 10

                Slayer ->
                    r.level >= 24 && s.agility >= 8 && s.strength >= 8 && skill Skill.Unarmed >= 80

                MoreCriticals ->
                    r.level >= 6 && s.luck >= 6

                BetterCriticals ->
                    r.level >= 9 && s.luck >= 6 && s.perception >= 6 && s.agility >= 4

                SwiftLearner ->
                    r.level >= 3 && s.intelligence >= 4

                Thief ->
                    r.level >= 3

                Toughness ->
                    r.level >= 3 && s.endurance >= 6 && s.luck >= 6

                AdrenalineRush ->
                    r.level >= 6 && s.strength < 10

                FortuneFinder ->
                    r.level >= 6 && s.luck >= 8

                Gambler ->
                    r.level >= 6 && skill Skill.Gambling >= 50

                Negotiator ->
                    r.level >= 6 && skill Skill.Barter >= 50 && skill Skill.Speech >= 50

                Pathfinder ->
                    r.level >= 6 && s.endurance >= 6 && skill Skill.Outdoorsman >= 40

                Ranger ->
                    r.level >= 6 && s.perception >= 6

                Salesman ->
                    r.level >= 6 && skill Skill.Barter >= 50

                Dodger ->
                    r.level >= 9 && s.agility >= 6

                Speaker ->
                    r.level >= 9 && skill Skill.Speech >= 50

                ActionBoy ->
                    r.level >= 12 && s.agility >= 5

                HthEvade ->
                    r.level >= 12 && skill Skill.Unarmed >= 75

                Lifegiver ->
                    r.level >= 12 && s.endurance >= 4

                LivingAnatomy ->
                    r.level >= 12 && skill Skill.Doctor >= 60

                MasterThief ->
                    r.level >= 12 && skill Skill.Lockpick >= 50 && skill Skill.Steal >= 50

                Medic ->
                    r.level >= 12 && skill Skill.FirstAid >= 40 && skill Skill.Doctor >= 40
           )
