module AssocSet.Extra exposing (decoder, encode, toggle)

import AssocSet
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


encode : (a -> JE.Value) -> AssocSet.Set a -> JE.Value
encode encodeItem set =
    set
        |> AssocSet.toList
        |> JE.list encodeItem


decoder : Decoder a -> Decoder (AssocSet.Set a)
decoder itemDecoder =
    JD.list itemDecoder
        |> JD.map AssocSet.fromList


toggle : a -> AssocSet.Set a -> AssocSet.Set a
toggle x xs =
    if AssocSet.member x xs then
        AssocSet.remove x xs

    else
        AssocSet.insert x xs
