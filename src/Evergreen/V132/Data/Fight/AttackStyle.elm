module Evergreen.V132.Data.Fight.AttackStyle exposing (..)

import Evergreen.V132.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V132.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V132.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V132.Data.Fight.AimedShot.AimedShot
    | ShootBurst
