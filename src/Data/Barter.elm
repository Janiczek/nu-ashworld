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
    , defaultTransferN
    , dismissMessage
    , doubleArrow
    , empty
    , encode
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

import Data.Item as Item
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Encode as JE
import Json.Encode.Extra as JE
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


encode : State -> JE.Value
encode state =
    JE.object
        [ ( "playerItems", Dict.encode JE.int JE.int state.playerItems )
        , ( "vendorItems", Dict.encode JE.int JE.int state.vendorItems )
        , ( "playerCaps", JE.int state.playerCaps )
        , ( "vendorCaps", JE.int state.vendorCaps )
        , ( "lastMessage", JE.maybe encodeMessage state.lastMessage )
        , ( "transferNInputs", SeqDict.encode encodeTransferNPosition JE.string state.transferNInputs )
        , ( "transferNActive", JE.maybe encodeTransferNPosition state.activeN )
        ]


encodeTransferNPosition : TransferNPosition -> JE.Value
encodeTransferNPosition position =
    case position of
        PlayerKeptItem itemId ->
            JE.object
                [ ( "type", JE.string "PlayerKeptItem" )
                , ( "itemId", JE.int itemId )
                ]

        VendorKeptItem itemId ->
            JE.object
                [ ( "type", JE.string "VendorKeptItem" )
                , ( "itemId", JE.int itemId )
                ]

        PlayerTradedItem itemId ->
            JE.object
                [ ( "type", JE.string "PlayerTradedItem" )
                , ( "itemId", JE.int itemId )
                ]

        VendorTradedItem itemId ->
            JE.object
                [ ( "type", JE.string "VendorTradedItem" )
                , ( "itemId", JE.int itemId )
                ]

        PlayerKeptCaps ->
            JE.object
                [ ( "type", JE.string "PlayerKeptCaps" ) ]

        VendorKeptCaps ->
            JE.object
                [ ( "type", JE.string "VendorKeptCaps" ) ]

        PlayerTradedCaps ->
            JE.object
                [ ( "type", JE.string "PlayerTradedCaps" ) ]

        VendorTradedCaps ->
            JE.object
                [ ( "type", JE.string "VendorTradedCaps" ) ]


encodeMessage : Message -> JE.Value
encodeMessage message =
    case message of
        BarterIsEmpty ->
            JE.string "BarterIsEmpty"

        PlayerOfferNotValuableEnough ->
            JE.string "PlayerOfferNotValuableEnough"

        YouGaveStuffForFree ->
            JE.string "YouGaveStuffForFree"
