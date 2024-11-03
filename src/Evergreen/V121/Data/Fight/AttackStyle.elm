module Evergreen.V121.Data.Fight.AttackStyle exposing (..)

import Evergreen.V121.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V121.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V121.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V121.Data.Fight.AimedShot.AimedShot
    | ShootBurst
