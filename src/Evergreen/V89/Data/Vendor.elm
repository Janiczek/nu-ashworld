module Evergreen.V89.Data.Vendor exposing (..)

import Dict
import Evergreen.V89.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V89.Data.Item.Id Evergreen.V89.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
