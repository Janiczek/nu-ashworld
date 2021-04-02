module Data.Perk exposing (Perk(..), encode)

-- TODO finish implementing perks

import Json.Encode as JE


type Perk
    = Kamikaze
    | EarlierSequence


encode : Perk -> JE.Value
encode perk =
    JE.string <|
        case perk of
            Kamikaze ->
                "kamikaze"

            EarlierSequence ->
                "earlier-sequence"
