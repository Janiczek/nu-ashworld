module Evergreen.V87.Data.Vendor exposing (..)

import Dict
import Evergreen.V87.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V87.Data.Item.Id Evergreen.V87.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
