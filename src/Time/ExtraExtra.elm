module Time.ExtraExtra exposing
    ( intervalCodec
    , intervalToString
    , posixCodec
    )

import Codec exposing (Codec)
import Time exposing (Posix)
import Time.Extra exposing (Interval(..))


intervalCodec : Codec Interval
intervalCodec =
    Codec.enum Codec.string
        [ ( "Year", Time.Extra.Year )
        , ( "Quarter", Time.Extra.Quarter )
        , ( "Month", Time.Extra.Month )
        , ( "Week", Time.Extra.Week )
        , ( "Monday", Time.Extra.Monday )
        , ( "Tuesday", Time.Extra.Tuesday )
        , ( "Wednesday", Time.Extra.Wednesday )
        , ( "Thursday", Time.Extra.Thursday )
        , ( "Friday", Time.Extra.Friday )
        , ( "Saturday", Time.Extra.Saturday )
        , ( "Sunday", Time.Extra.Sunday )
        , ( "Day", Time.Extra.Day )
        , ( "Hour", Time.Extra.Hour )
        , ( "Minute", Time.Extra.Minute )
        , ( "Second", Time.Extra.Second )
        , ( "Millisecond", Time.Extra.Millisecond )
        ]


intervalToString : Interval -> String
intervalToString interval =
    case interval of
        Year ->
            "year"

        Quarter ->
            "quarter"

        Month ->
            "month"

        Week ->
            "week"

        Monday ->
            "Monday"

        Tuesday ->
            "Tuesday"

        Wednesday ->
            "Wednesday"

        Thursday ->
            "Thursday"

        Friday ->
            "Friday"

        Saturday ->
            "Saturday"

        Sunday ->
            "Sunday"

        Day ->
            "day"

        Hour ->
            "hour"

        Minute ->
            "minute"

        Second ->
            "second"

        Millisecond ->
            "millisecond"


posixCodec : Codec Posix
posixCodec =
    Codec.int
        |> Codec.map Time.millisToPosix Time.posixToMillis
