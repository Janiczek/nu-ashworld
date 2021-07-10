module Evergreen.V100.Data.Vendor exposing (..)

import Dict
import Evergreen.V100.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V100.Data.Item.Id Evergreen.V100.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
