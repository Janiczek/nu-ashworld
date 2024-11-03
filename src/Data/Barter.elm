module Data.Barter exposing
    ( ArrowsDirection(..)
    , Message(..)
    , State
    , TransferNPosition(..)
    , addPlayerCaps
    , addPlayerItem
    , addVendorCaps
    , addVendorItem
    , arrowsDirection
    , codec
    , defaultTransferN
    , dismissMessage
    , doubleArrow
    , empty
    , messageText
    , removePlayerCaps
    , removePlayerItem
    , removeVendorCaps
    , removeVendorItem
    , setMessage
    , setTransferNActive
    , setTransferNInput
    , singleArrow
    , unsetTransferNActive
    )

import Codec exposing (Codec)
import Data.Item as Item
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict


type Message
    = BarterIsEmpty
    | PlayerOfferNotValuableEnough
    | YouGaveStuffForFree


type TransferNPosition
    = PlayerKeptItem Item.Id
    | VendorKeptItem Item.Id
    | PlayerTradedItem Item.Id
    | VendorTradedItem Item.Id
    | PlayerKeptCaps
    | VendorKeptCaps
    | PlayerTradedCaps
    | VendorTradedCaps


type alias State =
    { playerItems : Dict Item.Id Int
    , vendorItems : Dict Item.Id Int
    , playerCaps : Int
    , vendorCaps : Int
    , lastMessage : Maybe Message
    , transferNInputs : SeqDict TransferNPosition String
    , activeN : Maybe TransferNPosition
    }


empty : State
empty =
    { playerItems = Dict.empty
    , vendorItems = Dict.empty
    , playerCaps = 0
    , vendorCaps = 0
    , lastMessage = Nothing
    , transferNInputs = SeqDict.empty
    , activeN = Nothing
    }


addVendorItem : Item.Id -> Int -> State -> State
addVendorItem id count state =
    { state
        | vendorItems =
            state.vendorItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
        , activeN = Nothing
    }


addPlayerItem : Item.Id -> Int -> State -> State
addPlayerItem id count state =
    { state
        | playerItems =
            state.playerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
        , activeN = Nothing
    }


removePlayerItem : Item.Id -> Int -> State -> State
removePlayerItem id count state =
    { state
        | playerItems =
            state.playerItems
                |> Dict.update id
                    (Maybe.andThen
                        (\existingCount ->
                            let
                                newCount =
                                    existingCount - count
                            in
                            if newCount <= 0 then
                                Nothing

                            else
                                Just newCount
                        )
                    )
        , activeN = Nothing
    }


removeVendorItem : Item.Id -> Int -> State -> State
removeVendorItem id count state =
    { state
        | vendorItems =
            state.vendorItems
                |> Dict.update id
                    (Maybe.andThen
                        (\existingCount ->
                            let
                                newCount =
                                    existingCount - count
                            in
                            if newCount <= 0 then
                                Nothing

                            else
                                Just newCount
                        )
                    )
        , activeN = Nothing
    }


addPlayerCaps : Int -> State -> State
addPlayerCaps amount state =
    { state
        | playerCaps = state.playerCaps + amount
        , activeN = Nothing
    }


removePlayerCaps : Int -> State -> State
removePlayerCaps amount state =
    { state
        | playerCaps = state.playerCaps - amount
        , activeN = Nothing
    }


addVendorCaps : Int -> State -> State
addVendorCaps amount state =
    { state
        | vendorCaps = state.vendorCaps + amount
        , activeN = Nothing
    }


removeVendorCaps : Int -> State -> State
removeVendorCaps amount state =
    { state
        | vendorCaps = state.vendorCaps - amount
        , activeN = Nothing
    }


setMessage : Message -> State -> State
setMessage message state =
    { state | lastMessage = Just message }


dismissMessage : State -> State
dismissMessage state =
    { state | lastMessage = Nothing }


messageText : Message -> String
messageText message =
    case message of
        BarterIsEmpty ->
            "You didn't yet say what you want to trade."

        PlayerOfferNotValuableEnough ->
            "You didn't offer enough value for what you request."

        YouGaveStuffForFree ->
            "You gave stuff away for free. Just sayin'."


defaultTransferN : String
defaultTransferN =
    "10"


type ArrowsDirection
    = ArrowLeft
    | ArrowRight


