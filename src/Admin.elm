module Admin exposing
    ( backendModelCodec
    , toBackendMsgCodec
    )

import BiDict.Extra as BiDict
import Codec exposing (Codec)
import Data.Auth as Auth
import Data.Barter as Barter
import Data.FightStrategy as FightStrategy
import Data.Item.Kind as ItemKind
import Data.NewChar as NewChar
import Data.Perk as Perk
import Data.Quest as Quest
import Data.Skill as Skill
import Data.Vendor.Shop as Shop
import Data.World as World
import Dict
import Queue.Extra as Queue
import Random
import Time.ExtraExtra as Time
import Types exposing (AdminToBackend(..), BackendModel, ToBackend(..))


backendModelCodec : Random.Seed -> Codec BackendModel
backendModelCodec seed =
    Codec.object BackendModel
        |> Codec.field
            "worlds"
            .worlds
            (Codec.map Dict.fromList Dict.toList (Codec.list (Codec.tuple Codec.string World.codec)))
        |> Codec.field "time" .time Time.posixCodec
        |> Codec.field
            "loggedInPlayers"
            .loggedInPlayers
            (BiDict.codec Codec.string (Codec.tuple Codec.string Codec.string))
        |> Codec.field "adminLoggedIn" .adminLoggedIn (Codec.nullable (Codec.tuple Codec.string Codec.string))
        |> Codec.field
            "lastTenToBackendMsgs"
            .lastTenToBackendMsgs
            (Queue.codec (Codec.triple Codec.string Codec.string toBackendMsgCodec))
        |> Codec.field "randomSeed" .randomSeed (Codec.succeed seed)
        |> Codec.field
            "playerDataCache"
            .playerDataCache
            (Codec.map Dict.fromList Dict.toList (Codec.list (Codec.tuple Codec.string Codec.int)))
        |> Codec.buildObject


