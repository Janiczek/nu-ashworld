module Evergreen.V129.Data.Barter exposing (..)

import Dict
import Evergreen.V129.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V129.Data.Item.Id
    | VendorKeptItem Evergreen.V129.Data.Item.Id
    | PlayerTradedItem Evergreen.V129.Data.Item.Id
    | VendorTradedItem Evergreen.V129.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V129.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V129.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
