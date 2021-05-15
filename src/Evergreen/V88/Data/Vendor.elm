module Evergreen.V88.Data.Vendor exposing (..)

import Dict
import Evergreen.V88.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V88.Data.Item.Id Evergreen.V88.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
