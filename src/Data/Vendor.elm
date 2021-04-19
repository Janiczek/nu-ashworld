module Data.Vendor exposing
    ( Name(..)
    , Vendor
    , addCaps
    , addItem
    , emptyVendors
    , encodeVendors
    , getFrom
    , name
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


type Name
    = KlamathMaidaBuckner


type alias Vendor =
    { name : Name
    , items : Dict Item.Id Item
    , caps : Int
    , barterSkill : Int
    }


type alias VendorSpec =
    { avgCaps : Int
    , maxCapsDeviation : Int
    , stock : List { uniqueKey : Item.UniqueKey, maxCount : Int }
    }


all : List Name
all =
    [ KlamathMaidaBuckner ]


spec : Name -> VendorSpec
spec name_ =
    case name_ of
        KlamathMaidaBuckner ->
            klamathSpec


barterSkill : Name -> Int
barterSkill name_ =
    case name_ of
        KlamathMaidaBuckner ->
            55


getFrom : Dict_.Dict Name Vendor -> Name -> Vendor
getFrom vendors name_ =
    Dict_.get name_ vendors
        |> Maybe.withDefault (emptyVendor name_)


emptyVendors : Dict_.Dict Name Vendor
emptyVendors =
    all
        |> List.map (\name_ -> ( name_, emptyVendor name_ ))
        |> Dict_.fromList


emptyVendor : Name -> Vendor
emptyVendor name_ =
    { items = Dict.empty
    , caps = 0
    , barterSkill = barterSkill name_
    , name = name_
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


restockVendors : Int -> Dict_.Dict Name Vendor -> Generator ( Dict_.Dict Name Vendor, Int )
restockVendors lastItemId vendors =
    let
        restockVendor : Int -> VendorSpec -> Vendor -> Generator ( Vendor, Int )
        restockVendor lastItemId_ spec_ vendor =
            let
                stockKeys : Set_.Set Item.UniqueKey
                stockKeys =
                    spec_.stock
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
                (capsGenerator spec_)
                (stockGenerator spec_)
    in
    all
        |> List.foldl
            (\name_ accGenerator ->
                accGenerator
                    |> Random.andThen
                        (\( accVendors, lastItemId_ ) ->
                            restockVendor
                                lastItemId_
                                (spec name_)
                                (getFrom accVendors name_)
                                |> Random.map
                                    (\( restockedVendor, idAfterVendor ) ->
                                        ( Dict_.insert name_ restockedVendor accVendors
                                        , idAfterVendor
                                        )
                                    )
                        )
            )
            (Random.constant ( vendors, lastItemId ))


encodeVendors : Dict_.Dict Name Vendor -> JE.Value
encodeVendors vendors =
    Dict_.encode encodeName encode vendors


vendorsDecoder : Decoder (Dict_.Dict Name Vendor)
vendorsDecoder =
    Dict_.decoder nameDecoder decoder


encodeName : Name -> JE.Value
encodeName name_ =
    JE.string <|
        case name_ of
            KlamathMaidaBuckner ->
                "klamath-maida-buckner"


nameDecoder : Decoder Name
nameDecoder =
    JD.string
        |> JD.andThen
            (\name_ ->
                case name_ of
                    "klamath-maida-buckner" ->
                        JD.succeed KlamathMaidaBuckner

                    _ ->
                        JD.fail <| "unknown Vendor.Name: '" ++ name_ ++ "'"
            )


encode : Vendor -> JE.Value
encode vendor =
    JE.object
        [ ( "name", encodeName vendor.name )
        , ( "items", Dict.encode JE.int Item.encode vendor.items )
        , ( "caps", JE.int vendor.caps )
        , ( "barterSkill", JE.int vendor.barterSkill )
        ]


decoder : Decoder Vendor
decoder =
    JD.succeed Vendor
        |> JD.andMap (JD.field "name" nameDecoder)
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
                                Just { oldItem | count = oldItem.count + item.count }
                    )
    }


name : Name -> String
name name_ =
    case name_ of
        KlamathMaidaBuckner ->
            "Maida Buckner (Klamath)"
