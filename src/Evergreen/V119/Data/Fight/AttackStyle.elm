module Evergreen.V119.Data.Fight.AttackStyle exposing (..)

import Evergreen.V119.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V119.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V119.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V119.Data.Fight.AimedShot.AimedShot
    | ShootBurst
