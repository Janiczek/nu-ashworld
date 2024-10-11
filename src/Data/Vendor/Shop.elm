module Data.Vendor.Shop exposing
    ( Shop(..), encode, decoder
    , all, allAvailable, isAvailable
    , personName, description, barterSkill, initialSpec
    , location, forLocation, isInLocation
    , ShopSpec, encodeSpec, specDecoder
    )

{-|

@docs Shop, encode, decoder
@docs all, allAvailable, isAvailable
@docs personName, description, barterSkill, initialSpec
@docs location, forLocation, isInLocation

@docs ShopSpec, encodeSpec, specDecoder

-}

import Data.Item as Item
import Data.Item.Kind as ItemKind
import Data.Map.Location as Location exposing (Location)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random.FloatExtra as Random exposing (NormalIntSpec)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


type Shop
    = ArroyoHakunin
    | KlamathMaida
    | KlamathVic
    | DenFlick
    | ModocJo
    | VaultCityRandal
    | VaultCityHappyHarry
    | GeckoSurvivalGearPercy
    | ReddingAscorti
    | BrokenHillsGeneralStoreLiz
    | BrokenHillsChemistJacob
    | NewRenoArmsEldridge
    | NewRenoRenescoPharmacy
    | NCRBuster
    | NCRDuppo
    | SanFranciscoFlyingDragon8LaoChou
    | SanFranciscoRed888GunsMaiDaChiang
    | SanFranciscoPunksCal
    | SanFranciscoPunksJenna


type alias ShopSpec =
    { caps : NormalIntSpec
    , stock : List { uniqueKey : Item.UniqueKey, maxCount : Int }
    }


all : List Shop
all =
    [ ArroyoHakunin
    , KlamathMaida
    , KlamathVic
    , DenFlick
    , ModocJo
    , VaultCityRandal
    , VaultCityHappyHarry
    , GeckoSurvivalGearPercy
    , ReddingAscorti
    , BrokenHillsGeneralStoreLiz
    , BrokenHillsChemistJacob
    , NewRenoArmsEldridge
    , NewRenoRenescoPharmacy
    , NCRBuster
    , NCRDuppo
    , SanFranciscoFlyingDragon8LaoChou
    , SanFranciscoRed888GunsMaiDaChiang
    , SanFranciscoPunksCal
    , SanFranciscoPunksJenna
    ]


allAvailable : SeqSet Shop -> List Shop
allAvailable fromQuestGlobalRewards =
    all
        |> List.filter (isAvailable fromQuestGlobalRewards)


isAvailable : SeqSet Shop -> Shop -> Bool
isAvailable questRewards shop =
    let
        asReward : () -> Bool
        asReward () =
            SeqSet.member shop questRewards
    in
    case shop of
        ArroyoHakunin ->
            True

        KlamathMaida ->
            True

        KlamathVic ->
            asReward ()

        DenFlick ->
            True

        ModocJo ->
            True

        VaultCityRandal ->
            True

        VaultCityHappyHarry ->
            True

        GeckoSurvivalGearPercy ->
            True

        ReddingAscorti ->
            True

        BrokenHillsGeneralStoreLiz ->
            True

        BrokenHillsChemistJacob ->
            True

        NewRenoArmsEldridge ->
            True

        NewRenoRenescoPharmacy ->
            True

        NCRBuster ->
            True

        NCRDuppo ->
            True

        SanFranciscoFlyingDragon8LaoChou ->
            True

        SanFranciscoRed888GunsMaiDaChiang ->
            True

        SanFranciscoPunksCal ->
            asReward ()

        SanFranciscoPunksJenna ->
            asReward ()


