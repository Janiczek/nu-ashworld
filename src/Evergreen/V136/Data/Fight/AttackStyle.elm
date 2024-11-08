module Evergreen.V136.Data.Fight.AttackStyle exposing (..)

import Evergreen.V136.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V136.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V136.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V136.Data.Fight.AimedShot.AimedShot
    | ShootBurst
