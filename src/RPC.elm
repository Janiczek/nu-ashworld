module RPC exposing (..)

import Http
import Json.Encode as Json
import Lamdera exposing (SessionId)
import LamderaRPC exposing (..)
import Types exposing (BackendModel)


lamdera_handleEndpoints : Json.Value -> HttpRequest -> BackendModel -> ( LamderaRPC.RPCResult, BackendModel, Cmd msg )
lamdera_handleEndpoints reqRaw req model =
    ( ResultRaw 404 "" [] <| BodyBytes [], model, Cmd.none )
