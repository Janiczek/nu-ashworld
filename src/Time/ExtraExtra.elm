module Time.ExtraExtra exposing (encodeInterval, intervalDecoder)

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Time.Extra as Time exposing (Interval(..))


encodeInterval : Interval -> JE.Value
encodeInterval interval =
    case interval of
        Year ->
            JE.string "Year"

        Quarter ->
            JE.string "Quarter"

        Month ->
            JE.string "Month"

        Week ->
            JE.string "Week"

        Monday ->
            JE.string "Monday"

        Tuesday ->
            JE.string "Tuesday"

        Wednesday ->
            JE.string "Wednesday"

        Thursday ->
            JE.string "Thursday"

        Friday ->
            JE.string "Friday"

        Saturday ->
            JE.string "Saturday"

        Sunday ->
            JE.string "Sunday"

        Day ->
            JE.string "Day"

        Hour ->
            JE.string "Hour"

        Minute ->
            JE.string "Minute"

        Second ->
            JE.string "Second"

        Millisecond ->
            JE.string "Millisecond"


intervalDecoder : Decoder Interval
intervalDecoder =
    JD.string
        |> JD.andThen
            (\interval ->
                case interval of
                    "Year" ->
                        JD.succeed Year

                    "Quarter" ->
                        JD.succeed Quarter

                    "Month" ->
                        JD.succeed Month

                    "Week" ->
                        JD.succeed Week

                    "Monday" ->
                        JD.succeed Monday

                    "Tuesday" ->
                        JD.succeed Tuesday

                    "Wednesday" ->
                        JD.succeed Wednesday

                    "Thursday" ->
                        JD.succeed Thursday

                    "Friday" ->
                        JD.succeed Friday

                    "Saturday" ->
                        JD.succeed Saturday

                    "Sunday" ->
                        JD.succeed Sunday

                    "Day" ->
                        JD.succeed Day

                    "Hour" ->
                        JD.succeed Hour

                    "Minute" ->
                        JD.succeed Minute

                    "Second" ->
                        JD.succeed Second

                    "Millisecond" ->
                        JD.succeed Millisecond

                    _ ->
                        JD.fail <| "Unknown interval: '" ++ interval ++ "'"
            )
