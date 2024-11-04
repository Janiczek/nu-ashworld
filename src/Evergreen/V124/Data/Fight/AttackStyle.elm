module Evergreen.V124.Data.Fight.AttackStyle exposing (..)

import Evergreen.V124.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V124.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V124.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V124.Data.Fight.AimedShot.AimedShot
    | ShootBurst
