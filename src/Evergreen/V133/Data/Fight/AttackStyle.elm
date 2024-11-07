module Evergreen.V133.Data.Fight.AttackStyle exposing (..)

import Evergreen.V133.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V133.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V133.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V133.Data.Fight.AimedShot.AimedShot
    | ShootBurst
