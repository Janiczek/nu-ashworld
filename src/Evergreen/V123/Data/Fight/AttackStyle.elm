module Evergreen.V123.Data.Fight.AttackStyle exposing (..)

import Evergreen.V123.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V123.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V123.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V123.Data.Fight.AimedShot.AimedShot
    | ShootBurst
