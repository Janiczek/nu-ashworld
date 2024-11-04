module Evergreen.V125.Data.Tick exposing (..)


type TickPerIntervalCurve
    = QuarterAndRest
        { quarter : Int
        , rest : Int
        }
    | Linear Int
