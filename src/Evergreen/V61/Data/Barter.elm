module Evergreen.V61.Data.Barter exposing (..)

import Dict
import Evergreen.V61.Data.Item


type Problem
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough


type alias State =
    { playerItems : Dict.Dict Evergreen.V61.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V61.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastProblem : Maybe Problem
    }
