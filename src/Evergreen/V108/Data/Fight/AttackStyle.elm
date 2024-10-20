module Evergreen.V108.Data.Fight.AttackStyle exposing (..)

import Evergreen.V108.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V108.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V108.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V108.Data.Fight.AimedShot.AimedShot
    | ShootBurst
