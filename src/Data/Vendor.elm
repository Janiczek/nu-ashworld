module Data.Vendor exposing
    ( Vendor
    , Vendors
    , emptyVendors
    , encodeVendors
    , restockVendors
    , vendorsDecoder
    )

import AssocList as Dict_
import AssocList.ExtraExtra as Dict_
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
    { playerItems : Dict Item.Id Item
    , stockItems : Dict_.Dict Item.Kind Int
    , caps : Int
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }


type alias VendorSpec =
    { avgCaps : Int
    , maxCapsDeviation : Int
    , stock : List { kind : Item.Kind, maxCount : Int }
    }


emptyVendors : Vendors
emptyVendors =
    { klamath = emptyVendor 55
    }


emptyVendor : Int -> Vendor
emptyVendor barterSkill =
    { playerItems = Dict.empty
    , stockItems = Dict_.empty
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


stockGenerator : VendorSpec -> Generator (List ( Item.Kind, Int ))
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
                        (\{ kind, maxCount } ->
                            halfOrMore maxCount
                                |> Random.map (Tuple.pair kind)
                        )
                    |> Random.Extra.sequence
            )


restockVendors : Vendors -> Generator Vendors
restockVendors vendors =
    let
        restockVendor : VendorSpec -> Vendor -> Generator Vendor
        restockVendor spec vendor =
            Random.map2
                (\newCaps newStock ->
                    { vendor
                        | caps = newCaps
                        , stockItems = Dict_.fromList newStock
                    }
                )
                (capsGenerator spec)
                (stockGenerator spec)
    in
    {- TODO perhaps it's better to have VendorNpc = KlamathMaidaBuckner | ...
       than this (<|) magic?
    -}
    [ restockVendor klamathSpec vendors.klamath
        |> Random.map (\v vs -> { vs | klamath = v })
    ]
        |> Random.Extra.sequence
        |> Random.map (List.foldl (<|) vendors)


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
        [ ( "playerItems", Dict.encode JE.int Item.encode vendor.playerItems )
        , ( "stockItems", Dict_.encode Item.encodeKind JE.int vendor.stockItems )
        , ( "caps", JE.int vendor.caps )
        , ( "barterSkill", JE.int vendor.barterSkill )
        ]


decoder : Decoder Vendor
decoder =
    JD.succeed Vendor
        |> JD.andMap (JD.field "playerItems" (Dict.decoder JD.int Item.decoder))
        |> JD.andMap (JD.field "stockItems" (Dict_.decoder Item.kindDecoder JD.int))
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "barterSkill" JD.int)


klamathSpec : VendorSpec
klamathSpec =
    { avgCaps = 1000
    , maxCapsDeviation = 500
    , stock = [ { kind = Item.Stimpak, maxCount = 4 } ]
    }
