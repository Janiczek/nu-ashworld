module Evergreen.V139.Data.Fight.AttackStyle exposing (..)

import Evergreen.V139.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V139.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V139.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V139.Data.Fight.AimedShot.AimedShot
    | ShootBurst
