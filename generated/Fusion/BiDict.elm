module Fusion.BiDict exposing (build_BiDict, patch_BiDict, patcher_BiDict, toValue_BiDict)

{-| -}

import BiDict exposing (BiDict)
import Fusion exposing (Value(..))
import Fusion.Patch exposing (Error(..), Patch(..), Patcher)
import Fusion.ValueDict as ValueDict exposing (ValueDict)


{-| -}
patcher_BiDict : Patcher comparable1 -> Patcher comparable2 -> Patcher (BiDict comparable1 comparable2)
patcher_BiDict keyPatcher valuePatcher =
    { patch = patch_BiDict keyPatcher valuePatcher
    , build = build_BiDict keyPatcher valuePatcher
    , toValue = toValue_BiDict keyPatcher valuePatcher
    }


{-| -}
patch_BiDict :
    Patcher comparable1
    -> Patcher comparable2
    -> { force : Bool }
    -> Patch
    -> BiDict comparable1 comparable2
    -> Result Error (BiDict comparable1 comparable2)
patch_BiDict keyPatcher valuePatcher options p value =
    -- TODO: Check when removing that we're removing the expected value
    -- or that force is True
    case p of
        PDict dpatch ->
            let
                foldOn :
                    ValueDict b
                    -> (Value -> b -> c -> Result Error c)
                    -> Result Error c
                    -> Result Error c
                foldOn prop f init =
                    case init of
                        Err e ->
                            Err e

                        Ok _ ->
                            ValueDict.foldl
                                (\key item acc ->
                                    case acc of
                                        Err e ->
                                            Err e

                                        Ok oacc ->
                                            Result.mapError (ErrorAtValueWithKey key) (f key item oacc)
                                )
                                init
                                prop
            in
            Ok value
                |> foldOn dpatch.removed
                    (\removedKey _ acc ->
                        Result.map
                            (\key -> BiDict.remove key acc)
                            (keyPatcher.build removedKey)
                    )
                |> foldOn dpatch.added
                    (\addedKey addedValue acc ->
                        Result.map2 (\k v -> BiDict.insert k v acc)
                            (keyPatcher.build addedKey)
                            (valuePatcher.build addedValue)
                    )
                |> foldOn dpatch.edited
                    (\changedKey valuePatch acc ->
                        keyPatcher.build changedKey
                            |> Result.andThen
                                (\key ->
                                    case BiDict.get key acc of
                                        Nothing ->
                                            -- The value was removed by someone else
                                            Err Conflict

                                        Just item ->
                                            valuePatcher.patch options valuePatch item
                                                |> Result.map (\patched -> BiDict.insert key patched acc)
                                )
                    )

        _ ->
            Err (WrongType "Patch.")


{-| -}
build_BiDict :
    Patcher comparable1
    -> Patcher comparable2
    -> Value
    -> Result Error (BiDict comparable1 comparable2)
build_BiDict keyPatcher valuePatcher p =
    case p of
        VDict fields ->
            List.foldl
                (\( addedKeyPatch, addedValuePatch ) acc ->
                    Result.map3 BiDict.insert
                        (Result.mapError (ErrorAtKey addedKeyPatch) <| keyPatcher.build addedKeyPatch)
                        (Result.mapError (ErrorAtValueWithKey addedKeyPatch) <| valuePatcher.build addedValuePatch)
                        acc
                )
                (Ok BiDict.empty)
                fields.items

        _ ->
            Err (WrongType "Patch.")


{-| -}
toValue_BiDict :
    Patcher comparable1
    -> Patcher comparable2
    -> BiDict comparable1 comparable2
    -> Value
toValue_BiDict keyPatcher valuePatcher dict =
    VDict
        { cursor = 0
        , items =
            BiDict.toList dict
                |> List.map
                    (\( key, value ) ->
                        ( keyPatcher.toValue key
                        , valuePatcher.toValue value
                        )
                    )
        }
