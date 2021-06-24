module Admin exposing (backendModelDecoder, encodeBackendModel)

import AssocList as Dict_
import AssocList.ExtraExtra as Dict_
import Data.Player as Player
import Data.Quest as Quest
import Data.Vendor as Vendor
import Dict
import Dict.ExtraExtra as Dict
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.ExtraExtra as List
import Time
import Types exposing (BackendModel)


encodeBackendModel : BackendModel -> JE.Value
encodeBackendModel model =
    JE.object
        [ ( "players"
          , model.players
                |> Dict.values
                |> JE.list (Player.encode Player.encodeSPlayer)
          )
        , ( "nextWantedTick", JEE.maybe Iso8601.encode model.nextWantedTick )
        , ( "vendors", Vendor.encodeVendors model.vendors )
        ]


backendModelDecoder : Decoder BackendModel
backendModelDecoder =
    JD.oneOf
        [ backendModelDecoderV3
        , backendModelDecoderV2
        , backendModelDecoderV1
        ]


{-| init version
-}
backendModelDecoderV1 : Decoder BackendModel
backendModelDecoderV1 =
    JD.map2
        (\players nextWantedTick ->
            { players = players
            , loggedInPlayers = Dict.empty
            , nextWantedTick = nextWantedTick
            , adminLoggedIn = Nothing
            , time = Time.millisToPosix 0
            , vendors = Vendor.emptyVendors
            , lastItemId = 0
            , questsProgress =
                Quest.all
                    |> List.map (\q -> ( q, Dict.empty ))
                    |> Dict_.fromList
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))


{-| adds "vendors" field
-}
backendModelDecoderV2 : Decoder BackendModel
backendModelDecoderV2 =
    JD.map3
        (\players nextWantedTick vendors ->
            let
                lastPlayersItemId : Int
                lastPlayersItemId =
                    players
                        |> Dict.values
                        |> List.filterMap Player.getPlayerData
                        |> List.fastConcatMap (.items >> Dict.keys)
                        |> List.maximum
                        |> Maybe.withDefault 0

                lastVendorsItemId : Int
                lastVendorsItemId =
                    vendors
                        |> Dict_.values
                        |> List.fastConcatMap (.items >> Dict.keys)
                        |> List.maximum
                        |> Maybe.withDefault 0

                lastItemId : Int
                lastItemId =
                    max lastPlayersItemId lastVendorsItemId
            in
            { players = players
            , loggedInPlayers = Dict.empty
            , nextWantedTick = nextWantedTick
            , adminLoggedIn = Nothing
            , time = Time.millisToPosix 0
            , vendors = vendors
            , lastItemId = lastItemId
            , questsProgress =
                Quest.all
                    |> List.map (\q -> ( q, Dict.empty ))
                    |> Dict_.fromList
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))
        (JD.field "vendors" Vendor.vendorsDecoder)


{-| adds "questsProgress" field
-}
backendModelDecoderV3 : Decoder BackendModel
backendModelDecoderV3 =
    JD.map4
        (\players nextWantedTick vendors quests ->
            let
                lastPlayersItemId : Int
                lastPlayersItemId =
                    players
                        |> Dict.values
                        |> List.filterMap Player.getPlayerData
                        |> List.fastConcatMap (.items >> Dict.keys)
                        |> List.maximum
                        |> Maybe.withDefault 0

                lastVendorsItemId : Int
                lastVendorsItemId =
                    vendors
                        |> Dict_.values
                        |> List.fastConcatMap (.items >> Dict.keys)
                        |> List.maximum
                        |> Maybe.withDefault 0

                lastItemId : Int
                lastItemId =
                    max lastPlayersItemId lastVendorsItemId
            in
            { players = players
            , loggedInPlayers = Dict.empty
            , nextWantedTick = nextWantedTick
            , adminLoggedIn = Nothing
            , time = Time.millisToPosix 0
            , vendors = vendors
            , lastItemId = lastItemId
            , questsProgress = quests
            }
        )
        (JD.field "players"
            (JD.list
                (Player.decoder Player.sPlayerDecoder
                    |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                )
                |> JD.map Dict.fromList
            )
        )
        (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))
        (JD.field "vendors" Vendor.vendorsDecoder)
        (JD.field "questsProgress" (Dict_.decoder Quest.decoder (Dict.decoder JD.string JD.int)))
