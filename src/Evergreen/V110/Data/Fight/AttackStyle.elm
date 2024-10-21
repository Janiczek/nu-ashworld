module Evergreen.V110.Data.Fight.AttackStyle exposing (..)

import Evergreen.V110.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V110.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V110.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V110.Data.Fight.AimedShot.AimedShot
    | ShootBurst
