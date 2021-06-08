module Evergreen.V97.Data.Vendor exposing (..)

import Dict
import Evergreen.V97.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V97.Data.Item.Id Evergreen.V97.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
