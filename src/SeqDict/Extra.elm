module SeqDict.Extra exposing
    ( decoder
    , encode
    , groupBy
    )

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import SeqDict exposing (SeqDict)


encode : (k -> JE.Value) -> (v -> JE.Value) -> SeqDict k v -> JE.Value
encode encodeKey encodeValue dict =
    let
        encodeTuple : ( k, v ) -> JE.Value
        encodeTuple ( k, v ) =
            JE.object
                [ ( "key", encodeKey k )
                , ( "value", encodeValue v )
                ]
    in
    dict
        |> SeqDict.toList
        |> JE.list encodeTuple


decoder : Decoder k -> Decoder v -> Decoder (SeqDict k v)
decoder keyDecoder valueDecoder =
    let
        tupleDecoder : Decoder ( k, v )
        tupleDecoder =
            JD.map2 Tuple.pair
                (JD.field "key" keyDecoder)
                (JD.field "value" valueDecoder)
    in
    JD.list tupleDecoder
        |> JD.map SeqDict.fromList


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
