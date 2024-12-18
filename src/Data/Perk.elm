module Data.Perk exposing
    ( Perk(..)
    , all
    , codec
    , description
    , maxRank
    , name
    , rank
    )

import Codec exposing (Codec)
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
    | NightVision
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
    | BonusRangedDamage
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
    | QuickRecovery
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
    | Sharpshooter
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
    | BonusRateOfFire
      -- TODO Pickpocket -- needs stealing mechanic
      -- lvl 18
      -- TODO SilentDeath -- needs sneaking in combat
      -- lvl 24
    | Sniper
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
    , BonusRangedDamage
    , BonusRateOfFire
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
    , NightVision
    , Pathfinder
    , QuickRecovery
    , Ranger
    , Salesman
    , Sniper
    , Slayer
    , Sharpshooter
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
            "Bonus Hand-to-Hand Damage"

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

        Sharpshooter ->
            "Sharpshooter"

        Sniper ->
            "Sniper"

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
            "Hand-to-Hand Evade"

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
            "Bonus Hand-to-Hand Attacks"

        BonusRateOfFire ->
            "Bonus Rate of Fire"

        GeckoSkinning ->
            "Gecko Skinning"

        NightVision ->
            "Night Vision"

        BonusRangedDamage ->
            "Bonus Ranged Damage"

        QuickRecovery ->
            "Quick Recovery"


{-| <https://fallout.fandom.com/wiki/Fallout_2_perks>
-}
maxRank : Perk -> Int
maxRank perk =
    case perk of
        EarlierSequence ->
            3

        Educated ->
            3

        BonusHthDamage ->
            3

        FasterHealing ->
            3

        MoreCriticals ->
            3

        SwiftLearner ->
            3

        Toughness ->
            3

        Pathfinder ->
            2

        ActionBoy ->
            2

        Lifegiver ->
            2

        Awareness ->
            1

        CautiousNature ->
            1

        Comprehension ->
            1

        HereAndNow ->
            1

        NightVision ->
            1

        Survivalist ->
            1

        Thief ->
            1

        AdrenalineRush ->
            1

        FortuneFinder ->
            1

        Gambler ->
            1

        Negotiator ->
            1

        Ranger ->
            1

        Salesman ->
            1

        BetterCriticals ->
            1

        Dodger ->
            1

        Speaker ->
            1

        Sharpshooter ->
            2

        GainStrength ->
            1

        GainPerception ->
            1

        GainEndurance ->
            1

        GainCharisma ->
            1

        GainIntelligence ->
            1

        GainAgility ->
            1

        GainLuck ->
            1

        HthEvade ->
            1

        LivingAnatomy ->
            1

        MasterThief ->
            1

        MasterTrader ->
            1

        Medic ->
            1

        MrFixit ->
            1

        Tag ->
            1

        BonusHthAttacks ->
            1

        BonusRateOfFire ->
            1

        Sniper ->
            1

        Slayer ->
            1

        GeckoSkinning ->
            1

        BonusRangedDamage ->
            2

        QuickRecovery ->
            1


