module Evergreen.V85.Data.Vendor exposing (..)

import Dict
import Evergreen.V85.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V85.Data.Item.Id Evergreen.V85.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
