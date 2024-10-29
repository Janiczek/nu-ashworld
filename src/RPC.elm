module RPC exposing (..)

import Env
import Http
import LamderaRPC exposing (RPC(..))
import Types exposing (..)



-- Apps with no RPC.elm get this file, which responds to no endpoints


lamdera_handleEndpoints : LamderaRPC.RPCArgs -> BackendModel -> ( LamderaRPC.RPCResult, BackendModel, Cmd msg )
lamdera_handleEndpoints args model =
    ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )
