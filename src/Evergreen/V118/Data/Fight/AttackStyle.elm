module Evergreen.V118.Data.Fight.AttackStyle exposing (..)

import Evergreen.V118.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V118.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V118.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V118.Data.Fight.AimedShot.AimedShot
    | ShootBurst
