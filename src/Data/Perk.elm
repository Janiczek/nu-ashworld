module Data.Perk exposing
    ( Perk(..)
    , all
    , allApplicableForLevelup
    , decoder
    , description
    , encode
    , isApplicableForLevelup
    , maxRank
    , name
    , rank
    )

import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import SeqDict exposing (SeqDict)


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
    | MrFixit
    | Tag
      -- TODO WeaponHandling -- needs weapons
      -- lvl 15
    | BonusHthAttacks
      -- TODO BonusRateOfFire -- needs weapons
      -- TODO Pickpocket -- needs stealing mechanic
      -- lvl 18
      -- TODO SilentDeath -- needs sneaking in combat
      -- lvl 24
      -- TODO Sniper -- needs ranged weapons
    | Slayer
      -- special
    | GeckoSkinning


all : List Perk
all =
    [ ActionBoy
    , AdrenalineRush
    , Awareness
    , BetterCriticals
    , BonusHthAttacks
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
    , MrFixit
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
    , GeckoSkinning
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

        MrFixit ->
            "Mr. Fixit"

        BonusHthAttacks ->
            "Bonus HtH Attacks"

        GeckoSkinning ->
            "Gecko Skinning"


multipleRankPerks : SeqDict Perk Int
multipleRankPerks =
    -- https://fallout.fandom.com/wiki/Fallout_2_perks
    SeqDict.fromList
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
    SeqDict.get perk multipleRankPerks
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

            MrFixit ->
                "mr-fixit"

            BonusHthAttacks ->
                "bonus-hth-attacks"

            GeckoSkinning ->
                "gecko-skinning"


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

                    "mr-fixit" ->
                        JD.succeed MrFixit

                    "bonus-hth-attacks" ->
                        JD.succeed BonusHthAttacks

                    "gecko-skinning" ->
                        JD.succeed GeckoSkinning

                    _ ->
                        JD.fail <| "unknown Perk: '" ++ perk ++ "'"
            )


rank : Perk -> SeqDict Perk Int -> Int
rank perk perks =
    SeqDict.get perk perks
        |> Maybe.withDefault 0


allApplicableForLevelup :
    { level : Int
    , special : Special
    , addedSkillPercentages : SeqDict Skill Int
    , perks : SeqDict Perk Int
    }
    -> List Perk
allApplicableForLevelup r =
    List.filter (isApplicableForLevelup r) all


isApplicableForLevelup :
    { level : Int
    , special : Special
    , addedSkillPercentages : SeqDict Skill Int
    , perks : SeqDict Perk Int
    }
    -> Perk
    -> Bool
isApplicableForLevelup r perk =
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
                    r.level >= 12 && (skill Skill.FirstAid >= 40 || skill Skill.Doctor >= 40)

                MrFixit ->
                    r.level >= 12 && (skill Skill.Science >= 40 || skill Skill.Repair >= 40)

                BonusHthAttacks ->
                    r.level >= 15 && s.agility >= 6

                GeckoSkinning ->
                    False
           )


