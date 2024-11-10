module Evergreen.V137.Data.Fight.AttackStyle exposing (..)

import Evergreen.V137.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V137.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V137.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V137.Data.Fight.AimedShot.AimedShot
    | ShootBurst
