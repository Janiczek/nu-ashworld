module Evergreen.V105.Data.Fight.AttackStyle exposing (..)

import Evergreen.V105.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V105.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V105.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V105.Data.Fight.AimedShot.AimedShot
    | ShootBurst
