module Evergreen.V35.Data.Fight.ShotType exposing (..)

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