arrowsDirection : TransferNPosition -> ArrowsDirection
arrowsDirection position =
    case position of
        PlayerKeptItem _ ->
            ArrowRight

        VendorKeptItem _ ->
            ArrowLeft

        PlayerTradedItem _ ->
            ArrowLeft

        VendorTradedItem _ ->
            ArrowRight

        PlayerKeptCaps ->
            ArrowRight

        VendorKeptCaps ->
            ArrowLeft

        PlayerTradedCaps ->
            ArrowLeft

        VendorTradedCaps ->
            ArrowRight


singleArrow : ArrowsDirection -> String
singleArrow direction =
    case direction of
        ArrowLeft ->
            "‹"

        ArrowRight ->
            "›"


doubleArrow : ArrowsDirection -> String
doubleArrow direction =
    case direction of
        ArrowLeft ->
            "«"

        ArrowRight ->
            "»"


setTransferNInput : TransferNPosition -> String -> State -> State
setTransferNInput position string state =
    { state | transferNInputs = SeqDict.insert position string state.transferNInputs }


setTransferNActive : TransferNPosition -> State -> State
setTransferNActive position state =
    { state | activeN = Just position }


unsetTransferNActive : State -> State
unsetTransferNActive state =
    { state | activeN = Nothing }


codec : Codec State
codec =
    Codec.object State
        |> Codec.field "playerItems" .playerItems (Dict.codec Codec.int Codec.int)
        |> Codec.field "vendorItems" .vendorItems (Dict.codec Codec.int Codec.int)
        |> Codec.field "playerCaps" .playerCaps Codec.int
        |> Codec.field "vendorCaps" .vendorCaps Codec.int
        |> Codec.field "lastMessage" .lastMessage (Codec.nullable messageCodec)
        |> Codec.field "transferNInputs" .transferNInputs (SeqDict.codec transferNPositionCodec Codec.string)
        |> Codec.field "activeN" .activeN (Codec.nullable transferNPositionCodec)
        |> Codec.buildObject


messageCodec : Codec Message
messageCodec =
    Codec.custom
        (\barterIsEmptyEncoder playerOfferNotValuableEnoughEncoder youGaveStuffForFreeEncoder value ->
            case value of
                BarterIsEmpty ->
                    barterIsEmptyEncoder

                PlayerOfferNotValuableEnough ->
                    playerOfferNotValuableEnoughEncoder

                YouGaveStuffForFree ->
                    youGaveStuffForFreeEncoder
        )
        |> Codec.variant0 "BarterIsEmpty" BarterIsEmpty
        |> Codec.variant0 "PlayerOfferNotValuableEnough" PlayerOfferNotValuableEnough
        |> Codec.variant0 "YouGaveStuffForFree" YouGaveStuffForFree
        |> Codec.buildCustom


transferNPositionCodec : Codec TransferNPosition
transferNPositionCodec =
    Codec.custom
        (\playerKeptItemEncoder vendorKeptItemEncoder playerTradedItemEncoder vendorTradedItemEncoder playerKeptCapsEncoder vendorKeptCapsEncoder playerTradedCapsEncoder vendorTradedCapsEncoder value ->
            case value of
                PlayerKeptItem arg0 ->
                    playerKeptItemEncoder arg0

                VendorKeptItem arg0 ->
                    vendorKeptItemEncoder arg0

                PlayerTradedItem arg0 ->
                    playerTradedItemEncoder arg0

                VendorTradedItem arg0 ->
                    vendorTradedItemEncoder arg0

                PlayerKeptCaps ->
                    playerKeptCapsEncoder

                VendorKeptCaps ->
                    vendorKeptCapsEncoder

                PlayerTradedCaps ->
                    playerTradedCapsEncoder

                VendorTradedCaps ->
                    vendorTradedCapsEncoder
        )
        |> Codec.variant1 "PlayerKeptItem" PlayerKeptItem Codec.int
        |> Codec.variant1 "VendorKeptItem" VendorKeptItem Codec.int
        |> Codec.variant1 "PlayerTradedItem" PlayerTradedItem Codec.int
        |> Codec.variant1 "VendorTradedItem" VendorTradedItem Codec.int
        |> Codec.variant0 "PlayerKeptCaps" PlayerKeptCaps
        |> Codec.variant0 "VendorKeptCaps" VendorKeptCaps
        |> Codec.variant0 "PlayerTradedCaps" PlayerTradedCaps
        |> Codec.variant0 "VendorTradedCaps" VendorTradedCaps
        |> Codec.buildCustom
