module Data.Perk exposing
    ( Perk(..)
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
    = EarlierSequence
    | Tag
    | Educated
    | BonusHthDamage
    | MasterTrader
    | Awareness
    | CautiousNature


all : List Perk
all =
    [ EarlierSequence
    , Tag
    , Educated
    , BonusHthDamage
    , MasterTrader
    , Awareness
    , CautiousNature
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


multipleRankPerks : Dict_.Dict Perk Int
multipleRankPerks =
    -- https://fallout.fandom.com/wiki/Fallout_2_perks
    Dict_.fromList
        [ ( EarlierSequence, 3 )
        , ( Educated, 3 )
        , ( BonusHthDamage, 3 )
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

                    _ ->
                        JD.fail <| "unknown Perk: '" ++ perk ++ "'"
            )


rank : Perk -> Dict_.Dict Perk Int -> Int
rank perk perks =
    Dict_.get perk perks
        |> Maybe.withDefault 0


allApplicable :
    { level : Int
    , finalSpecial : Special
    , addedSkillPercentages : Dict_.Dict Skill Int
    , perks : Dict_.Dict Perk Int
    }
    -> List Perk
allApplicable r =
    List.filter (isApplicable r) all


isApplicable :
    { level : Int
    , finalSpecial : Special
    , addedSkillPercentages : Dict_.Dict Skill Int
    , perks : Dict_.Dict Perk Int
    }
    -> Perk
    -> Bool
isApplicable r perk =
    let
        skill : Skill -> Int
        skill =
            Skill.get r.finalSpecial r.addedSkillPercentages

        s =
            r.finalSpecial

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
           )
