module SeqDict.Extra exposing
    ( codec
    , groupBy
    )

import Codec exposing (Codec)
import SeqDict exposing (SeqDict)


codec : Codec k -> Codec v -> Codec (SeqDict k v)
codec keyCodec valueCodec =
    Codec.list (Codec.tuple keyCodec valueCodec)
        |> Codec.map SeqDict.fromList SeqDict.toList


groupBy : (a -> b) -> List a -> SeqDict b (List a)
groupBy keyfn list =
    List.foldr
        (\x acc ->
            SeqDict.update
                (keyfn x)
                (Maybe.map ((::) x) >> Maybe.withDefault [ x ] >> Just)
                acc
        )
        SeqDict.empty
        list
