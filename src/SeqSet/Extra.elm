module SeqSet.Extra exposing (decoder, encode, toggle)

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import SeqSet exposing (SeqSet)


encode : (a -> JE.Value) -> SeqSet a -> JE.Value
encode encodeItem set =
    set
        |> SeqSet.toList
        |> JE.list encodeItem


decoder : Decoder a -> Decoder (SeqSet a)
decoder itemDecoder =
    JD.list itemDecoder
        |> JD.map SeqSet.fromList


toggle : a -> SeqSet a -> SeqSet a
toggle x xs =
    if SeqSet.member x xs then
        SeqSet.remove x xs

    else
        SeqSet.insert x xs
