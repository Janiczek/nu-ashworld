module Lamdera.Hash exposing (hasChanged, hash)

import Dict exposing (Dict)
import FNV1a
import Hex.Convert
import Lamdera exposing (ClientId)
import Lamdera.Wire3


hash : (a -> Lamdera.Wire3.Encoder) -> a -> Int
hash encode value =
    value
        |> encode
        |> Lamdera.Wire3.bytesEncode
        |> Hex.Convert.toString
        |> FNV1a.hash


hasChanged : Int -> ClientId -> Dict ClientId Int -> Bool
hasChanged newHash clientId cache =
    case Dict.get clientId cache of
        Nothing ->
            True

        Just oldHash ->
            oldHash /= newHash
