module AssocList.Extra exposing (encode)

import AssocList
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
