module Data.Vendor exposing
    ( Name(..)
    , Vendor
    , addCaps
    , addItem
    , all
    , barterSkill
    , emptyVendors
    , encodeVendors
    , forLocation
    , getFrom
    , isInLocation
    , name
    , nameWithLocation
    , removeItem
    , restockVendors
    , subtractCaps
    , vendorsDecoder
    )

import Data.Item as Item exposing (Item)
import Data.Map.Location as Location exposing (Location)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)
import Random.Extra
import Random.FloatExtra as Random exposing (NormalIntSpec)
import Random.List
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import SeqSet exposing (SeqSet)


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict Item.Id Item
    , caps : Int
    , barterSkill : Int
    }


type alias VendorSpec =
    { caps : NormalIntSpec
    , stock : List { uniqueKey : Item.UniqueKey, maxCount : Int }
    }


all : List Name
all =
    [ ArroyoHakunin
    , KlamathMaidaBuckner
    , DenFlick
    , ModocJo
    , VaultCityHappyHarry
    ]


spec : Name -> VendorSpec
spec name_ =
    case name_ of
        ArroyoHakunin ->
            { caps = { average = 50, maxDeviation = 20 }
            , stock =
                [ { uniqueKey = { kind = Item.HealingPowder }, maxCount = 4 }
                , { uniqueKey = { kind = Item.Robes }, maxCount = 1 }
                ]
            }

        KlamathMaidaBuckner ->
            { caps = { average = 150, maxDeviation = 80 }
            , stock =
                [ { uniqueKey = { kind = Item.HealingPowder }, maxCount = 3 }
                , { uniqueKey = { kind = Item.Stimpak }, maxCount = 2 }
                , { uniqueKey = { kind = Item.BigBookOfScience }, maxCount = 1 }
                , { uniqueKey = { kind = Item.DeansElectronics }, maxCount = 1 }
                , { uniqueKey = { kind = Item.Robes }, maxCount = 2 }
                ]
            }

        DenFlick ->
            { caps = { average = 280, maxDeviation = 120 }
            , stock =
                [ { uniqueKey = { kind = Item.HealingPowder }, maxCount = 1 }
                , { uniqueKey = { kind = Item.Stimpak }, maxCount = 3 }
                , { uniqueKey = { kind = Item.ScoutHandbook }, maxCount = 1 }
                , { uniqueKey = { kind = Item.GunsAndBullets }, maxCount = 1 }
                , { uniqueKey = { kind = Item.LeatherJacket }, maxCount = 1 }
                ]
            }

        ModocJo ->
            { caps = { average = 500, maxDeviation = 200 }
            , stock =
                [ { uniqueKey = { kind = Item.Stimpak }, maxCount = 5 }
                , { uniqueKey = { kind = Item.GunsAndBullets }, maxCount = 1 }
                , { uniqueKey = { kind = Item.FirstAidBook }, maxCount = 1 }
                , { uniqueKey = { kind = Item.LeatherJacket }, maxCount = 1 }
                , { uniqueKey = { kind = Item.LeatherArmor }, maxCount = 1 }
                ]
            }

        VaultCityHappyHarry ->
            { caps = { average = 300, maxDeviation = 120 }
            , stock =
                [ { uniqueKey = { kind = Item.Stimpak }, maxCount = 4 }
                , { uniqueKey = { kind = Item.ScoutHandbook }, maxCount = 2 }
                , { uniqueKey = { kind = Item.MetalArmor }, maxCount = 1 }
                ]
            }


barterSkill : Name -> Int
barterSkill name_ =
    case name_ of
        ArroyoHakunin ->
            30

        KlamathMaidaBuckner ->
            55

        DenFlick ->
            80

        ModocJo ->
            100

        VaultCityHappyHarry ->
            80


getFrom : SeqDict Name Vendor -> Name -> Vendor
getFrom vendors name_ =
    SeqDict.get name_ vendors
        |> Maybe.withDefault (emptyVendor name_)


emptyVendors : SeqDict Name Vendor
emptyVendors =
    all
        |> List.map (\name_ -> ( name_, emptyVendor name_ ))
        |> SeqDict.fromList


emptyVendor : Name -> Vendor
emptyVendor name_ =
    { items = Dict.empty
    , caps = 0
    , barterSkill = barterSkill name_
    , name = name_
    }


capsGenerator : VendorSpec -> Generator Int
capsGenerator { caps } =
    Random.normallyDistributedInt caps


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
                            Random.int 0 maxCount
                                |> Random.map (Tuple.pair uniqueKey)
                        )
                    |> Random.Extra.sequence
            )
        |> Random.map (List.filter (\( _, count ) -> count > 0))


restockVendors : Int -> SeqDict Name Vendor -> Generator ( SeqDict Name Vendor, Int )
restockVendors lastItemId vendors =
    let
        restockVendor : Int -> VendorSpec -> Vendor -> Generator ( Vendor, Int )
        restockVendor lastItemId_ spec_ vendor =
            let
                stockKeys : SeqSet Item.UniqueKey
                stockKeys =
                    spec_.stock
                        |> List.map .uniqueKey
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
                                        ( SeqDict.insert name_ restockedVendor accVendors
                                        , idAfterVendor
                                        )
                                    )
                        )
            )
            (Random.constant ( vendors, lastItemId ))


encodeVendors : SeqDict Name Vendor -> JE.Value
encodeVendors vendors =
    SeqDict.encode encodeName encode vendors


vendorsDecoder : Decoder (SeqDict Name Vendor)
vendorsDecoder =
    SeqDict.decoder nameDecoder decoder


encodeName : Name -> JE.Value
encodeName name_ =
    JE.string <|
        case name_ of
            ArroyoHakunin ->
                "arroyo-hakunin"

            KlamathMaidaBuckner ->
                "klamath-maida-buckner"

            DenFlick ->
                "den-flick"

            ModocJo ->
                "modoc-jo"

            VaultCityHappyHarry ->
                "vault-city-happy-harry"


nameDecoder : Decoder Name
nameDecoder =
    JD.string
        |> JD.andThen
            (\name_ ->
                case name_ of
                    "arroyo-hakunin" ->
                        JD.succeed ArroyoHakunin

                    "klamath-maida-buckner" ->
                        JD.succeed KlamathMaidaBuckner

                    "den-flick" ->
                        JD.succeed DenFlick

                    "modoc-jo" ->
                        JD.succeed ModocJo

                    "vault-city-happy-harry" ->
                        JD.succeed VaultCityHappyHarry

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


name : Name -> String
name name_ =
    case name_ of
        ArroyoHakunin ->
            "Hakunin"

        KlamathMaidaBuckner ->
            "Maida Buckner"

        DenFlick ->
            "Flick"

        ModocJo ->
            "Jo"

        VaultCityHappyHarry ->
            "Happy Harry"


nameWithLocation : Name -> String
nameWithLocation name_ =
    case name_ of
        ArroyoHakunin ->
            "Hakunin (Arroyo)"

        KlamathMaidaBuckner ->
            "Maida Buckner (Klamath)"

        DenFlick ->
            "Flick (Den)"

        ModocJo ->
            "Jo (Modoc)"

        VaultCityHappyHarry ->
            "Happy Harry (Vault City)"


location : Name -> Location
location name_ =
    case name_ of
        ArroyoHakunin ->
            Location.Arroyo

        KlamathMaidaBuckner ->
            Location.Klamath

        DenFlick ->
            Location.Den

        ModocJo ->
            Location.Modoc

        VaultCityHappyHarry ->
            Location.VaultCity


locationsWithVendors : SeqDict Location Name
locationsWithVendors =
    all
        |> List.map (\name_ -> ( location name_, name_ ))
        |> SeqDict.fromList


forLocation : Location -> Maybe Name
forLocation loc =
    SeqDict.get loc locationsWithVendors


isInLocation : Location -> Bool
isInLocation loc =
    SeqDict.member loc locationsWithVendors
