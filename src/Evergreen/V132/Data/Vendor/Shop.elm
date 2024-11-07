module Evergreen.V132.Data.Vendor.Shop exposing (..)

import Evergreen.V132.Data.Item
import Evergreen.V132.Random.FloatExtra
import SeqDict


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
    { caps : Evergreen.V132.Random.FloatExtra.NormalIntSpec
    , stock :
        SeqDict.SeqDict
            Evergreen.V132.Data.Item.UniqueKey
            { maxCount : Int
            }
    }
