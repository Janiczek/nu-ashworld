module Evergreen.V102.Data.Vendor exposing (..)

import Dict
import Evergreen.V102.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V102.Data.Item.Id Evergreen.V102.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
