module Data.Item exposing
    ( Item, codec
    , Id
    , UniqueKey, uniqueKeyCodec
    , create, findMergeableId, getUniqueKey
    )

{-|

@docs Item, codec
@docs Id
@docs UniqueKey, uniqueKeyCodec
@docs create, findMergeableId, getUniqueKey

-}

import Codec exposing (Codec)
import Data.Item.Kind as Kind exposing (Kind)
import Dict exposing (Dict)
import Dict.Extra as Dict


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


codec : Codec Item
codec =
    Codec.object Item
        |> Codec.field "id" .id Codec.int
        |> Codec.field "kind" .kind Kind.codec
        |> Codec.field "count" .count Codec.int
        |> Codec.buildObject


create :
    { lastId : Int
    , uniqueKey : UniqueKey
    , count : Int
    }
    -> ( Item, Int )
create { lastId, uniqueKey, count } =
    let
        newLastId : Int
        newLastId =
            lastId + 1

        item : Item
        item =
            { id = newLastId
            , kind = uniqueKey.kind
            , count = count
            }
    in
    ( item, newLastId )


{-| This identifies item.

---- the below written before we tried to do mods a bit differently ----

Right now this is just the item Kind (eg.
HuntingRifle) but later when we add Mods, UniqueKey will also contain them and
so you will be able to differentiate between (HuntingRifle, []) and
(HuntingRifle, [HuntingRifleUpgrade]) or
(HuntingRifle, [HasAmmo (24, Ammo223FMJ)]) or something.

This hopefully will prevent bugs like player with upgraded weapon buying a
non-upgraded one and it becoming automatically (wrongly) upgraded too.

-}
type alias UniqueKey =
    -- TODO mods
    { kind : Kind
    }


uniqueKeyCodec : Codec UniqueKey
uniqueKeyCodec =
    Codec.object UniqueKey
        |> Codec.field "kind" .kind Kind.codec
        |> Codec.buildObject


getUniqueKey : Item -> UniqueKey
getUniqueKey item =
    { kind = item.kind }


findMergeableId : Item -> Dict Id Item -> Maybe Id
findMergeableId item items =
    let
        uniqueKey : UniqueKey
        uniqueKey =
            getUniqueKey item
    in
    items
        |> Dict.find (\_ item_ -> getUniqueKey item_ == uniqueKey)
        |> Maybe.map Tuple.first
