module Evergreen.V104.Data.Vendor exposing (..)

import Dict
import Evergreen.V104.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V104.Data.Item.Id Evergreen.V104.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
