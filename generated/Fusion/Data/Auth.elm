module Fusion.Data.Auth exposing (patcher_Hashed, patcher_Verified, phantomPatcher)

import Data.Auth exposing (Hashed, Verified(..))
import Fusion exposing (Value(..))
import Fusion.Patch exposing (Patcher)


patcher_Verified : Patcher Verified
patcher_Verified =
    phantomPatcher


patcher_Hashed : Patcher Hashed
patcher_Hashed =
    phantomPatcher


phantomPatcher : Patcher a
phantomPatcher =
    { patch = \_ _ a -> Ok a
    , build = \_ -> Err Fusion.Patch.CouldNotBuildValueFromPatch
    , toValue = \_ -> VUnloaded
    }
