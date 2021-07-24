module Data.Tick exposing
    ( TickPerIntervalCurve(..)
    , baseTicksPerInterval
    , curveDecoder
    , curveToString
    , encodeCurve
    , limit
    , nextTick
    , ticksAddedPerInterval
    )

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
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


curveToString : TickPerIntervalCurve -> String
curveToString curve =
    case curve of
        QuarterAndRest { quarter, rest } ->
            String.fromInt quarter ++ "-" ++ String.fromInt rest

        Linear n ->
            String.fromInt n


encodeCurve : TickPerIntervalCurve -> JE.Value
encodeCurve curve =
    case curve of
        QuarterAndRest { quarter, rest } ->
            JE.object
                [ ( "type", JE.string "quarterAndRest" )
                , ( "quarter", JE.int quarter )
                , ( "rest", JE.int rest )
                ]

        Linear n ->
            JE.object
                [ ( "type", JE.string "linear" )
                , ( "n", JE.int n )
                ]


curveDecoder : Decoder TickPerIntervalCurve
curveDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "quarterAndRest" ->
                        JD.map2
                            (\quarter rest ->
                                QuarterAndRest
                                    { quarter = quarter
                                    , rest = rest
                                    }
                            )
                            (JD.field "quarter" JD.int)
                            (JD.field "rest" JD.int)

                    "linear" ->
                        JD.map Linear
                            (JD.field "n" JD.int)

                    _ ->
                        JD.fail <| "Unknown curve type: '" ++ type_ ++ "'"
            )


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


baseTicksPerInterval : Int
baseTicksPerInterval =
    4
