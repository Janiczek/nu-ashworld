module Evergreen.V128.Data.Fight.AttackStyle exposing (..)

import Evergreen.V128.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V128.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V128.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V128.Data.Fight.AimedShot.AimedShot
    | ShootBurst
