module Dict.ExtraExtra exposing (codec)

import Codec exposing (Codec)
import Dict exposing (Dict)


codec : Codec comparable -> Codec v -> Codec (Dict comparable v)
codec keyCodec valueCodec =
    Codec.list (Codec.tuple keyCodec valueCodec)
        |> Codec.map Dict.fromList Dict.toList