personName : Shop -> String
personName shop =
    case shop of
        ArroyoHakunin ->
            "Hakunin"

        KlamathMaida ->
            "Maida"

        KlamathVic ->
            "Vic"

        DenFlick ->
            "Flick"

        ModocJo ->
            "Jo"

        VaultCityRandal ->
            "Randal"

        VaultCityHappyHarry ->
            "Happy Harry"

        GeckoSurvivalGearPercy ->
            "Percy"

        ReddingAscorti ->
            "Ascorti"

        BrokenHillsGeneralStoreLiz ->
            "Liz"

        BrokenHillsChemistJacob ->
            "Jacob the Chemist"

        NewRenoArmsEldridge ->
            "Eldridge"

        NewRenoRenescoPharmacy ->
            "Renesco"

        NCRBuster ->
            "Buster"

        NCRDuppo ->
            "Duppo"

        SanFranciscoFlyingDragon8LaoChou ->
            "Lao Chou"

        SanFranciscoRed888GunsMaiDaChiang ->
            "Mai Da Chiang"

        SanFranciscoPunksCal ->
            "Cal"

        SanFranciscoPunksJenna ->
            "Jenna"


description : Shop -> String
description shop =
    case shop of
        ArroyoHakunin ->
            "Before you stands Hakunin, the Arroyo village shaman. He appraises you with his crazy eyes from somewhere in the world only he inhabits..."

        KlamathMaida ->
            "You see Maida Buckner, Mrs. Buckner's daughter: a plain looking, sturdily built young woman with a scowl on her face."

        KlamathVic ->
            "You see Vic, a wasteland trader and mechanic who works among the tribes of northern New California. He specializes in pre-War technologies."

        DenFlick ->
            "You see Flick, a thin, greasy looking man with a nasty facial twitch."

        ModocJo ->
            "In the middle of the trading post stands Jo: the sheriff/mayor of Modoc. An average person, of average height, of average complexion. Nothing out of the ordinary."

        VaultCityRandal ->
            "You see Randal, the Vault City Chief Amenities Officer. He's a middle-aged man with thinning black hair."

        VaultCityHappyHarry ->
            "You see a short, jovial man and the owner of this store, Happy Harry."

        GeckoSurvivalGearPercy ->
            "You see a shorter and rather stout ghoul, Percy. He's nattily attired-uh, for a ghoul, that is."

        ReddingAscorti ->
            "You see Ascorti, a well-dressed man with a greasy look to him who happens to be the mayor of Redding."

        BrokenHillsGeneralStoreLiz ->
            "You see Liz, the manager of the Broken Hills General Store. She's a middle-aged woman whose scowl has eroded her face. She looks like one of those people who takes a perverse pleasure in a hard life."

        BrokenHillsChemistJacob ->
            "You see a bedraggled man in a stained lab coat. His hands are discolored from chemicals. It's Jacob the Chemist."

        NewRenoArmsEldridge ->
            "You see Eldridge, a heavily armed man covered with grease. He is gazing at his weapon collection on the walls and smiling dreamily."

        NewRenoRenescoPharmacy ->
            "You see the old man Renesco, in his pharmacy. He wears a pair of huge, garish glasses. He sighs irritatedly as you watch."

        NCRBuster ->
            "You're looking at Buster, the gun guy. His clothes are ragged and he's got gun-bluing all over his hands, arms, and face. Still, he seems pretty cheerful."

        NCRDuppo ->
            "You see a red-faced, friendly looking man. It's Duppo. He runs the Stockmen's Association. He's a stocky fellow and with constantly flushed face and shock of thin blond hair. He walks with a slight limp."

        SanFranciscoFlyingDragon8LaoChou ->
            "You see a man in functional, comfortable clothing. He's Lao Chou, the shopkeeper."

        SanFranciscoRed888GunsMaiDaChiang ->
            "You see an enthusiastic Shi named Mai Da Chiang, the owner of Red 888 Guns. He looks like he's running on permanent overdrive."

        SanFranciscoPunksCal ->
            "You see Cal, the constantly bored but friendly looking gun merchant."

        SanFranciscoPunksJenna ->
            "You see Jenna, the merchant on the PMV Valdez."


