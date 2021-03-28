module Data.Fight.ShotType exposing
    ( AimedShot(..)
    , ShotType(..)
    , penalty
    )


type ShotType
    = NormalShot
    | AimedShot AimedShot


type AimedShot
    = Head
    | Torso
    | Eyes
    | Groin
    | Arms
    | Legs


penalty : ShotType -> Int
penalty shot =
    case shot of
        NormalShot ->
            0

        AimedShot aimedShot ->
            aimedShotPenalty aimedShot


aimedShotPenalty : AimedShot -> Int
aimedShotPenalty shot =
    case shot of
        Head ->
            40

        Torso ->
            0

        Eyes ->
            60

        Groin ->
            30

        Arms ->
            30

        Legs ->
            20
