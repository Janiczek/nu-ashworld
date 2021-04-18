module Data.Trait exposing
    ( Trait(..)
    , all
    , decoder
    , encode
    , isSelected
    , name
    )

import AssocSet as Set_
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE



{- TODO go through
   https://fallout.fandom.com/wiki/Fallout_2_traits
   and implement all missing and applicable
-}
-- TODO Kamikaze + sequence
-- TODO Kamikaze - armor class
-- TODO Bruiser + strength
-- TODO Bruiser - action points
-- TODO Gifted + SPECIAL
-- TODO Gifted - skills
-- TODO Gifted - skill points per level
-- TODO Skilled + skill points per level
-- TODO Skilled - perk rate
-- TODO Small Frame + agility
-- TODO Small Frame - carry weight
-- TODO Heavy Handed + damage
-- TODO Heavy Handed - critical hit chance


type Trait
    = Kamikaze
    | Bruiser
    | Gifted
    | SmallFrame
    | Skilled
    | HeavyHanded


all : List Trait
all =
    -- TODO sort them according to F2
    [ Bruiser
    , Kamikaze
    , Gifted
    , SmallFrame
    , Skilled
    , HeavyHanded
    ]


name : Trait -> String
name trait =
    case trait of
        Kamikaze ->
            "Kamikaze"

        Bruiser ->
            "Bruiser"

        Gifted ->
            "Gifted"

        SmallFrame ->
            "Small Frame"

        Skilled ->
            "Skilled"

        HeavyHanded ->
            "Heavy Handed"


encode : Trait -> JE.Value
encode trait =
    JE.string <|
        case trait of
            Kamikaze ->
                "kamikaze"

            Bruiser ->
                "bruiser"

            Gifted ->
                "gifted"

            SmallFrame ->
                "small-frame"

            Skilled ->
                "skilled"

            HeavyHanded ->
                "heavy-handed"


decoder : Decoder Trait
decoder =
    JD.string
        |> JD.andThen
            (\trait ->
                case trait of
                    "kamikaze" ->
                        JD.succeed Kamikaze

                    "bruiser" ->
                        JD.succeed Bruiser

                    "gifted" ->
                        JD.succeed Gifted

                    "small-frame" ->
                        JD.succeed SmallFrame

                    "skilled" ->
                        JD.succeed Skilled

                    "heavy-handed" ->
                        JD.succeed HeavyHanded

                    _ ->
                        JD.fail <| "unknown Trait: '" ++ trait ++ "'"
            )


isSelected : Trait -> Set_.Set Trait -> Bool
isSelected trait traits =
    Set_.member trait traits
