module Data.Vendor exposing
    ( Vendor
    , addCaps
    , addItem
    , emptyVendors
    , encodeVendors
    , getFrom
    , removeItem
    , restockVendors
    , subtractCaps
    , vendorsDecoder
    )

import Data.Item as Item exposing (Item)
import Data.Vendor.Shop as Shop exposing (Shop, ShopSpec)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.FloatExtra as Random
import Random.List
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import SeqSet exposing (SeqSet)


{-| The currentSpec is Shop.initialSpec + any global quest rewards
-}
type alias Vendor =
    { shop : Shop
    , currentSpec : ShopSpec
    , items : Dict Item.Id Item
    , caps : Int
    , discountPct : Int
    }


getFrom : SeqDict Shop Vendor -> Shop -> Vendor
getFrom vendors shop =
    SeqDict.get shop vendors
        |> Maybe.withDefault (emptyVendor shop)


emptyVendors : SeqDict Shop Vendor
emptyVendors =
    Shop.all
        |> List.map (\name_ -> ( name_, emptyVendor name_ ))
        |> SeqDict.fromList


emptyVendor : Shop -> Vendor
emptyVendor shop =
    { shop = shop
    , currentSpec = Shop.initialSpec shop
    , items = Dict.empty
    , caps = 0
    , discountPct = 0
    }


capsGenerator : ShopSpec -> Generator Int
capsGenerator { caps } =
    Random.normallyDistributedInt caps


stockGenerator : ShopSpec -> Generator (List ( Item.UniqueKey, Int ))
stockGenerator { stock } =
    let
        stockSize =
            SeqDict.size stock

        halfOrMore n =
            Random.int (max 1 (n // 2)) n
    in
    halfOrMore stockSize
        |> Random.andThen (\count -> Random.List.choices count (SeqDict.toList stock))
        |> Random.andThen
            (\( chosen, _ ) ->
                chosen
                    |> List.map
                        (\( uniqueKey, { maxCount } ) ->
                            Random.int 0 maxCount
                                |> Random.map (Tuple.pair uniqueKey)
                        )
                    |> Random.Extra.sequence
            )
        |> Random.map (List.filter (\( _, count ) -> count > 0))


restockVendors : Int -> SeqDict Shop Vendor -> Generator ( SeqDict Shop Vendor, Int )
restockVendors lastItemId vendors =
    let
        restockVendor : Int -> Vendor -> Generator ( Vendor, Int )
        restockVendor lastItemId_ vendor =
            let
                stockKeys : SeqSet Item.UniqueKey
                stockKeys =
                    vendor.currentSpec.stock
                        |> SeqDict.keys
                        |> SeqSet.fromList
            in
            Random.map2
                (\newCaps newStock ->
                    let
                        ( items, newLastId ) =
                            newStock
                                |> List.foldl
                                    (\( uniqueKey, count ) ( accItems, accItemId ) ->
                                        let
                                            ( item, incrementedId ) =
                                                Item.create
                                                    { lastId = accItemId
                                                    , uniqueKey = uniqueKey
                                                    , count = count
                                                    }
                                        in
                                        ( item :: accItems, incrementedId )
                                    )
                                    ( [], lastItemId_ )

                        newStockItems : Dict Item.Id Item
                        newStockItems =
                            Dict.fromList <| List.map (\i -> ( i.id, i )) items

                        nonStockItems : Dict Item.Id Item
                        nonStockItems =
                            vendor.items
                                |> Dict.filter (\_ item -> not <| SeqSet.member (Item.getUniqueKey item) stockKeys)
                    in
                    ( { vendor
                        | caps = newCaps
                        , items = Dict.union nonStockItems newStockItems
                      }
                    , newLastId
                    )
                )
                (capsGenerator vendor.currentSpec)
                (stockGenerator vendor.currentSpec)
    in
    Shop.all
        |> List.foldl
            (\name_ accGenerator ->
                accGenerator
                    |> Random.andThen
                        (\( accVendors, lastItemId_ ) ->
                            restockVendor
                                lastItemId_
                                (getFrom accVendors name_)
                                |> Random.map
                                    (\( restockedVendor, idAfterVendor ) ->
                                        ( SeqDict.insert name_ restockedVendor accVendors
                                        , idAfterVendor
                                        )
                                    )
                        )
            )
            (Random.constant ( vendors, lastItemId ))


encodeVendors : SeqDict Shop Vendor -> JE.Value
encodeVendors vendors =
    SeqDict.encode Shop.encode encode vendors


vendorsDecoder : Decoder (SeqDict Shop Vendor)
vendorsDecoder =
    SeqDict.decoder Shop.decoder decoder


encode : Vendor -> JE.Value
encode vendor =
    JE.object
        [ ( "shop", Shop.encode vendor.shop )
        , ( "currentSpec", Shop.encodeSpec vendor.currentSpec )
        , ( "items", Dict.encode JE.int Item.encode vendor.items )
        , ( "caps", JE.int vendor.caps )
        , ( "discountPct", JE.int vendor.discountPct )
        ]


decoder : Decoder Vendor
decoder =
    JD.succeed Vendor
        |> JD.andMap (JD.field "shop" Shop.decoder)
        |> JD.andMap (JD.field "currentSpec" Shop.specDecoder)
        |> JD.andMap (JD.field "items" (Dict.decoder JD.int Item.decoder))
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "discountPct" JD.int)


subtractCaps : Int -> Vendor -> Vendor
subtractCaps amount vendor =
    { vendor | caps = max 0 <| vendor.caps - amount }


addCaps : Int -> Vendor -> Vendor
addCaps amount vendor =
    { vendor | caps = vendor.caps + amount }


removeItem : Item.Id -> Int -> Vendor -> Vendor
removeItem id removedCount vendor =
    { vendor
        | items =
            vendor.items
                |> Dict.update id
                    (Maybe.andThen
                        (\oldItem ->
                            if oldItem.count > removedCount then
                                Just { oldItem | count = oldItem.count - removedCount }

                            else
                                Nothing
                        )
                    )
    }


addItem : Item -> Vendor -> Vendor
addItem item vendor =
    let
        id =
            Item.findMergeableId item vendor.items
                |> Maybe.withDefault item.id
    in
    { vendor
        | items =
            vendor.items
                |> Dict.update id
                    (\maybeCount ->
                        case maybeCount of
                            Nothing ->
                                Just item

                            Just oldItem ->
                                Just { oldItem | count = oldItem.count + item.count }
                    )
    }
