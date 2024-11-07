module Data.Tick exposing
    ( TickPerIntervalCurve(..)
    , curveCodec
    , limit
    , nextTick
    , ticksAddedPerInterval
    , worstCaseScenarioTicksForQuests
    )

import Codec exposing (Codec)
import Time exposing (Posix)
import Time.Extra as Time


nextTick : Time.Interval -> Posix -> Posix
nextTick tickFrequency time =
    Time.ceiling tickFrequency Time.utc time


limit : Int
limit =
    200


type TickPerIntervalCurve
    = QuarterAndRest
        { quarter : Int
        , rest : Int
        }
    | Linear Int


ticksAddedPerInterval : TickPerIntervalCurve -> Int -> Int
ticksAddedPerInterval curve currentTicks =
    case curve of
        Linear n ->
            if currentTicks < limit then
                n

            else
                0

        QuarterAndRest { quarter, rest } ->
            if currentTicks < (limit // 4) then
                quarter

            else if currentTicks < limit then
                rest

            else
                0


curveCodec : Codec TickPerIntervalCurve
curveCodec =
    Codec.custom
        (\quarterAndRestEncoder linearEncoder value ->
            case value of
                QuarterAndRest arg0 ->
                    quarterAndRestEncoder arg0

                Linear arg0 ->
                    linearEncoder arg0
        )
        |> Codec.variant1
            "QuarterAndRest"
            QuarterAndRest
            (Codec.object (\quarter rest -> { quarter = quarter, rest = rest })
                |> Codec.field "quarter" .quarter Codec.int
                |> Codec.field "rest" .rest Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1 "Linear" Linear Codec.int
        |> Codec.buildCustom


worstCaseScenarioTicksForQuests : TickPerIntervalCurve -> Int
worstCaseScenarioTicksForQuests curve =
    case curve of
        Linear n ->
            n

        QuarterAndRest { quarter, rest } ->
            min quarter rest
