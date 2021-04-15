module Data.Vendor exposing
    ( Vendor
    , Vendors
    , addCaps
    , addItem
    , emptyVendors
    , encodeVendors
    , listVendors
    , removeItem
    , restockVendors
    , subtractCaps
    , vendorsDecoder
    )

import AssocList as Dict_
import AssocList.ExtraExtra as Dict_
import AssocSet as Set_
import Data.Item as Item exposing (Item)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.Float
import Random.List


type alias Vendor =
    { items : Dict Item.Id Item
    , caps : Int
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }


listVendors : Vendors -> List Vendor
listVendors vendors =
    -- TODO perhaps this would be better as a dict really...
    [ vendors.klamath
    ]


type alias VendorSpec =
    { avgCaps : Int
    , maxCapsDeviation : Int
    , stock : List { uniqueKey : Item.UniqueKey, maxCount : Int }
    }


emptyVendors : Vendors
emptyVendors =
    { klamath = emptyVendor 55
    }


emptyVendor : Int -> Vendor
emptyVendor barterSkill =
    { items = Dict.empty
    , caps = 0
    , barterSkill = barterSkill
    }


capsGenerator : VendorSpec -> Generator Int
capsGenerator { avgCaps, maxCapsDeviation } =
    -- dev/3 == 99.7% chance the value will fall inside the range
    -- we'll just clamp the remaining 0.3%
    Random.Float.normal (toFloat avgCaps) (toFloat maxCapsDeviation / 3)
        |> Random.map
            (\n ->
                clamp
                    (avgCaps - maxCapsDeviation)
                    (avgCaps + maxCapsDeviation)
                    (round n)
            )


stockGenerator : VendorSpec -> Generator (List ( Item.UniqueKey, Int ))
stockGenerator { stock } =
    let
        listLength =
            List.length stock

        halfOrMore n =
            Random.int (max 1 (n // 2)) n
    in
    halfOrMore listLength
        |> Random.andThen (\count -> Random.List.choices count stock)
        |> Random.andThen
            (\( chosen, _ ) ->
                chosen
                    |> List.map
                        (\{ uniqueKey, maxCount } ->
                            halfOrMore maxCount
                                |> Random.map (Tuple.pair uniqueKey)
                        )
                    |> Random.Extra.sequence
            )


restockVendors : Int -> Vendors -> Generator ( Vendors, Int )
restockVendors lastItemId vendors =
    let
        restockVendor : Int -> VendorSpec -> Vendor -> Generator ( Vendor, Int )
        restockVendor lastItemId_ spec vendor =
            let
                stockKeys : Set_.Set Item.UniqueKey
                stockKeys =
                    spec.stock
                        |> List.map .uniqueKey
                        |> Set_.fromList
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
                                |> Dict.filter (\_ item -> not <| Set_.member (Item.getUniqueKey item) stockKeys)
                    in
                    ( { vendor
                        | caps = newCaps
                        , items = Dict.union nonStockItems newStockItems
                      }
                    , newLastId
                    )
                )
                (capsGenerator spec)
                (stockGenerator spec)
    in
    restockVendor lastItemId klamathSpec vendors.klamath
        |> Random.map
            (\( restockedKlamath, idAfterKlamath ) ->
                ( { vendors | klamath = restockedKlamath }
                , idAfterKlamath
                )
            )


encodeVendors : Vendors -> JE.Value
encodeVendors vendors =
    JE.object
        [ ( "klamath", encode vendors.klamath )
        ]


vendorsDecoder : Decoder Vendors
vendorsDecoder =
    JD.succeed Vendors
        |> JD.andMap (JD.field "klamath" decoder)


encode : Vendor -> JE.Value
encode vendor =
    JE.object
        [ ( "items", Dict.encode JE.int Item.encode vendor.items )
        , ( "caps", JE.int vendor.caps )
        , ( "barterSkill", JE.int vendor.barterSkill )
        ]


decoder : Decoder Vendor
decoder =
    JD.succeed Vendor
        |> JD.andMap (JD.field "items" (Dict.decoder JD.int Item.decoder))
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "barterSkill" JD.int)


klamathSpec : VendorSpec
klamathSpec =
    { avgCaps = 1000
    , maxCapsDeviation = 500
    , stock = [ { uniqueKey = { kind = Item.Stimpak }, maxCount = 4 } ]
    }


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
                    (\maybeItem ->
                        case maybeItem of
                            Nothing ->
                                Nothing

                            Just oldItem ->
                                if oldItem.count > removedCount then
                                    Just { oldItem | count = oldItem.count - removedCount }

                                else
                                    Nothing
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
                                Just <| { oldItem | count = oldItem.count + item.count }
                    )
    }