description : Perk -> String
description perk =
    case perk of
        ActionBoy ->
            "Each level of Action Boy gives you an additional AP to spend every combat turn. You can use these generic APs on any task."

        AdrenalineRush ->
            "With this Perk, you gain +1 to your Strength when you drop below 1/2 of your max hit points."

        Awareness ->
            "With Awareness, you are given detailed information about any critter you examine. You see their exact hit points and information about any weapon they are equipped with."

        BetterCriticals ->
            "The critical hits you cause in combat are more devastating. You gain a 20% bonus on the critical hit table, almost ensuring that more damage will be done. This does not affect the chance to cause a critical hit."

        BonusHthAttacks ->
            "You have learned the secret arts of the East, or you just punch faster. In any case, your hand-to-hand attacks cost 1 AP less to perform."

        BonusHthDamage ->
            "Experience in unarmed combat has given you the edge when it comes to damage. You cause +2 points of damage with hand-to-hand and melee attacks for each level of this Perk."

        CautiousNature ->
            "You are more alert outdoors and enemies are less likely to sneak up on you. With this Perk you get a +3 to your perception in random encounters when determining placement. This means the average starting distance in your fights increases."

        Comprehension ->
            "You pay much closer attention to the smaller details when reading. You gain 50% more skill points when reading books."

        Dodger ->
            "You are less likely to be hit in combat if you have this Perk. You gain a +5 to your Armor Class, in addition to the AC bonus from any armor worn."

        EarlierSequence ->
            "You are more likely to move before your opponents in combat, since your Sequence is +2 for each level of this Perk."

        Educated ->
            "Each level of Educated will add +2 skill points when you gain a new experience level. This Perk works best when purchased early in your adventure."

        FasterHealing ->
            "With each level of this Perk, the percentage of max HP you heal using a tick increases by 10%."

        FortuneFinder ->
            "You have the talent of finding money. You will find additional money in random encounters in the desert: all caps drops from PvM combat get doubled."

        GainAgility ->
            "With this Perk you gain +1 to your Agility."

        GainCharisma ->
            "With this Perk you gain +1 to your Charisma."

        GainEndurance ->
            "With this Perk you gain +1 to your Endurance."

        GainIntelligence ->
            "With this Perk you gain +1 to your Intelligence."

        GainLuck ->
            "With this Perk you gain +1 to your Luck."

        GainPerception ->
            "With this Perk you gain +1 to your Perception."

        GainStrength ->
            "With this Perk you gain +1 to your Strength."

        Gambler ->
            "You can roll with the best of them. You gain +20% to your gambling skill."

        HereAndNow ->
            "With this Perk you immediately gain one experience level."

        HthEvade ->
            -- TODO perhaps in future change to only work if hands are empty?
            "Each unused action point gives you a +2 instead of +1 towards your Armor Class at the end of your turn, plus 1/12 of your unarmed skill."

        Lifegiver ->
            "With each level of this Perk, you gain an additional 4 Hit Points every time you advance a level. This is in addition to the Hit Points you already gain per level based off of your Endurance. This also applies retroactively to all the levels you already gained."

        LivingAnatomy ->
            "You have a better understanding of living creatures and their strengths and weaknesses. You get a one-time bonus of +10% to Doctor, and you do +5 damage per attack to living creatures."

        MasterThief ->
            "You gain +15 to stealing and lockpicking. Steal from the rich, and give to you."

        MasterTrader ->
            "You have mastered one aspect of bartering - buying goods far more cheaply than normal. With this Perk, you get a 25% discount when purchasing items from a store or another trader."

        Medic ->
            "The Medic Perk gives you a one-time bonus of +10% to the First Aid and Doctor skills. Healing skills are a good thing."

        MoreCriticals ->
            "You are more likely to cause critical hits in combat if you have this Perk. Each level of More Criticals gets you an additional +5% chance to cause a critical hit."

        MrFixit ->
            "This Perk will give you a one-time bonus of +10% to the Repair and Science skills. A little late night cramming never hurt anybody, especially you."

        Negotiator ->
            "You are a very skilled negotiator. Not only can you barter with the best of them, but you can talk your way into or out of almost anything. With this Perk you gain +10% to both Barter and Speech."

        Pathfinder ->
            "The Pathfinder is better able to find the shortest route. With this Perk, your travel cost on the World Map is reduced by 25% for each level."

        Ranger ->
            "You gain a +15% toward your Outdoorsman skill."

        Salesman ->
            "You are an adept salesperson. With this Perk you gain +20% towards your Barter skill."

        Slayer ->
            "The Slayer walks the earth! In hand-to-hand combat all of your hits are upgraded to critical hits, causing destruction and mayhem."

        Speaker ->
            "Being a Speaker means you have a one-time bonus of +20% to Speech. From the mouth of babes and all that."

        Survivalist ->
            "You are a master of the outdoors. This Perk confers the ability to survive in hostile environments. You get a +25% bonus to Outdoorsman."

        SwiftLearner ->
            "You are indeed a Swift Learner with this Perk, as each level gives you an additional +5% bonus whenever you earn experience points. This is best taken early."

        Tag ->
            "Your skills have improved to the point where you can pick an additional Tag Skill.  Tag skills increase twice as fast."

        Thief ->
            "The blood of a thief runs through your veins. With the Thief Perk, you get a one-time bonus of +10% to your Sneak, Lockpick, Steal, and Traps skills.  A well rounded thief is a live thief."

        Toughness ->
            "When you are tough, you take less damage.  Each level of this Perk adds +10% to your general damage resistance."

        GeckoSkinning ->
            "You have the knowledge of how to skin geckos properly to get their hides."
