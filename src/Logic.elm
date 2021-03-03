module Logic exposing (affectsHitpoints, healingRate, hitpoints)

import Data.Special exposing (Special, SpecialType(..))


affectsHitpoints : SpecialType -> Bool
affectsHitpoints type_ =
    case type_ of
        Strength ->
            True

        Endurance ->
            True

        _ ->
            False


hitpoints :
    { level : Int
    , special : Special
    }
    -> Int
hitpoints { level, special } =
    let
        { strength, endurance } =
            special
    in
    15
        + (2 * endurance)
        + strength
        + (level * (2 + endurance // 2))


healingRate : Special -> Int
healingRate { endurance } =
    max 1 (endurance // 3)
