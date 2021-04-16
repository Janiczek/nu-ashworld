module Evergreen.V63.Data.Barter exposing (..)

import AssocList
import Dict
import Evergreen.V63.Data.Item


type Problem
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough


type TransferNPosition
    = PlayerKeptItem Evergreen.V63.Data.Item.Id
    | VendorKeptItem Evergreen.V63.Data.Item.Id
    | PlayerTradedItem Evergreen.V63.Data.Item.Id
    | VendorTradedItem Evergreen.V63.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V63.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V63.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastProblem : Maybe Problem
    , transferNInputs : AssocList.Dict TransferNPosition String
    , transferNHover : Maybe TransferNPosition
    }
