module Data.Perk exposing (Perk(..), decoder, encode)

-- TODO finish implementing perks

import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JDE
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


decoder : Decoder Perk
decoder =
    JD.string
        |> JD.andThen
            (\perk ->
                case perk of
                    "kamikaze" ->
                        JD.succeed Kamikaze

                    "earlier-sequence" ->
                        JD.succeed EarlierSequence

                    _ ->
                        JD.fail <| "unknown Perk: '" ++ perk ++ "'"
            )
