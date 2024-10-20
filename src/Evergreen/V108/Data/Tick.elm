module Evergreen.V108.Data.Tick exposing (..)


type TickPerIntervalCurve
    = QuarterAndRest
        { quarter : Int
        , rest : Int
        }
    | Linear Int
