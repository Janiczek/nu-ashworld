module Set.ExtraExtra exposing (encode)

import Json.Encode as JE
import Set exposing (Set)


encode : (comparable -> JE.Value) -> Set comparable -> JE.Value
encode encodeInner set =
    set
        |> Set.toList
        |> JE.list encodeInner
