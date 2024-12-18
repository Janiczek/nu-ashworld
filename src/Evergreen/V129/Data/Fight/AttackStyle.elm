module Evergreen.V129.Data.Fight.AttackStyle exposing (..)

import Evergreen.V129.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V129.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V129.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V129.Data.Fight.AimedShot.AimedShot
    | ShootBurst