location : Shop -> Location
location shop =
    case shop of
        ArroyoHakunin ->
            Location.Arroyo

        KlamathMaida ->
            Location.Klamath

        KlamathVic ->
            Location.Klamath

        DenFlick ->
            Location.Den

        ModocJo ->
            Location.Modoc

        VaultCityRandal ->
            Location.VaultCity

        VaultCityHappyHarry ->
            Location.VaultCity

        GeckoSurvivalGearPercy ->
            Location.Gecko

        ReddingAscorti ->
            Location.Redding

        BrokenHillsGeneralStoreLiz ->
            Location.BrokenHills

        BrokenHillsChemistJacob ->
            Location.BrokenHills

        NewRenoArmsEldridge ->
            Location.NewReno

        NewRenoRenescoPharmacy ->
            Location.NewReno

        NCRBuster ->
            Location.NewCaliforniaRepublic

        NCRDuppo ->
            Location.NewCaliforniaRepublic

        SanFranciscoFlyingDragon8LaoChou ->
            Location.SanFrancisco

        SanFranciscoRed888GunsMaiDaChiang ->
            Location.SanFrancisco

        SanFranciscoPunksCal ->
            Location.SanFrancisco

        SanFranciscoPunksJenna ->
            Location.SanFrancisco


barterSkill : Shop -> Int
barterSkill shop =
    case shop of
        ArroyoHakunin ->
            30

        KlamathMaida ->
            55

        KlamathVic ->
            50

        DenFlick ->
            80

        ModocJo ->
            100

        VaultCityRandal ->
            90

        VaultCityHappyHarry ->
            80

        GeckoSurvivalGearPercy ->
            -- 0 in the game
            70

        ReddingAscorti ->
            90

        BrokenHillsGeneralStoreLiz ->
            120

        BrokenHillsChemistJacob ->
            115

        NewRenoArmsEldridge ->
            115

        NewRenoRenescoPharmacy ->
            110

        NCRBuster ->
            120

        NCRDuppo ->
            120

        SanFranciscoFlyingDragon8LaoChou ->
            150

        SanFranciscoRed888GunsMaiDaChiang ->
            140

        SanFranciscoPunksCal ->
            85

        SanFranciscoPunksJenna ->
            85


