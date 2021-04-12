module Data.Barter exposing (State, empty)

import AssocList as Dict_
import Data.Item as Item
import Dict exposing (Dict)


type alias State =
    { playerItems : Dict Item.Id Int
    , playerCaps : Int
    , vendorPlayerItems : Dict Item.Id Int
    , vendorStockItems : Dict_.Dict Item.Kind Int
    , vendorCaps : Int
    }


empty : State
empty =
    { playerItems = Dict.empty
    , playerCaps = 0
    , vendorPlayerItems = Dict.empty
    , vendorStockItems = Dict_.empty
    , vendorCaps = 0
    }
