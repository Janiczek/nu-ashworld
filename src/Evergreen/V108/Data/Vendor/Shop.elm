module Evergreen.V108.Data.Vendor.Shop exposing (..)

import Evergreen.V108.Data.Item
import Evergreen.V108.Random.FloatExtra


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
    { caps : Evergreen.V108.Random.FloatExtra.NormalIntSpec
    , stock :
        List
            { uniqueKey : Evergreen.V108.Data.Item.UniqueKey
            , maxCount : Int
            }
    }
