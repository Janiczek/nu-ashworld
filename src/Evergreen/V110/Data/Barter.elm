module Evergreen.V110.Data.Barter exposing (..)

import Dict
import Evergreen.V110.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V110.Data.Item.Id
    | VendorKeptItem Evergreen.V110.Data.Item.Id
    | PlayerTradedItem Evergreen.V110.Data.Item.Id
    | VendorTradedItem Evergreen.V110.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V110.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V110.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
