module Evergreen.V133.Data.Barter exposing (..)

import Dict
import Evergreen.V133.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V133.Data.Item.Id
    | VendorKeptItem Evergreen.V133.Data.Item.Id
    | PlayerTradedItem Evergreen.V133.Data.Item.Id
    | VendorTradedItem Evergreen.V133.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V133.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V133.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
