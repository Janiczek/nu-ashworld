module Evergreen.V125.Data.Fight.AttackStyle exposing (..)

import Evergreen.V125.Data.Fight.AimedShot


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed Evergreen.V125.Data.Fight.AimedShot.AimedShot
    | MeleeUnaimed
    | MeleeAimed Evergreen.V125.Data.Fight.AimedShot.AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed Evergreen.V125.Data.Fight.AimedShot.AimedShot
    | ShootBurst