codec : Codec Perk
codec =
    Codec.enum Codec.string
        [ ( "BonusHthDamage", BonusHthDamage )
        , ( "Awareness", Awareness )
        , ( "CautiousNature", CautiousNature )
        , ( "Comprehension", Comprehension )
        , ( "EarlierSequence", EarlierSequence )
        , ( "FasterHealing", FasterHealing )
        , ( "HereAndNow", HereAndNow )
        , ( "NightVision", NightVision )
        , ( "Survivalist", Survivalist )
        , ( "SwiftLearner", SwiftLearner )
        , ( "Thief", Thief )
        , ( "Toughness", Toughness )
        , ( "AdrenalineRush", AdrenalineRush )
        , ( "BonusRangedDamage", BonusRangedDamage )
        , ( "Educated", Educated )
        , ( "FortuneFinder", FortuneFinder )
        , ( "Gambler", Gambler )
        , ( "MoreCriticals", MoreCriticals )
        , ( "Negotiator", Negotiator )
        , ( "Pathfinder", Pathfinder )
        , ( "QuickRecovery", QuickRecovery )
        , ( "Ranger", Ranger )
        , ( "Salesman", Salesman )
        , ( "BetterCriticals", BetterCriticals )
        , ( "Dodger", Dodger )
        , ( "Sharpshooter", Sharpshooter )
        , ( "Speaker", Speaker )
        , ( "ActionBoy", ActionBoy )
        , ( "GainStrength", GainStrength )
        , ( "GainPerception", GainPerception )
        , ( "GainEndurance", GainEndurance )
        , ( "GainCharisma", GainCharisma )
        , ( "GainIntelligence", GainIntelligence )
        , ( "GainAgility", GainAgility )
        , ( "GainLuck", GainLuck )
        , ( "HthEvade", HthEvade )
        , ( "Lifegiver", Lifegiver )
        , ( "LivingAnatomy", LivingAnatomy )
        , ( "MasterThief", MasterThief )
        , ( "MasterTrader", MasterTrader )
        , ( "Medic", Medic )
        , ( "MrFixit", MrFixit )
        , ( "Tag", Tag )
        , ( "BonusHthAttacks", BonusHthAttacks )
        , ( "BonusRateOfFire", BonusRateOfFire )
        , ( "Sniper", Sniper )
        , ( "Slayer", Slayer )
        , ( "GeckoSkinning", GeckoSkinning )
        ]


rank : Perk -> SeqDict Perk Int -> Int
rank perk perks =
    SeqDict.get perk perks
        |> Maybe.withDefault 0


description : Perk -> String
description perk =
    case perk of
        ActionBoy ->
            "Each level of Action Boy gives you an additional AP to spend every combat turn. You can use these generic APs on any task."

        Sharpshooter ->
            "The talent of hitting things at longer distances. You get a +2 bonus, for each level of this Perk, to Perception for the purposes of determining range modifiers. It's easier than ever to kill at long range!"

        AdrenalineRush ->
            "With this Perk, you gain +1 to your Strength when you drop below 1/2 of your max hit points."

        Awareness ->
            "With Awareness, you are given detailed information about any critter you examine. You see their exact hit points and information about any weapon they are equipped with. This is shown in the Ladder and during fights."

        BetterCriticals ->
            "The critical hits you cause in combat are more devastating. You gain a 20% bonus on the critical hit table, almost ensuring that more damage will be done. This does not affect the chance to cause a critical hit."

        BonusHthAttacks ->
            "You have learned the secret arts of the East, or you just punch faster. In any case, your hand-to-hand attacks cost 1 AP less to perform."

        BonusHthDamage ->
            "Experience in unarmed combat has given you the edge when it comes to damage. You cause +2 points of damage with hand-to-hand and melee attacks for each level of this Perk."

        BonusRateOfFire ->
            "This Perk allows you to pull the trigger a little more faster, and still remain as accurate as before. Each ranged weapon attack costs 1 AP less to perform."

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
            "With each level of this Perk, the percentage of max HP you heal over time and when you use a tick increases by 10%."

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
            "If your hands are empty (no equipped weapon), each unused action point gives you a +2 instead of +1 towards your Armor Class at the end of your turn, plus 1/12 of your unarmed skill."

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

        NightVision ->
            "With the Night Vision Perk, you can see in the dark better. This Perk will reduce the overall darkness level by 20%."

        Pathfinder ->
            "The Pathfinder is better able to find the shortest route. With this Perk, your travel cost on the World Map is reduced by 25% for each level."

        Ranger ->
            "You gain a +15% toward your Outdoorsman skill."

        Salesman ->
            "You are an adept salesperson. With this Perk you gain +20% towards your Barter skill."

        Sniper ->
            "You have mastered the firearm as a source of pain. This perk gives you an increased chance to score a critical hit with ranged weapons."

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

        BonusRangedDamage ->
            "Your training in firearms and other ranged weapons has made you more deadly in ranged combat. For each level of this Perk, you do +2 points of damage with ranged weapons."

        QuickRecovery ->
            "You are quick at recovering from being knocked down. Standing back up takes 1 AP instead of 4 AP."
