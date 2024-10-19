module Evergreen.V101.Data.Vendor exposing (..)

import Dict
import Evergreen.V101.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V101.Data.Item.Id Evergreen.V101.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
