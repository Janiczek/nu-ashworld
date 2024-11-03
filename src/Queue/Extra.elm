module Queue.Extra exposing (codec)

import Codec exposing (Codec)
import Queue exposing (Queue)


codec : Codec a -> Codec (Queue a)
codec a =
    Codec.list a
        |> Codec.map Queue.fromList Queue.toList
