module Data.Vendor exposing
    ( Vendor
    , Vendors
    , emptyVendors
    , encodeVendors
    , restockVendors
    , vendorsDecoder
    )

import AssocSet as Set_
import AssocSet.Extra as Set_
import Data.Item as Item exposing (VendorItem)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JDE
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.List


type alias Vendor =
    { items : Set_.Set VendorItem
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }


emptyVendors : Vendors
emptyVendors =
    { klamath = { items = Set_.empty, barterSkill = 55 }
    }


type alias Stock =
    List { kind : Item.Kind, maxCount : Int }


stockGenerator : Stock -> Generator (List { kind : Item.Kind, count : Int })
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
                                |> Random.map
                                    (\count ->
                                        { kind = kind
                                        , count = count
                                        }
                                    )
                        )
                    |> Random.Extra.sequence
            )


restockVendors : Vendors -> Generator Vendors
restockVendors vendors =
    let
        restockVendor : Stock -> Vendor -> Generator Vendor
        restockVendor stock vendor =
            let
                playerItems : Set_.Set VendorItem
                playerItems =
                    Set_.filter Item.isPlayerItem vendor.items
            in
            stockGenerator stock
                |> Random.map
                    (\newStock ->
                        let
                            stockVendorItems : Set_.Set VendorItem
                            stockVendorItems =
                                newStock
                                    |> List.map (\{ kind, count } -> Item.Stock ( kind, count ))
                                    |> Set_.fromList

                            newItems : Set_.Set VendorItem
                            newItems =
                                Set_.union playerItems stockVendorItems
                        in
                        { vendor | items = newItems }
                    )
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
        |> JDE.andMap (JD.field "klamath" decoder)


encode : Vendor -> JE.Value
encode vendor =
    JE.object
        [ ( "items", Set_.encode Item.encodeVendorItem vendor.items )
        , ( "barterSkill", JE.int vendor.barterSkill )
        ]


decoder : Decoder Vendor
decoder =
    JD.succeed Vendor
        |> JDE.andMap (JD.field "items" (Set_.decoder Item.vendorItemDecoder))
        |> JDE.andMap (JD.field "barterSkill" JD.int)


klamathStock : Stock
klamathStock =
    [ { kind = Item.Stimpak, maxCount = 4 } ]
