module Evergreen.V128.Data.HealthStatus exposing (..)


type HealthStatus
    = ExactHp
        { current : Int
        , max : Int
        }
    | Unhurt
    | SlightlyWounded
    | Wounded
    | SeverelyWounded
    | AlmostDead
    | Dead
    | Alive
    | Unknown
