module Evergreen.V120.Data.Fight.AttackStyle exposing (..)

import Evergreen.V120.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V120.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V120.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V120.Data.Fight.AimedShot.AimedShot
    | ShootBurst
