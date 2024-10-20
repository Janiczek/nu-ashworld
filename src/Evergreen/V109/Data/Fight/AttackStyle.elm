module Evergreen.V109.Data.Fight.AttackStyle exposing (..)

import Evergreen.V109.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V109.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V109.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V109.Data.Fight.AimedShot.AimedShot
    | ShootBurst
