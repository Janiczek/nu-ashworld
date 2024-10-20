module Evergreen.V109.Data.Barter exposing (..)

import Dict
import Evergreen.V109.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V109.Data.Item.Id
    | VendorKeptItem Evergreen.V109.Data.Item.Id
    | PlayerTradedItem Evergreen.V109.Data.Item.Id
    | VendorTradedItem Evergreen.V109.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V109.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V109.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
