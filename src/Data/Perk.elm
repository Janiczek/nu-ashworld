module Data.Perk exposing (Perk(..), decoder, encode, maxRank, name)

import AssocList as Dict_
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE



{- TODO go through
   https://fallout.fandom.com/wiki/Fallout_2_perks
   and implement all missing and applicable
-}
-- TODO allow adding the perks in Character view
-- TODO conditions
-- TODO Earlier Sequence (3x) + sequence
-- TODO Tag (1x) + tag skill
-- TODO Educated (3x) + skill points at level up


type Perk
    = EarlierSequence
    | Tag


name : Perk -> String
name perk =
    case perk of
        EarlierSequence ->
            "Earlier Sequence"

        Tag ->
            "Tag!"


multipleRankPerks : Dict_.Dict Perk Int
multipleRankPerks =
    -- https://fallout.fandom.com/wiki/Fallout_2_perks
    Dict_.fromList
        [ ( EarlierSequence, 3 ) ]


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

                    _ ->
                        JD.fail <| "unknown Perk: '" ++ perk ++ "'"
            )
