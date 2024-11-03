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
    Codec.custom
        (\yearEncoder quarterEncoder monthEncoder weekEncoder mondayEncoder tuesdayEncoder wednesdayEncoder thursdayEncoder fridayEncoder saturdayEncoder sundayEncoder dayEncoder hourEncoder minuteEncoder secondEncoder millisecondEncoder value ->
            case value of
                Time.Extra.Year ->
                    yearEncoder

                Time.Extra.Quarter ->
                    quarterEncoder

                Time.Extra.Month ->
                    monthEncoder

                Time.Extra.Week ->
                    weekEncoder

                Time.Extra.Monday ->
                    mondayEncoder

                Time.Extra.Tuesday ->
                    tuesdayEncoder

                Time.Extra.Wednesday ->
                    wednesdayEncoder

                Time.Extra.Thursday ->
                    thursdayEncoder

                Time.Extra.Friday ->
                    fridayEncoder

                Time.Extra.Saturday ->
                    saturdayEncoder

                Time.Extra.Sunday ->
                    sundayEncoder

                Time.Extra.Day ->
                    dayEncoder

                Time.Extra.Hour ->
                    hourEncoder

                Time.Extra.Minute ->
                    minuteEncoder

                Time.Extra.Second ->
                    secondEncoder

                Time.Extra.Millisecond ->
                    millisecondEncoder
        )
        |> Codec.variant0 "Year" Time.Extra.Year
        |> Codec.variant0 "Quarter" Time.Extra.Quarter
        |> Codec.variant0 "Month" Time.Extra.Month
        |> Codec.variant0 "Week" Time.Extra.Week
        |> Codec.variant0 "Monday" Time.Extra.Monday
        |> Codec.variant0 "Tuesday" Time.Extra.Tuesday
        |> Codec.variant0 "Wednesday" Time.Extra.Wednesday
        |> Codec.variant0 "Thursday" Time.Extra.Thursday
        |> Codec.variant0 "Friday" Time.Extra.Friday
        |> Codec.variant0 "Saturday" Time.Extra.Saturday
        |> Codec.variant0 "Sunday" Time.Extra.Sunday
        |> Codec.variant0 "Day" Time.Extra.Day
        |> Codec.variant0 "Hour" Time.Extra.Hour
        |> Codec.variant0 "Minute" Time.Extra.Minute
        |> Codec.variant0 "Second" Time.Extra.Second
        |> Codec.variant0 "Millisecond" Time.Extra.Millisecond
        |> Codec.buildCustom


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
