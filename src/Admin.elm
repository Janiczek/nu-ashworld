module Admin exposing (backendModelDecoder, encodeBackendModel)

import AssocList as Dict_
import Data.Player as Player
import Data.Vendor as Vendor
import Data.World as World
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
        [ ( "worlds", Dict.encode JE.string World.encode model.worlds ) ]


backendModelDecoder : Decoder BackendModel
backendModelDecoder =
    JD.map
        (\worlds ->
            { worlds = worlds
            , loggedInPlayers = Dict.empty
            , time = Time.millisToPosix 0
            , adminLoggedIn = Nothing
            }
        )
        (JD.field "worlds" (Dict.decoder JD.string World.decoder))
