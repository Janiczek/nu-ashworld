module Admin exposing
    ( backendModelDecoder
    , encodeBackendModel
    , encodeToBackendMsg
    )

import AssocList as Dict_
import Data.Auth as Auth
import Data.Barter as Barter
import Data.FightStrategy as FightStrategy
import Data.Map as Map
import Data.NewChar as NewChar
import Data.Perk as Perk
import Data.Player as Player
import Data.Skill as Skill
import Data.Vendor as Vendor
import Data.World as World
import Dict
import Dict.ExtraExtra as Dict
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.ExtraExtra as List
import Set.ExtraExtra as Set
import Time
import Types exposing (AdminToBackend(..), BackendModel, ToBackend(..))


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
            , lastTenToBackendMsgs = []
            }
        )
        (JD.field "worlds" (Dict.decoder JD.string World.decoder))


encodeToBackendMsg : ToBackend -> JE.Value
encodeToBackendMsg msg =
    case msg of
        LogMeIn auth ->
            JE.object
                [ ( "type", JE.string "LogMeIn" )
                , ( "auth", Auth.encode auth )
                ]

        RegisterMe auth ->
            JE.object
                [ ( "type", JE.string "RegisterMe" )
                , ( "auth", Auth.encode auth )
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

        EquipItem itemId ->
            JE.object
                [ ( "type", JE.string "EquipItem" )
                , ( "itemId", JE.int itemId )
                ]

        UnequipArmor ->
            JE.object
                [ ( "type", JE.string "UnequipArmor" ) ]

        SetFightStrategy ( strategy, text ) ->
            JE.object
                [ ( "type", JE.string "SetFightStrategy" )
                , ( "strategy", FightStrategy.encode strategy )
                , ( "text", JE.string text )
                ]

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

        Barter barterState ->
            JE.object
                [ ( "type", JE.string "Barter" )
                , ( "barterState", Barter.encode barterState )
                ]

        ChoosePerk perk ->
            JE.object
                [ ( "type", JE.string "ChoosePerk" )
                , ( "perk", Perk.encode perk )
                ]

        AdminToBackend ExportJson ->
            JE.object
                [ ( "type", JE.string "AdminToBackend ExportJson" ) ]

        AdminToBackend (ImportJson _) ->
            JE.object
                [ ( "type", JE.string "AdminToBackend ImportJson" )
                , ( "json", JE.string "<omitted>" )
                ]
