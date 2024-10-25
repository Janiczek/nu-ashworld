module Admin exposing (encodeToBackendMsg)

import BiDict
import Data.Auth as Auth
import Data.Barter as Barter
import Data.FightStrategy as FightStrategy
import Data.Item.Kind as ItemKind
import Data.Map as Map
import Data.NewChar as NewChar
import Data.Perk as Perk
import Data.Quest as Quest
import Data.Skill as Skill
import Data.Vendor.Shop as Shop
import Data.World as World
import Dict
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Queue
import Random
import Set.ExtraExtra as Set
import Time
import Types exposing (AdminToBackend(..), BackendModel, ToBackend(..))


encodeToBackendMsg : ToBackend -> JE.Value
encodeToBackendMsg msg =
    case msg of
        LogMeIn auth ->
            JE.object
                [ ( "type", JE.string "LogMeIn" )
                , ( "auth", Auth.encodeSanitized auth )
                ]

        RegisterMe auth ->
            JE.object
                [ ( "type", JE.string "RegisterMe" )
                , ( "auth", Auth.encodeSanitized auth )
                ]

        CreateNewChar newChar ->
            JE.object
                [ ( "type", JE.string "CreateNewChar" )
                , ( "newChar", NewChar.encode newChar )
                ]

        LogMeOut ->
            JE.object
                [ ( "type", JE.string "LogMeOut" ) ]

        Fight playerName ->
            JE.object
                [ ( "type", JE.string "Fight" )
                , ( "playerName", JE.string playerName )
                ]

        HealMe ->
            JE.object
                [ ( "type", JE.string "HealMe" ) ]

        UseItem itemId ->
            JE.object
                [ ( "type", JE.string "UseItem" )
                , ( "itemId", JE.int itemId )
                ]

        Wander ->
            JE.object
                [ ( "type", JE.string "Wander" ) ]

        EquipArmor itemId ->
            JE.object
                [ ( "type", JE.string "EquipArmor" )
                , ( "itemId", JE.int itemId )
                ]

        EquipWeapon itemId ->
            JE.object
                [ ( "type", JE.string "EquipWeapon" )
                , ( "itemId", JE.int itemId )
                ]

        PreferAmmo kind ->
            JE.object
                [ ( "type", JE.string "PreferAmmo" )
                , ( "itemKind", ItemKind.encode kind )
                ]

        UnequipArmor ->
            JE.object
                [ ( "type", JE.string "UnequipArmor" ) ]

        UnequipWeapon ->
            JE.object
                [ ( "type", JE.string "UnequipWeapon" ) ]

        ClearPreferredAmmo ->
            JE.object
                [ ( "type", JE.string "ClearPreferredAmmo" ) ]

        SetFightStrategy ( strategy, text ) ->
            JE.object
                [ ( "type", JE.string "SetFightStrategy" )
                , ( "strategy", FightStrategy.encode strategy )
                , ( "text", JE.string text )
                ]

        WorldsPlease ->
            JE.object
                [ ( "type", JE.string "WorldsPlease" ) ]

        RefreshPlease ->
            JE.object
                [ ( "type", JE.string "RefreshPlease" ) ]

        TagSkill skill ->
            JE.object
                [ ( "type", JE.string "TagSkill" )
                , ( "skill", Skill.encode skill )
                ]

        UseSkillPoints skill ->
            JE.object
                [ ( "type", JE.string "UseSkillPoints" )
                , ( "skill", Skill.encode skill )
                ]

        MoveTo coords path ->
            JE.object
                [ ( "type", JE.string "MoveTo" )
                , ( "coords", Map.encodeCoords coords )
                , ( "path", Set.encode Map.encodeCoords path )
                ]

        MessageWasRead messageId ->
            JE.object
                [ ( "type", JE.string "MessageWasRead" )
                , ( "messageId", JE.int messageId )
                ]

        RemoveMessage messageId ->
            JE.object
                [ ( "type", JE.string "RemoveMessage" )
                , ( "messageId", JE.int messageId )
                ]

        RemoveFightMessages ->
            JE.object
                [ ( "type", JE.string "RemoveFightMessages" )
                ]

        RemoveAllMessages ->
            JE.object
                [ ( "type", JE.string "RemoveAllMessages" )
                ]

        Barter barterState shop ->
            JE.object
                [ ( "type", JE.string "Barter" )
                , ( "barterState", Barter.encode barterState )
                , ( "shop", Shop.encode shop )
                ]

        ChoosePerk perk ->
            JE.object
                [ ( "type", JE.string "ChoosePerk" )
                , ( "perk", Perk.encode perk )
                ]

        StopProgressing quest ->
            JE.object
                [ ( "type", JE.string "StopProgressing" )
                , ( "quest", Quest.encode quest )
                ]

        StartProgressing quest ->
            JE.object
                [ ( "type", JE.string "StartProgressing" )
                , ( "quest", Quest.encode quest )
                ]

        AdminToBackend (CreateNewWorld worldName fast) ->
            JE.object
                [ ( "type", JE.string "AdminToBackend CreateNewWorld" )
                , ( "name", JE.string worldName )
                , ( "fast", JE.bool fast )
                ]

        FusionGiveMeBackendModel ->
            JE.object
                [ ( "type", JE.string "FusionGiveMeBackendModel" ) ]

        ApplyThisFusionPatch value ->
            JE.object
                [ ( "type", JE.string "ApplyThisFusionPatch" )
                , ( "value", JE.string "<omitted>" )
                ]
