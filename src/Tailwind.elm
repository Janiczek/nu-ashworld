module Tailwind exposing (mod)

import Html exposing (Attribute)
import Html.Attributes as HA


mod : String -> String -> Attribute msg
mod modifier classes =
    classes
        |> String.words
        |> List.map (\word -> modifier ++ ":" ++ word)
        |> String.join " "
        |> HA.class
