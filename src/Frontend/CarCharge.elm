module Frontend.CarCharge exposing (format, formatShort)


format : Int -> String
format promile =
    String.fromInt (promile // 10)
        ++ "."
        ++ String.fromInt (promile |> modBy 10)
        ++ "%"


formatShort : Int -> String
formatShort promile =
    let
        whole =
            String.fromInt (promile // 10)

        fraction =
            modBy 10 promile
    in
    if fraction == 0 then
        whole

    else
        whole
            ++ "."
            ++ String.fromInt fraction
            ++ "%"
