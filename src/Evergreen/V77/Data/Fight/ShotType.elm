module Evergreen.V77.Data.Fight.ShotType exposing (..)


type AimedShot
    = Head
    | Torso
    | Eyes
    | Groin
    | LeftArm
    | RightArm
    | LeftLeg
    | RightLeg


type ShotType
    = NormalShot
    | AimedShot AimedShot
