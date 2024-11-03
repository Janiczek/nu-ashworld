module SeqSet.Extra exposing (codec, toggle)

import Codec exposing (Codec)
import SeqSet exposing (SeqSet)


codec : Codec a -> Codec (SeqSet a)
codec itemCodec =
    Codec.list itemCodec
        |> Codec.map SeqSet.fromList SeqSet.toList


toggle : a -> SeqSet a -> SeqSet a
toggle x xs =
    if SeqSet.member x xs then
        SeqSet.remove x xs

    else
        SeqSet.insert x xs
