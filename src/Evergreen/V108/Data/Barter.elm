module Evergreen.V108.Data.Barter exposing (..)

import Dict
import Evergreen.V108.Data.Item
import SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Evergreen.V108.Data.Item.Id
    | VendorKeptItem Evergreen.V108.Data.Item.Id
    | PlayerTradedItem Evergreen.V108.Data.Item.Id
    | VendorTradedItem Evergreen.V108.Data.Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict.Dict Evergreen.V108.Data.Item.Id Int
    , vendorItems : Dict.Dict Evergreen.V108.Data.Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict.SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }
