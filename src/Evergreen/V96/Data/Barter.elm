module Evergreen.V96.Data.Barter exposing (..)

import AssocList
import Dict
import Evergreen.V96.Data.Item


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V96.Data.Item.Id
    | VendorKeptItem Evergreen.V96.Data.Item.Id
    | PlayerTradedItem Evergreen.V96.Data.Item.Id
    | VendorTradedItem Evergreen.V96.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V96.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V96.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : AssocList.Dict TransferNPosition String
    , transferNHover : Maybe TransferNPosition
    }
