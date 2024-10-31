module Evergreen.V114.Data.Fight.AttackStyle exposing (..)

import Evergreen.V114.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V114.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V114.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V114.Data.Fight.AimedShot.AimedShot
    | ShootBurst
