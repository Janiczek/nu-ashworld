module Fusion.Queue exposing (build_Queue, patch_Queue, patcher_Queue, toValue_Queue)

{-| -}

import Fusion exposing (Value(..))
import Fusion.Patch as Patch exposing (Error(..), Patch(..), Patcher)
import Fusion.ValueDict as ValueDict exposing (ValueDict)
import Queue exposing (Queue)


{-| -}
patcher_Queue : Patcher item -> Patcher (Queue item)
patcher_Queue valuePatcher =
    Patch.patcher_List valuePatcher
        |> Patch.map Queue.fromList Queue.toList


build_Queue : Patcher item -> Value -> Result Error (Queue item)
build_Queue valuePatcher =
    (patcher_Queue valuePatcher).build


patch_Queue : Patcher item -> { force : Bool } -> Patch -> Queue item -> Result Error (Queue item)
patch_Queue valuePatcher =
    (patcher_Queue valuePatcher).patch


toValue_Queue : Patcher item -> Queue item -> Value
toValue_Queue valuePatcher =
    (patcher_Queue valuePatcher).toValue
