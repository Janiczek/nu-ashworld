module Admin exposing (backendModelDecoder, encodeBackendModel)

import Data.Player as Player
import Data.Vendor as Vendor
import Dict
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Json.Encode.Extra as JEE
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
        [ backendModelDecoderV2
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
                        |> List.concatMap (.items >> Dict.keys)
                        |> List.maximum
                        |> Maybe.withDefault 0

                lastVendorsItemId : Int
                lastVendorsItemId =
                    vendors
                        |> Vendor.listVendors
                        |> List.concatMap (.items >> Dict.keys)
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
