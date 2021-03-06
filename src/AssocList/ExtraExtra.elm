module AssocList.ExtraExtra exposing
    ( decoder
    , encode
    , groupBy
    )

import AssocList
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


encode : (k -> JE.Value) -> (v -> JE.Value) -> AssocList.Dict k v -> JE.Value
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
        |> AssocList.toList
        |> JE.list encodeTuple


decoder : Decoder k -> Decoder v -> Decoder (AssocList.Dict k v)
decoder keyDecoder valueDecoder =
    let
        tupleDecoder : Decoder ( k, v )
        tupleDecoder =
            JD.map2 Tuple.pair
                (JD.field "key" keyDecoder)
                (JD.field "value" valueDecoder)
    in
    JD.list tupleDecoder
        |> JD.map AssocList.fromList


groupBy : (a -> b) -> List a -> AssocList.Dict b (List a)
groupBy keyfn list =
    List.foldr
        (\x acc ->
            AssocList.update
                (keyfn x)
                (Maybe.map ((::) x) >> Maybe.withDefault [ x ] >> Just)
                acc
        )
        AssocList.empty
        list