{-| This can later be extended by global rewards.
-}
initialSpec : Shop -> ShopSpec
initialSpec shop =
    case shop of
        ArroyoHakunin ->
            { caps = { average = 50, maxDeviation = 20 }
            , stock =
                [ { uniqueKey = { kind = ItemKind.HealingPowder }, maxCount = 3 }
                , { uniqueKey = { kind = ItemKind.Robes }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.Fruit }, maxCount = 2 }
                , { uniqueKey = { kind = ItemKind.Knife }, maxCount = 1 }
                ]
            }

        KlamathMaida ->
            { caps = { average = 150, maxDeviation = 80 }
            , stock =
                [ { uniqueKey = { kind = ItemKind.HealingPowder }, maxCount = 3 }
                , { uniqueKey = { kind = ItemKind.Stimpak }, maxCount = 2 }
                , { uniqueKey = { kind = ItemKind.BigBookOfScience }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.DeansElectronics }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.Robes }, maxCount = 2 }
                ]
            }

        KlamathVic ->
            { caps = Debug.todo "vic caps"
            , stock = Debug.todo "vic stock"
            }

        DenFlick ->
            { caps = { average = 280, maxDeviation = 120 }
            , stock =
                [ { uniqueKey = { kind = ItemKind.HealingPowder }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.Stimpak }, maxCount = 3 }
                , { uniqueKey = { kind = ItemKind.ScoutHandbook }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.GunsAndBullets }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.LeatherJacket }, maxCount = 1 }
                ]
            }

        ModocJo ->
            { caps = { average = 500, maxDeviation = 200 }
            , stock =
                [ { uniqueKey = { kind = ItemKind.Stimpak }, maxCount = 5 }
                , { uniqueKey = { kind = ItemKind.GunsAndBullets }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.FirstAidBook }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.LeatherJacket }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.LeatherArmor }, maxCount = 1 }
                ]
            }

        VaultCityRandal ->
            { caps = Debug.todo "randal caps"
            , stock = Debug.todo "randal stock"
            }

        VaultCityHappyHarry ->
            { caps = { average = 300, maxDeviation = 120 }
            , stock =
                [ { uniqueKey = { kind = ItemKind.Stimpak }, maxCount = 4 }
                , { uniqueKey = { kind = ItemKind.ScoutHandbook }, maxCount = 2 }
                , { uniqueKey = { kind = ItemKind.MetalArmor }, maxCount = 1 }
                , { uniqueKey = { kind = ItemKind.Ap10mm }, maxCount = 50 }
                , { uniqueKey = { kind = ItemKind.Jhp10mm }, maxCount = 50 }
                ]
            }

        GeckoSurvivalGearPercy ->
            { caps = Debug.todo "gecko caps"
            , stock = Debug.todo "gecko stock"
            }

        ReddingAscorti ->
            { caps = Debug.todo "redding caps"
            , stock = Debug.todo "redding stock"
            }

        BrokenHillsGeneralStoreLiz ->
            { caps = Debug.todo "brokenhills liz caps"
            , stock = Debug.todo "brokenhills liz stock"
            }

        BrokenHillsChemistJacob ->
            { caps = Debug.todo "brokenhills jacob caps"
            , stock = Debug.todo "brokenhills jacob stock"
            }

        NewRenoArmsEldridge ->
            { caps = Debug.todo "new reno arms caps"
            , stock = Debug.todo "new reno arms stock"
            }

        NewRenoRenescoPharmacy ->
            { caps = Debug.todo "new reno renesco caps"
            , stock = Debug.todo "new reno renesco stock"
            }

        NCRBuster ->
            { caps = Debug.todo "ncr buster caps"
            , stock = Debug.todo "ncr buster stock"
            }

        NCRDuppo ->
            { caps = Debug.todo "ncr duppo caps"
            , stock = Debug.todo "ncr duppo stock"
            }

        SanFranciscoFlyingDragon8LaoChou ->
            { caps = Debug.todo "san francisco lao chou caps"
            , stock = Debug.todo "san francisco lao chou stock"
            }

        SanFranciscoRed888GunsMaiDaChiang ->
            { caps = Debug.todo "san francisco mai da chiang caps"
            , stock = Debug.todo "san francisco mai da chiang stock"
            }

        SanFranciscoPunksCal ->
            { caps = Debug.todo "san francisco cal caps"
            , stock = Debug.todo "san francisco cal stock"
            }

        SanFranciscoPunksJenna ->
            { caps = Debug.todo "san francisco jenna caps"
            , stock = Debug.todo "san francisco jenna stock"
            }


encode : Shop -> JE.Value
encode shop =
    case shop of
        ArroyoHakunin ->
            JE.string "ArroyoHakunin"

        KlamathMaida ->
            JE.string "KlamathMaida"

        KlamathVic ->
            JE.string "KlamathVic"

        DenFlick ->
            JE.string "DenFlick"

        ModocJo ->
            JE.string "ModocJo"

        VaultCityRandal ->
            JE.string "VaultCityRandal"

        VaultCityHappyHarry ->
            JE.string "VaultCityHappyHarry"

        GeckoSurvivalGearPercy ->
            JE.string "GeckoSurvivalGearPercy"

        ReddingAscorti ->
            JE.string "ReddingAscorti"

        BrokenHillsGeneralStoreLiz ->
            JE.string "BrokenHillsGeneralStoreLiz"

        BrokenHillsChemistJacob ->
            JE.string "BrokenHillsChemistJacob"

        NewRenoArmsEldridge ->
            JE.string "NewRenoArmsEldridge"

        NewRenoRenescoPharmacy ->
            JE.string "NewRenoRenescoPharmacy"

        NCRBuster ->
            JE.string "NCRBuster"

        NCRDuppo ->
            JE.string "NCRDuppo"

        SanFranciscoFlyingDragon8LaoChou ->
            JE.string "SanFranciscoFlyingDragon8LaoChou"

        SanFranciscoRed888GunsMaiDaChiang ->
            JE.string "SanFranciscoRed888GunsMaiDaChiang"

        SanFranciscoPunksCal ->
            JE.string "SanFranciscoPunksCal"

        SanFranciscoPunksJenna ->
            JE.string "SanFranciscoPunksJenna"


