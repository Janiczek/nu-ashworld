module BiDict.Extra exposing (codec)

import BiDict exposing (BiDict)
import Codec exposing (Codec)


codec : Codec comparable1 -> Codec comparable2 -> Codec (BiDict comparable1 comparable2)
codec a b =
    Codec.list (Codec.tuple a b)
        |> Codec.map BiDict.fromList BiDict.toList