toBackendMsgCodec : Codec ToBackend
toBackendMsgCodec =
    Codec.custom
        (\logMeInEncoder signMeUpEncoder createNewCharEncoder logMeOutEncoder fightEncoder healMeEncoder useItemEncoder wanderEncoder equipArmorEncoder equipWeaponEncoder preferAmmoEncoder setFightStrategyEncoder unequipArmorEncoder unequipWeaponEncoder clearPreferredAmmoEncoder refreshPleaseEncoder worldsPleaseEncoder tagSkillEncoder useSkillPointsEncoder choosePerkEncoder moveToEncoder messageWasReadEncoder removeMessageEncoder removeFightMessagesEncoder removeAllMessagesEncoder barterEncoder adminToBackendEncoder stopProgressingEncoder startProgressingEncoder refuelCarEncoder value ->
            case value of
                LogMeIn arg0 ->
                    logMeInEncoder arg0

                SignMeUp arg0 ->
                    signMeUpEncoder arg0

                CreateNewChar arg0 ->
                    createNewCharEncoder arg0

                LogMeOut ->
                    logMeOutEncoder

                Fight arg0 ->
                    fightEncoder arg0

                HealMe ->
                    healMeEncoder

                UseItem arg0 ->
                    useItemEncoder arg0

                Wander ->
                    wanderEncoder

                EquipArmor arg0 ->
                    equipArmorEncoder arg0

                EquipWeapon arg0 ->
                    equipWeaponEncoder arg0

                PreferAmmo arg0 ->
                    preferAmmoEncoder arg0

                SetFightStrategy arg0 ->
                    setFightStrategyEncoder arg0

                UnequipArmor ->
                    unequipArmorEncoder

                UnequipWeapon ->
                    unequipWeaponEncoder

                ClearPreferredAmmo ->
                    clearPreferredAmmoEncoder

                RefreshPlease ->
                    refreshPleaseEncoder

                WorldsPlease ->
                    worldsPleaseEncoder

                TagSkill arg0 ->
                    tagSkillEncoder arg0

                UseSkillPoints arg0 ->
                    useSkillPointsEncoder arg0

                ChoosePerk arg0 ->
                    choosePerkEncoder arg0

                MoveTo arg0 arg1 ->
                    moveToEncoder arg0 arg1

                MessageWasRead arg0 ->
                    messageWasReadEncoder arg0

                RemoveMessage arg0 ->
                    removeMessageEncoder arg0

                RemoveFightMessages ->
                    removeFightMessagesEncoder

                RemoveAllMessages ->
                    removeAllMessagesEncoder

                Barter arg0 arg1 ->
                    barterEncoder arg0 arg1

                AdminToBackend arg0 ->
                    adminToBackendEncoder arg0

                StopProgressing arg0 ->
                    stopProgressingEncoder arg0

                StartProgressing arg0 ->
                    startProgressingEncoder arg0

                RefuelCar arg0 ->
                    refuelCarEncoder arg0
        )
        |> Codec.variant1 "LogMeIn" LogMeIn Auth.sanitizedCodec
        |> Codec.variant1 "SignMeUp" SignMeUp Auth.sanitizedCodec
        |> Codec.variant1 "CreateNewChar" CreateNewChar NewChar.codec
        |> Codec.variant0 "LogMeOut" LogMeOut
        |> Codec.variant1 "Fight" Fight Codec.string
        |> Codec.variant0 "HealMe" HealMe
        |> Codec.variant1 "UseItem" UseItem Codec.int
        |> Codec.variant0 "Wander" Wander
        |> Codec.variant1 "EquipArmor" EquipArmor Codec.int
        |> Codec.variant1 "EquipWeapon" EquipWeapon Codec.int
        |> Codec.variant1 "PreferAmmo" PreferAmmo ItemKind.codec
        |> Codec.variant1 "SetFightStrategy" SetFightStrategy (Codec.tuple FightStrategy.codec Codec.string)
        |> Codec.variant0 "UnequipArmor" UnequipArmor
        |> Codec.variant0 "UnequipWeapon" UnequipWeapon
        |> Codec.variant0 "ClearPreferredAmmo" ClearPreferredAmmo
        |> Codec.variant0 "RefreshPlease" RefreshPlease
        |> Codec.variant0 "WorldsPlease" WorldsPlease
        |> Codec.variant1 "TagSkill" TagSkill Skill.codec
        |> Codec.variant1 "UseSkillPoints" UseSkillPoints Skill.codec
        |> Codec.variant1 "ChoosePerk" ChoosePerk Perk.codec
        |> Codec.variant2
            "MoveTo"
            MoveTo
            (Codec.tuple Codec.int Codec.int)
            (Codec.set (Codec.tuple Codec.int Codec.int))
        |> Codec.variant1 "MessageWasRead" MessageWasRead Codec.int
        |> Codec.variant1 "RemoveMessage" RemoveMessage Codec.int
        |> Codec.variant0 "RemoveFightMessages" RemoveFightMessages
        |> Codec.variant0 "RemoveAllMessages" RemoveAllMessages
        |> Codec.variant2 "Barter" Barter Barter.codec Shop.codec
        |> Codec.variant1 "AdminToBackend" AdminToBackend adminToBackendCodec
        |> Codec.variant1 "StopProgressing" StopProgressing Quest.codec
        |> Codec.variant1 "StartProgressing" StartProgressing Quest.codec
        |> Codec.variant1 "RefuelCar" RefuelCar ItemKind.codec
        |> Codec.buildCustom


adminToBackendCodec : Codec AdminToBackend
adminToBackendCodec =
    Codec.custom
        (\exportJsonEncoder importJsonEncoder createNewWorldEncoder changeWorldSpeedEncoder value ->
            case value of
                ExportJson ->
                    exportJsonEncoder

                ImportJson arg0 ->
                    importJsonEncoder arg0

                CreateNewWorld arg0 arg1 ->
                    createNewWorldEncoder arg0 arg1

                ChangeWorldSpeed arg0 ->
                    changeWorldSpeedEncoder arg0
        )
        |> Codec.variant0 "ExportJson" ExportJson
        |> Codec.variant1 "ImportJson" ImportJson Codec.string
        |> Codec.variant2 "CreateNewWorld" CreateNewWorld Codec.string Codec.bool
        |> Codec.variant1 "ChangeWorldSpeed"
            ChangeWorldSpeed
            (Codec.object (\world fast -> { world = world, fast = fast })
                |> Codec.field "world" .world Codec.string
                |> Codec.field "fast" .fast Codec.bool
                |> Codec.buildObject
            )
        |> Codec.buildCustom
