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


type alias Stock =
    List { kind : Item.Kind, maxCount : Int }


stockGenerator : Stock -> Generator (List ( Item.Kind, Int ))
stockGenerator list =
    let
        listLength =
            List.length list

        halfOrMore n =
            Random.int (max 1 (n // 2)) n
    in
    halfOrMore listLength
        |> Random.andThen (\count -> Random.List.choices count list)
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
        restockVendor : Stock -> Vendor -> Generator Vendor
        restockVendor stock vendor =
            stockGenerator stock
                |> Random.map (\newStock -> { vendor | stockItems = Dict_.fromList newStock })
    in
    {- TODO perhaps it's better to have VendorNpc = KlamathMaidaBuckner | ...
       than this (<|) magic?
    -}
    [ restockVendor klamathStock vendors.klamath
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


klamathStock : Stock
klamathStock =
    [ { kind = Item.Stimpak, maxCount = 4 } ]
