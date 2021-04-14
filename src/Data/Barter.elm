module Data.Barter exposing
    ( State
    , addPlayerCaps
    , addPlayerItem
    , addVendorCaps
    , addVendorPlayerItem
    , addVendorStockItem
    , empty
    , removePlayerCaps
    , removePlayerItem
    , removeVendorCaps
    , removeVendorPlayerItem
    , removeVendorStockItem
    )

import AssocList as Dict_
import Data.Item as Item
import Dict exposing (Dict)


type alias State =
    { playerItems : Dict Item.Id Int
    , playerCaps : Int
    , vendorPlayerItems : Dict Item.Id Int
    , vendorStockItems : Dict_.Dict Item.Kind Int
    , vendorCaps : Int
    }


empty : State
empty =
    { playerItems = Dict.empty
    , playerCaps = 0
    , vendorPlayerItems = Dict.empty
    , vendorStockItems = Dict_.empty
    , vendorCaps = 0
    }


addVendorStockItem : Item.Kind -> Int -> State -> State
addVendorStockItem kind count state =
    { state
        | vendorStockItems =
            state.vendorStockItems
                |> Dict_.update kind
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
    }


removeVendorStockItem : Item.Kind -> Int -> State -> State
removeVendorStockItem kind count state =
    { state
        | vendorStockItems =
            state.vendorStockItems
                |> Dict_.update kind
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Nothing

                            Just existingCount ->
                                let
                                    newCount =
                                        existingCount - count
                                in
                                if newCount <= 0 then
                                    Nothing

                                else
                                    Just newCount
                    )
    }


addVendorPlayerItem : Item.Id -> Int -> State -> State
addVendorPlayerItem id count state =
    { state
        | vendorPlayerItems =
            state.vendorPlayerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Just count

                            Just existingCount ->
                                Just <| existingCount + count
                    )
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
    }


removePlayerItem : Item.Id -> Int -> State -> State
removePlayerItem id count state =
    { state
        | playerItems =
            state.playerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Nothing

                            Just existingCount ->
                                let
                                    newCount =
                                        existingCount - count
                                in
                                if newCount <= 0 then
                                    Nothing

                                else
                                    Just newCount
                    )
    }


removeVendorPlayerItem : Item.Id -> Int -> State -> State
removeVendorPlayerItem id count state =
    { state
        | vendorPlayerItems =
            state.vendorPlayerItems
                |> Dict.update id
                    (\maybeExistingCount ->
                        case maybeExistingCount of
                            Nothing ->
                                Nothing

                            Just existingCount ->
                                let
                                    newCount =
                                        existingCount - count
                                in
                                if newCount <= 0 then
                                    Nothing

                                else
                                    Just newCount
                    )
    }


addPlayerCaps : Int -> State -> State
addPlayerCaps amount state =
    { state | playerCaps = state.playerCaps + amount }


removePlayerCaps : Int -> State -> State
removePlayerCaps amount state =
    { state | playerCaps = state.playerCaps - amount }


addVendorCaps : Int -> State -> State
addVendorCaps amount state =
    { state | vendorCaps = state.vendorCaps + amount }


removeVendorCaps : Int -> State -> State
removeVendorCaps amount state =
    { state | vendorCaps = state.vendorCaps - amount }
