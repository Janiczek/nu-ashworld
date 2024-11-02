module Evergreen.V120.Data.Barter exposing (..)

import Dict
import Evergreen.V120.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V120.Data.Item.Id
    | VendorKeptItem Evergreen.V120.Data.Item.Id
    | PlayerTradedItem Evergreen.V120.Data.Item.Id
    | VendorTradedItem Evergreen.V120.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V120.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V120.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
