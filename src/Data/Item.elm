module Data.Item exposing
    ( Category(..)
    , Id
    , Item
    , Kind(..)
    , VendorItem(..)
    , category
    , decoder
    , encode
    , encodeVendorItem
    , isPlayerItem
    , vendorItemDecoder
    )

import AssocList as Dict_
import AssocList.Extra as Dict_
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JDE
import Json.Encode as JE


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


type Category
    = Consumable


type Kind
    = Stimpak


type VendorItem
    = Stock ( Kind, Int )
    | PlayerItem Item


isPlayerItem : VendorItem -> Bool
isPlayerItem vendorItem =
    case vendorItem of
        PlayerItem _ ->
            True

        Stock _ ->
            False


category : Kind -> Category
category kind =
    case kind of
        Stimpak ->
            Consumable


encode : Item -> JE.Value
encode item =
    JE.object
        [ ( "id", JE.int item.id )
        , ( "kind", encodeKind item.kind )
        , ( "count", JE.int item.count )
        ]


decoder : Decoder Item
decoder =
    JD.succeed Item
        |> JDE.andMap (JD.field "id" JD.int)
        |> JDE.andMap (JD.field "kind" kindDecoder)
        |> JDE.andMap (JD.field "count" JD.int)


encodeKind : Kind -> JE.Value
encodeKind kind =
    case kind of
        Stimpak ->
            JE.string "stimpak"


kindDecoder : Decoder Kind
kindDecoder =
    JD.string
        |> JD.andThen
            (\kind ->
                case kind of
                    "stimpak" ->
                        JD.succeed Stimpak

                    _ ->
                        JD.fail <| "Unknown item kind: '" ++ kind ++ "'"
            )


encodeVendorItem : VendorItem -> JE.Value
encodeVendorItem vendorItem =
    case vendorItem of
        Stock ( kind, count ) ->
            JE.object
                [ ( "type", JE.string "stock" )
                , ( "kind", encodeKind kind )
                , ( "count", JE.int count )
                ]

        PlayerItem item ->
            JE.object
                [ ( "type", JE.string "playerItem" )
                , ( "item", encode item )
                ]


vendorItemDecoder : Decoder VendorItem
vendorItemDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "stock" ->
                        JD.map2 (\kind count -> Stock ( kind, count ))
                            (JD.field "kind" kindDecoder)
                            (JD.field "count" JD.int)

                    "playerItem" ->
                        JD.field "item" decoder
                            |> JD.map PlayerItem

                    _ ->
                        JD.fail <| "Unknown vendor item: '" ++ type_ ++ "'"
            )
