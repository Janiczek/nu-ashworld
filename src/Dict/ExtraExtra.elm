module Dict.ExtraExtra exposing (all, decoder, encode)

import Dict exposing (Dict)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


all : (comparable -> value -> Bool) -> Dict comparable value -> Bool
all fn dict =
    dict
        |> Dict.toList
        |> List.all (\( k, v ) -> fn k v)


encode : (comparable -> JE.Value) -> (v -> JE.Value) -> Dict comparable v -> JE.Value
encode encodeKey encodeValue dict =
    let
        encodeTuple : ( comparable, v ) -> JE.Value
        encodeTuple ( k, v ) =
            JE.object
                [ ( "key", encodeKey k )
                , ( "value", encodeValue v )
                ]
    in
    dict
        |> Dict.toList
        |> JE.list encodeTuple


decoder : Decoder comparable -> Decoder v -> Decoder (Dict comparable v)
decoder keyDecoder valueDecoder =
    let
        tupleDecoder : Decoder ( comparable, v )
        tupleDecoder =
            JD.map2 Tuple.pair
                (JD.field "key" keyDecoder)
                (JD.field "value" valueDecoder)
    in
    JD.list tupleDecoder
        |> JD.map Dict.fromList