decoder : Decoder Shop
decoder =
    JD.field "tag" JD.string
        |> JD.andThen
            (\ctor ->
                case ctor of
                    "ArroyoHakunin" ->
                        JD.succeed ArroyoHakunin

                    "KlamathMaida" ->
                        JD.succeed KlamathMaida

                    "KlamathVic" ->
                        JD.succeed KlamathVic

                    "DenFlick" ->
                        JD.succeed DenFlick

                    "ModocJo" ->
                        JD.succeed ModocJo

                    "VaultCityRandal" ->
                        JD.succeed VaultCityRandal

                    "VaultCityHappyHarry" ->
                        JD.succeed VaultCityHappyHarry

                    "GeckoSurvivalGearPercy" ->
                        JD.succeed GeckoSurvivalGearPercy

                    "ReddingAscorti" ->
                        JD.succeed ReddingAscorti

                    "BrokenHillsGeneralStoreLiz" ->
                        JD.succeed BrokenHillsGeneralStoreLiz

                    "BrokenHillsChemistJacob" ->
                        JD.succeed BrokenHillsChemistJacob

                    "NewRenoArmsEldridge" ->
                        JD.succeed NewRenoArmsEldridge

                    "NewRenoRenescoPharmacy" ->
                        JD.succeed NewRenoRenescoPharmacy

                    "NCRBuster" ->
                        JD.succeed NCRBuster

                    "NCRDuppo" ->
                        JD.succeed NCRDuppo

                    "SanFranciscoFlyingDragon8LaoChou" ->
                        JD.succeed SanFranciscoFlyingDragon8LaoChou

                    "SanFranciscoRed888GunsMaiDaChiang" ->
                        JD.succeed SanFranciscoRed888GunsMaiDaChiang

                    "SanFranciscoPunksCal" ->
                        JD.succeed SanFranciscoPunksCal

                    "SanFranciscoPunksJenna" ->
                        JD.succeed SanFranciscoPunksJenna

                    _ ->
                        JD.fail "Unrecognized constructor"
            )


encodeSpec : ShopSpec -> JE.Value
encodeSpec spec_ =
    let
        encodeItem : { uniqueKey : Item.UniqueKey, maxCount : Int } -> JE.Value
        encodeItem item =
            JE.object
                [ ( "uniqueKey", Item.encodeUniqueKey item.uniqueKey )
                , ( "maxCount", JE.int item.maxCount )
                ]
    in
    JE.object
        [ ( "capsAverage", JE.int spec_.caps.average )
        , ( "capsMaxDeviation", JE.int spec_.caps.maxDeviation )
        , ( "stock", JE.list encodeItem spec_.stock )
        ]


specDecoder : Decoder ShopSpec
specDecoder =
    JD.map2
        (\caps stock ->
            { caps = caps
            , stock = stock
            }
        )
        (JD.map2 Random.NormalIntSpec
            (JD.field "capsAverage" JD.int)
            (JD.field "capsMaxDeviation" JD.int)
        )
        (JD.field "stock"
            (JD.list
                (JD.map2
                    (\uniqueKey maxCount ->
                        { uniqueKey = uniqueKey
                        , maxCount = maxCount
                        }
                    )
                    (JD.field "uniqueKey" Item.uniqueKeyDecoder)
                    (JD.field "maxCount" JD.int)
                )
            )
        )


locationsWithShops : SeqDict Location (List Shop)
locationsWithShops =
    all
        |> List.map (\shop -> ( shop, location shop ))
        |> List.foldl
            (\( shop, location_ ) acc ->
                acc
                    |> SeqDict.update location_ (Maybe.withDefault [] >> (::) shop >> Just)
            )
            SeqDict.empty


forLocation : Location -> List Shop
forLocation loc =
    SeqDict.get loc locationsWithShops
        |> Maybe.withDefault []


isInLocation : Location -> Shop -> Bool
isInLocation loc shop =
    forLocation loc
        |> List.member shop
