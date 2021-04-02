module Admin exposing (backendModelDecoder, encodeBackendModel)

import Data.Player as Player
import Dict
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Json.Encode.Extra as JEE
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
        ]


backendModelDecoder : Decoder BackendModel
backendModelDecoder =
    JD.map2
        (\players nextWantedTick ->
            { players = players
            , loggedInPlayers = Dict.empty
            , nextWantedTick = nextWantedTick
            , adminLoggedIn = Nothing
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
