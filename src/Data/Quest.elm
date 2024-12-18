module Data.Quest exposing
    ( GlobalReward(..)
    , PlayerRequirement(..)
    , PlayerReward(..)
    , Progress
    , Quest(..)
    , SkillRequirement(..)
    , all
    , allForLocation
    , codec
    , completionText
    , description
    , exclusiveWith
    , globalRewardCodec
    , globalRewardTitle
    , globalRewards
    , isExclusiveWith
    , location
    , locationQuestRequirements
    , playerRequirementTitle
    , playerRequirements
    , playerRewardCodec
    , playerRewardTitle
    , playerRewards
    , questRequirements
    , ticksNeeded
    , title
    , xpPerTickGiven
    )

import Codec exposing (Codec)
import Data.Item.Kind as ItemKind
import Data.Map.Location as Location exposing (Location)
import Data.Perk as Perk exposing (Perk)
import Data.Skill as Skill exposing (Skill)
import Data.Vendor.Shop as Shop exposing (Shop)
import SeqDict exposing (SeqDict)



{- TODO quest in NCR about the suicidal guy: time attack - the first time
   somebody starts that quest, a global time limit for everybody starts; if the
   quest isn't finished by then, it fails and something in the world changes
-}


type Quest
    = ArroyoKillEvilPlants
    | ArroyoFixWellForFeargus
    | ArroyoRescueNagorsDog
    | KlamathRefuelStill
    | KlamathGuardTheBrahmin
    | KlamathRustleTheBrahmin
    | KlamathKillRatGod
    | KlamathRescueTorr
    | KlamathSearchForSmileyTrapper
    | KlamathGetFuelCellRegulator
    | ToxicCavesRescueSmileyTrapper
    | ToxicCavesRepairTheGenerator
    | ToxicCavesLootTheBunker
    | DenFreeVicByPayingMetzger
    | DenFreeVicByKillingOffSlaversGuild
    | DenDeliverMealToSmitty
    | DenFixTheCar
    | ModocInvestigateGhostFarm
    | ModocRemoveInfestationInFarrelsGarden
    | ModocMediateBetweenSlagsAndJo
    | ModocFindGoldWatchForCornelius
    | ModocFindGoldWatchForFarrel
    | VaultCityGetPlowForMrSmith
    | VaultCityRescueAmandasHusband
    | GeckoOptimizePowerPlant
    | GeckoGetFuelCellControllerFromSkeeter
    | ReddingClearWanamingoMine
    | ReddingFindExcavatorChip
    | NewRenoTrackDownPrettyBoyLloyd
    | NewRenoHelpGuardSecretTransaction
    | NewRenoCollectTributeFromCorsicanBrothers
    | NewRenoWinBoxingTournament
    | NewRenoAcquireElectronicLockpick
    | NCRGuardBrahminCaravan
    | NCRTestMutagenicSerum
    | NCRRetrieveComputerParts
    | NCRFreeSlaves
    | NCRInvestigateBrahminRaids
    | V15RescueChrissy
    | V15CompleteDealWithNCR
    | V13FixVaultComputer
    | V13FindTheGeck
    | BrokenHillsFixMineAirPurifier
    | BrokenHillsBlowUpMineAirPurifier
    | BrokenHillsFindMissingPeople
    | BrokenHillsBeatFrancisAtArmwrestling
    | RaidersFindEvidenceOfBishopTampering
    | RaidersKillEverybody
    | SierraArmyDepotFindAbnormalBrainForSkynet
    | SierraArmyDepotFindChimpanzeeBrainForSkynet
    | SierraArmyDepotFindHumanBrainForSkynet
    | SierraArmyDepotFindCyberneticBrainForSkynet
    | SierraArmyDepotAssembleBodyForSkynet
    | MilitaryBaseExcavateTheEntrance
    | MilitaryBaseKillMelchior
    | SanFranciscoFindFuelForTanker
    | SanFranciscoFindLocationOfFobForTanker
    | SanFranciscoFindNavCompPartForTanker
    | SanFranciscoFindVertibirdPlansForHubologists
    | SanFranciscoFindVertibirdPlansForShi
    | SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel
    | SanFranciscoFindBadgersGirlfriendInsideShip
    | SanFranciscoDefeatLoPanInRingForDragon
    | SanFranciscoDefeatDragonInRingForLoPan
    | SanFranciscoEmbarkForEnclave
    | NavarroFixK9
    | NavarroRetrieveFobForTanker
    | EnclavePersuadeControlCompanySquadToDesert
    | EnclaveKillThePresidentStealthily
    | EnclaveKillThePresidentTheUsualWay
    | EnclaveFindTheGeck
    | EnclaveRigTurretsToTargetFrankHorrigan
    | EnclaveForceScientistToInitiateSelfDestruct
    | EnclaveKillFrankHorrigan
    | EnclaveReturnToMainland


all : List Quest
all =
    [ ArroyoKillEvilPlants
    , ArroyoFixWellForFeargus
    , ArroyoRescueNagorsDog
    , KlamathRefuelStill
    , KlamathGuardTheBrahmin
    , KlamathRustleTheBrahmin
    , KlamathKillRatGod
    , KlamathRescueTorr
    , KlamathSearchForSmileyTrapper
    , KlamathGetFuelCellRegulator
    , ToxicCavesRescueSmileyTrapper
    , ToxicCavesRepairTheGenerator
    , ToxicCavesLootTheBunker
    , DenFreeVicByPayingMetzger
    , DenFreeVicByKillingOffSlaversGuild
    , DenDeliverMealToSmitty
    , DenFixTheCar
    , ModocInvestigateGhostFarm
    , ModocRemoveInfestationInFarrelsGarden
    , ModocMediateBetweenSlagsAndJo
    , ModocFindGoldWatchForCornelius
    , ModocFindGoldWatchForFarrel
    , VaultCityGetPlowForMrSmith
    , VaultCityRescueAmandasHusband
    , GeckoOptimizePowerPlant
    , GeckoGetFuelCellControllerFromSkeeter
    , ReddingClearWanamingoMine
    , ReddingFindExcavatorChip
    , NewRenoTrackDownPrettyBoyLloyd
    , NewRenoHelpGuardSecretTransaction
    , NewRenoCollectTributeFromCorsicanBrothers
    , NewRenoWinBoxingTournament
    , NewRenoAcquireElectronicLockpick
    , NCRGuardBrahminCaravan
    , NCRTestMutagenicSerum
    , NCRRetrieveComputerParts
    , NCRFreeSlaves
    , NCRInvestigateBrahminRaids
    , V15RescueChrissy
    , V15CompleteDealWithNCR
    , V13FixVaultComputer
    , V13FindTheGeck
    , BrokenHillsFixMineAirPurifier
    , BrokenHillsBlowUpMineAirPurifier
    , BrokenHillsFindMissingPeople
    , BrokenHillsBeatFrancisAtArmwrestling
    , RaidersFindEvidenceOfBishopTampering
    , RaidersKillEverybody
    , SierraArmyDepotFindAbnormalBrainForSkynet
    , SierraArmyDepotFindChimpanzeeBrainForSkynet
    , SierraArmyDepotFindHumanBrainForSkynet
    , SierraArmyDepotFindCyberneticBrainForSkynet
    , SierraArmyDepotAssembleBodyForSkynet
    , MilitaryBaseExcavateTheEntrance
    , MilitaryBaseKillMelchior
    , SanFranciscoFindFuelForTanker
    , SanFranciscoFindLocationOfFobForTanker
    , SanFranciscoFindNavCompPartForTanker
    , SanFranciscoFindVertibirdPlansForHubologists
    , SanFranciscoFindVertibirdPlansForShi
    , SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel
    , SanFranciscoFindBadgersGirlfriendInsideShip
    , SanFranciscoDefeatLoPanInRingForDragon
    , SanFranciscoDefeatDragonInRingForLoPan
    , SanFranciscoEmbarkForEnclave
    , NavarroFixK9
    , NavarroRetrieveFobForTanker
    , EnclavePersuadeControlCompanySquadToDesert
    , EnclaveKillThePresidentStealthily
    , EnclaveKillThePresidentTheUsualWay
    , EnclaveFindTheGeck
    , EnclaveRigTurretsToTargetFrankHorrigan
    , EnclaveForceScientistToInitiateSelfDestruct
    , EnclaveKillFrankHorrigan
    , EnclaveReturnToMainland
    ]


type alias Progress =
    { playersActive : Int
    , ticksPerHour : Int
    , ticksGiven : Int
    , ticksGivenByPlayer : Int
    , alreadyPaidRequirements : Bool
    }


title : Quest -> String
title quest =
    case quest of
        ArroyoKillEvilPlants ->
            "Kill the evil plants that infest Hakunin's garden"

        ArroyoFixWellForFeargus ->
            "Fix the well for Feargus"

        ArroyoRescueNagorsDog ->
            "Rescue Nagor's dog, Smoke, from the wilds"

        KlamathRefuelStill ->
            "Refuel the still for Whiskey Bob"

        KlamathGuardTheBrahmin ->
            "Guard the brahmin for Torr"

        KlamathRustleTheBrahmin ->
            "Rustle Torr's brahmin for Dunton brothers"

        KlamathKillRatGod ->
            "Kill the rat god Keeng Ra'at"

        KlamathRescueTorr ->
            "Rescue Torr from the Klamath Canyon"

        KlamathSearchForSmileyTrapper ->
            "Search for Smiley the Trapper"

        KlamathGetFuelCellRegulator ->
            "Get fuel cell regulator"

        ToxicCavesRescueSmileyTrapper ->
            "Rescue Smiley the Trapper"

        ToxicCavesRepairTheGenerator ->
            "Repair the generator"

        ToxicCavesLootTheBunker ->
            "Loot the bunker"

        DenFreeVicByPayingMetzger ->
            "Free Vic from his debt by paying Metzger"

        DenFreeVicByKillingOffSlaversGuild ->
            "Free Vic from his debt by killing off the Slavers Guild"

        DenDeliverMealToSmitty ->
            "Deliver meal to Smitty for Mom"

        DenFixTheCar ->
            "Fix the car"

        ModocInvestigateGhostFarm ->
            "Investigate the 'Ghost Farm'"

        ModocRemoveInfestationInFarrelsGarden ->
            "Remove the rodent infestation in Farrel's garden"

        ModocMediateBetweenSlagsAndJo ->
            "Mediate between Slags and Jo"

        ModocFindGoldWatchForCornelius ->
            "Find the gold watch for Cornelius"

        ModocFindGoldWatchForFarrel ->
            "Find the gold watch for Farrel"

        VaultCityGetPlowForMrSmith ->
            "Get a plow for Mr. Smith"

        VaultCityRescueAmandasHusband ->
            "Rescue Amanda's husband"

        GeckoOptimizePowerPlant ->
            "Optimize the power plant"

        GeckoGetFuelCellControllerFromSkeeter ->
            "Get fuel cell controller from Skeeter"

        ReddingClearWanamingoMine ->
            "Clear the Wanamingo mine"

        ReddingFindExcavatorChip ->
            "Find the excavator chip"

        NewRenoTrackDownPrettyBoyLloyd ->
            "Track down Pretty Boy Lloyd"

        NewRenoHelpGuardSecretTransaction ->
            "Help guard a secret transaction"

        NewRenoCollectTributeFromCorsicanBrothers ->
            "Collect tribute from Corsican Brothers"

        NewRenoWinBoxingTournament ->
            "Win a boxing tournament"

        NewRenoAcquireElectronicLockpick ->
            "Acquire electronic lockpick"

        NCRGuardBrahminCaravan ->
            "Guard a brahmin caravan"

        NCRTestMutagenicSerum ->
            "Test a mutagenic serum"

        NCRRetrieveComputerParts ->
            "Retrieve computer parts for Tandi"

        NCRFreeSlaves ->
            "Free slaves"

        NCRInvestigateBrahminRaids ->
            "Investigate brahmin raids"

        V15RescueChrissy ->
            "Rescue Chrissy"

        V15CompleteDealWithNCR ->
            "Complete a deal with the NCR"

        V13FixVaultComputer ->
            "Fix the vault computer"

        V13FindTheGeck ->
            "Find the GECK"

        BrokenHillsFixMineAirPurifier ->
            "Fix the mine air purifier"

        BrokenHillsBlowUpMineAirPurifier ->
            "Blow up the mine air purifier"

        BrokenHillsFindMissingPeople ->
            "Find the missing people"

        BrokenHillsBeatFrancisAtArmwrestling ->
            "Beat Francis at armwrestling"

        RaidersFindEvidenceOfBishopTampering ->
            "Find evidence of Bishop tampering"

        RaidersKillEverybody ->
            "Kill everybody in the raiders' base"

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            "Find an abnormal brain for Skynet"

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            "Find a chimpanzee brain for Skynet"

        SierraArmyDepotFindHumanBrainForSkynet ->
            "Find a human brain for Skynet"

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            "Find a cybernetic brain for Skynet"

        SierraArmyDepotAssembleBodyForSkynet ->
            "Assemble a body for Skynet"

        MilitaryBaseExcavateTheEntrance ->
            "Excavate the entrance"

        MilitaryBaseKillMelchior ->
            "Kill Melchior in the Vats"

        SanFranciscoFindFuelForTanker ->
            "Find fuel for the tanker"

        SanFranciscoFindLocationOfFobForTanker ->
            "Find location of fob for the tanker"

        SanFranciscoFindNavCompPartForTanker ->
            "Find NavComp part for the tanker"

        SanFranciscoFindVertibirdPlansForHubologists ->
            "Find the vertibird plans for Hubologists"

        SanFranciscoFindVertibirdPlansForShi ->
            "Find the vertibird plans for Shi"

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            "Find the vertibird plans for the Brotherhood of Steel"

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            "Find Badger's girlfriend inside ship"

        SanFranciscoDefeatLoPanInRingForDragon ->
            "Defeat Lo Pan in the ring for Dragon"

        SanFranciscoDefeatDragonInRingForLoPan ->
            "Defeat Dragon in the ring for Lo Pan"

        SanFranciscoEmbarkForEnclave ->
            "Embark for the Enclave"

        NavarroFixK9 ->
            "Fix K9"

        NavarroRetrieveFobForTanker ->
            "Retrieve the fob for the tanker"

        EnclavePersuadeControlCompanySquadToDesert ->
            "Persuade the Control Company squad to desert"

        EnclaveKillThePresidentStealthily ->
            "Kill the President in a stealthy way"

        EnclaveKillThePresidentTheUsualWay ->
            "Kill the President the usual way"

        EnclaveFindTheGeck ->
            "Find the GECK"

        EnclaveRigTurretsToTargetFrankHorrigan ->
            "Rig turrets to target Frank Horrigan"

        EnclaveForceScientistToInitiateSelfDestruct ->
            "Force the scientist Tom Murray to initiate a self-destruct sequence"

        EnclaveKillFrankHorrigan ->
            "Kill Frank Horrigan"

        EnclaveReturnToMainland ->
            "Return to the mainland"


ticksNeeded : Quest -> Int
ticksNeeded quest =
    case quest of
        ArroyoKillEvilPlants ->
            40

        ArroyoFixWellForFeargus ->
            20

        ArroyoRescueNagorsDog ->
            30

        KlamathRefuelStill ->
            50

        KlamathGuardTheBrahmin ->
            40

        KlamathRustleTheBrahmin ->
            40

        KlamathKillRatGod ->
            75

        KlamathRescueTorr ->
            30

        KlamathSearchForSmileyTrapper ->
            40

        KlamathGetFuelCellRegulator ->
            200

        ToxicCavesRescueSmileyTrapper ->
            75

        ToxicCavesRepairTheGenerator ->
            40

        ToxicCavesLootTheBunker ->
            100

        DenFreeVicByPayingMetzger ->
            200

        DenFreeVicByKillingOffSlaversGuild ->
            200

        DenDeliverMealToSmitty ->
            50

        DenFixTheCar ->
            100

        ModocInvestigateGhostFarm ->
            100

        ModocRemoveInfestationInFarrelsGarden ->
            75

        ModocMediateBetweenSlagsAndJo ->
            50

        ModocFindGoldWatchForCornelius ->
            75

        ModocFindGoldWatchForFarrel ->
            75

        VaultCityGetPlowForMrSmith ->
            50

        VaultCityRescueAmandasHusband ->
            100

        GeckoOptimizePowerPlant ->
            100

        GeckoGetFuelCellControllerFromSkeeter ->
            200

        ReddingClearWanamingoMine ->
            200

        ReddingFindExcavatorChip ->
            100

        NewRenoTrackDownPrettyBoyLloyd ->
            100

        NewRenoHelpGuardSecretTransaction ->
            75

        NewRenoCollectTributeFromCorsicanBrothers ->
            75

        NewRenoWinBoxingTournament ->
            150

        NewRenoAcquireElectronicLockpick ->
            50

        NCRGuardBrahminCaravan ->
            75

        NCRTestMutagenicSerum ->
            60

        NCRRetrieveComputerParts ->
            150

        NCRFreeSlaves ->
            80

        NCRInvestigateBrahminRaids ->
            75

        V15RescueChrissy ->
            100

        V15CompleteDealWithNCR ->
            200

        V13FixVaultComputer ->
            75

        V13FindTheGeck ->
            50

        BrokenHillsFixMineAirPurifier ->
            100

        BrokenHillsBlowUpMineAirPurifier ->
            100

        BrokenHillsFindMissingPeople ->
            100

        BrokenHillsBeatFrancisAtArmwrestling ->
            50

        RaidersFindEvidenceOfBishopTampering ->
            100

        RaidersKillEverybody ->
            200

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            100

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            100

        SierraArmyDepotFindHumanBrainForSkynet ->
            100

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            100

        SierraArmyDepotAssembleBodyForSkynet ->
            200

        MilitaryBaseExcavateTheEntrance ->
            100

        MilitaryBaseKillMelchior ->
            75

        SanFranciscoFindFuelForTanker ->
            120

        SanFranciscoFindLocationOfFobForTanker ->
            50

        SanFranciscoFindNavCompPartForTanker ->
            75

        SanFranciscoFindVertibirdPlansForHubologists ->
            150

        SanFranciscoFindVertibirdPlansForShi ->
            150

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            150

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            200

        SanFranciscoDefeatLoPanInRingForDragon ->
            100

        SanFranciscoDefeatDragonInRingForLoPan ->
            100

        SanFranciscoEmbarkForEnclave ->
            100

        NavarroFixK9 ->
            150

        NavarroRetrieveFobForTanker ->
            100

        EnclavePersuadeControlCompanySquadToDesert ->
            100

        EnclaveKillThePresidentStealthily ->
            150

        EnclaveKillThePresidentTheUsualWay ->
            150

        EnclaveFindTheGeck ->
            150

        EnclaveRigTurretsToTargetFrankHorrigan ->
            150

        EnclaveForceScientistToInitiateSelfDestruct ->
            100

        EnclaveKillFrankHorrigan ->
            300

        EnclaveReturnToMainland ->
            100


xpPerTickGiven : Quest -> Int
xpPerTickGiven quest =
    case quest of
        ArroyoKillEvilPlants ->
            50

        ArroyoFixWellForFeargus ->
            100

        ArroyoRescueNagorsDog ->
            75

        KlamathRefuelStill ->
            50

        KlamathGuardTheBrahmin ->
            100

        KlamathRustleTheBrahmin ->
            100

        KlamathKillRatGod ->
            150

        KlamathRescueTorr ->
            100

        KlamathSearchForSmileyTrapper ->
            75

        KlamathGetFuelCellRegulator ->
            150

        ToxicCavesRescueSmileyTrapper ->
            150

        ToxicCavesRepairTheGenerator ->
            200

        ToxicCavesLootTheBunker ->
            500

        DenFreeVicByPayingMetzger ->
            200

        DenFreeVicByKillingOffSlaversGuild ->
            200

        DenDeliverMealToSmitty ->
            100

        DenFixTheCar ->
            200

        ModocInvestigateGhostFarm ->
            250

        ModocRemoveInfestationInFarrelsGarden ->
            200

        ModocMediateBetweenSlagsAndJo ->
            250

        ModocFindGoldWatchForCornelius ->
            200

        ModocFindGoldWatchForFarrel ->
            200

        VaultCityGetPlowForMrSmith ->
            250

        VaultCityRescueAmandasHusband ->
            300

        GeckoOptimizePowerPlant ->
            350

        GeckoGetFuelCellControllerFromSkeeter ->
            300

        ReddingClearWanamingoMine ->
            400

        ReddingFindExcavatorChip ->
            350

        NewRenoTrackDownPrettyBoyLloyd ->
            300

        NewRenoHelpGuardSecretTransaction ->
            400

        NewRenoCollectTributeFromCorsicanBrothers ->
            300

        NewRenoWinBoxingTournament ->
            400

        NewRenoAcquireElectronicLockpick ->
            200

        NCRGuardBrahminCaravan ->
            350

        NCRTestMutagenicSerum ->
            300

        NCRRetrieveComputerParts ->
            500

        NCRFreeSlaves ->
            450

        NCRInvestigateBrahminRaids ->
            350

        V15RescueChrissy ->
            400

        V15CompleteDealWithNCR ->
            500

        V13FixVaultComputer ->
            700

        V13FindTheGeck ->
            800

        BrokenHillsFixMineAirPurifier ->
            600

        BrokenHillsBlowUpMineAirPurifier ->
            600

        BrokenHillsFindMissingPeople ->
            500

        BrokenHillsBeatFrancisAtArmwrestling ->
            600

        RaidersFindEvidenceOfBishopTampering ->
            600

        RaidersKillEverybody ->
            700

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            300

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            400

        SierraArmyDepotFindHumanBrainForSkynet ->
            500

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            600

        SierraArmyDepotAssembleBodyForSkynet ->
            800

        MilitaryBaseExcavateTheEntrance ->
            700

        MilitaryBaseKillMelchior ->
            800

        SanFranciscoFindFuelForTanker ->
            600

        SanFranciscoFindLocationOfFobForTanker ->
            500

        SanFranciscoFindNavCompPartForTanker ->
            700

        SanFranciscoFindVertibirdPlansForHubologists ->
            750

        SanFranciscoFindVertibirdPlansForShi ->
            750

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            750

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            700

        SanFranciscoDefeatLoPanInRingForDragon ->
            700

        SanFranciscoDefeatDragonInRingForLoPan ->
            700

        SanFranciscoEmbarkForEnclave ->
            800

        NavarroFixK9 ->
            750

        NavarroRetrieveFobForTanker ->
            850

        EnclavePersuadeControlCompanySquadToDesert ->
            800

        EnclaveKillThePresidentStealthily ->
            850

        EnclaveKillThePresidentTheUsualWay ->
            850

        EnclaveFindTheGeck ->
            800

        EnclaveRigTurretsToTargetFrankHorrigan ->
            850

        EnclaveForceScientistToInitiateSelfDestruct ->
            900

        EnclaveKillFrankHorrigan ->
            1000

        EnclaveReturnToMainland ->
            1000


location : Quest -> Location
location quest =
    case quest of
        ArroyoKillEvilPlants ->
            Location.Arroyo

        ArroyoFixWellForFeargus ->
            Location.Arroyo

        ArroyoRescueNagorsDog ->
            Location.Arroyo

        KlamathRefuelStill ->
            Location.Klamath

        KlamathGuardTheBrahmin ->
            Location.Klamath

        KlamathRustleTheBrahmin ->
            Location.Klamath

        KlamathKillRatGod ->
            Location.Klamath

        KlamathRescueTorr ->
            Location.Klamath

        KlamathSearchForSmileyTrapper ->
            Location.Klamath

        KlamathGetFuelCellRegulator ->
            Location.Klamath

        ToxicCavesRescueSmileyTrapper ->
            Location.ToxicCaves

        ToxicCavesRepairTheGenerator ->
            Location.ToxicCaves

        ToxicCavesLootTheBunker ->
            Location.ToxicCaves

        DenFreeVicByPayingMetzger ->
            Location.Den

        DenFreeVicByKillingOffSlaversGuild ->
            Location.Den

        DenDeliverMealToSmitty ->
            Location.Den

        DenFixTheCar ->
            Location.Den

        ModocInvestigateGhostFarm ->
            Location.Modoc

        ModocRemoveInfestationInFarrelsGarden ->
            Location.Modoc

        ModocMediateBetweenSlagsAndJo ->
            Location.Modoc

        ModocFindGoldWatchForCornelius ->
            Location.Modoc

        ModocFindGoldWatchForFarrel ->
            Location.Modoc

        VaultCityGetPlowForMrSmith ->
            Location.VaultCity

        VaultCityRescueAmandasHusband ->
            Location.VaultCity

        GeckoOptimizePowerPlant ->
            Location.Gecko

        GeckoGetFuelCellControllerFromSkeeter ->
            Location.Gecko

        ReddingClearWanamingoMine ->
            Location.Redding

        ReddingFindExcavatorChip ->
            Location.Redding

        NewRenoTrackDownPrettyBoyLloyd ->
            Location.NewReno

        NewRenoHelpGuardSecretTransaction ->
            Location.NewReno

        NewRenoCollectTributeFromCorsicanBrothers ->
            Location.NewReno

        NewRenoWinBoxingTournament ->
            Location.NewReno

        NewRenoAcquireElectronicLockpick ->
            Location.NewReno

        NCRGuardBrahminCaravan ->
            Location.NewCaliforniaRepublic

        NCRTestMutagenicSerum ->
            Location.NewCaliforniaRepublic

        NCRRetrieveComputerParts ->
            Location.NewCaliforniaRepublic

        NCRFreeSlaves ->
            Location.NewCaliforniaRepublic

        NCRInvestigateBrahminRaids ->
            Location.NewCaliforniaRepublic

        V15RescueChrissy ->
            Location.Vault15

        V15CompleteDealWithNCR ->
            Location.Vault15

        V13FixVaultComputer ->
            Location.Vault13

        V13FindTheGeck ->
            Location.Vault13

        BrokenHillsFixMineAirPurifier ->
            Location.BrokenHills

        BrokenHillsBlowUpMineAirPurifier ->
            Location.BrokenHills

        BrokenHillsFindMissingPeople ->
            Location.BrokenHills

        BrokenHillsBeatFrancisAtArmwrestling ->
            Location.BrokenHills

        RaidersFindEvidenceOfBishopTampering ->
            Location.Raiders

        RaidersKillEverybody ->
            Location.Raiders

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            Location.SierraArmyDepot

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            Location.SierraArmyDepot

        SierraArmyDepotFindHumanBrainForSkynet ->
            Location.SierraArmyDepot

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            Location.SierraArmyDepot

        SierraArmyDepotAssembleBodyForSkynet ->
            Location.SierraArmyDepot

        MilitaryBaseExcavateTheEntrance ->
            Location.MilitaryBase

        MilitaryBaseKillMelchior ->
            Location.MilitaryBase

        SanFranciscoFindFuelForTanker ->
            Location.SanFrancisco

        SanFranciscoFindLocationOfFobForTanker ->
            Location.SanFrancisco

        SanFranciscoFindNavCompPartForTanker ->
            Location.SanFrancisco

        SanFranciscoFindVertibirdPlansForHubologists ->
            Location.SanFrancisco

        SanFranciscoFindVertibirdPlansForShi ->
            Location.SanFrancisco

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            Location.SanFrancisco

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            Location.SanFrancisco

        SanFranciscoDefeatLoPanInRingForDragon ->
            Location.SanFrancisco

        SanFranciscoDefeatDragonInRingForLoPan ->
            Location.SanFrancisco

        SanFranciscoEmbarkForEnclave ->
            Location.SanFrancisco

        NavarroFixK9 ->
            Location.Navarro

        NavarroRetrieveFobForTanker ->
            Location.Navarro

        EnclavePersuadeControlCompanySquadToDesert ->
            Location.EnclavePlatform

        EnclaveKillThePresidentStealthily ->
            Location.EnclavePlatform

        EnclaveKillThePresidentTheUsualWay ->
            Location.EnclavePlatform

        EnclaveFindTheGeck ->
            Location.EnclavePlatform

        EnclaveRigTurretsToTargetFrankHorrigan ->
            Location.EnclavePlatform

        EnclaveForceScientistToInitiateSelfDestruct ->
            Location.EnclavePlatform

        EnclaveKillFrankHorrigan ->
            Location.EnclavePlatform

        EnclaveReturnToMainland ->
            Location.EnclavePlatform


exclusiveWith : Quest -> List Quest
exclusiveWith quest =
    -- if one of these is finished, the rest cannot be done
    -- advancing one impedes the rest (moving along a n-gon?)
    case quest of
        ArroyoKillEvilPlants ->
            []

        ArroyoFixWellForFeargus ->
            []

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            [ KlamathRustleTheBrahmin ]

        KlamathRustleTheBrahmin ->
            [ KlamathGuardTheBrahmin ]

        KlamathKillRatGod ->
            []

        KlamathRescueTorr ->
            []

        KlamathSearchForSmileyTrapper ->
            []

        KlamathGetFuelCellRegulator ->
            []

        ToxicCavesRescueSmileyTrapper ->
            []

        ToxicCavesRepairTheGenerator ->
            []

        ToxicCavesLootTheBunker ->
            []

        DenFreeVicByPayingMetzger ->
            [ DenFreeVicByKillingOffSlaversGuild ]

        DenFreeVicByKillingOffSlaversGuild ->
            [ DenFreeVicByPayingMetzger ]

        DenDeliverMealToSmitty ->
            []

        DenFixTheCar ->
            []

        ModocInvestigateGhostFarm ->
            []

        ModocRemoveInfestationInFarrelsGarden ->
            []

        ModocMediateBetweenSlagsAndJo ->
            []

        ModocFindGoldWatchForCornelius ->
            [ ModocFindGoldWatchForFarrel ]

        ModocFindGoldWatchForFarrel ->
            [ ModocFindGoldWatchForCornelius ]

        VaultCityGetPlowForMrSmith ->
            []

        VaultCityRescueAmandasHusband ->
            []

        GeckoOptimizePowerPlant ->
            []

        GeckoGetFuelCellControllerFromSkeeter ->
            []

        ReddingClearWanamingoMine ->
            []

        ReddingFindExcavatorChip ->
            []

        NewRenoTrackDownPrettyBoyLloyd ->
            []

        NewRenoHelpGuardSecretTransaction ->
            []

        NewRenoCollectTributeFromCorsicanBrothers ->
            []

        NewRenoWinBoxingTournament ->
            []

        NewRenoAcquireElectronicLockpick ->
            []

        NCRGuardBrahminCaravan ->
            []

        NCRTestMutagenicSerum ->
            []

        NCRRetrieveComputerParts ->
            []

        NCRFreeSlaves ->
            []

        NCRInvestigateBrahminRaids ->
            []

        V15RescueChrissy ->
            []

        V15CompleteDealWithNCR ->
            []

        V13FixVaultComputer ->
            []

        V13FindTheGeck ->
            []

        BrokenHillsFixMineAirPurifier ->
            [ BrokenHillsBlowUpMineAirPurifier ]

        BrokenHillsBlowUpMineAirPurifier ->
            [ BrokenHillsFixMineAirPurifier ]

        BrokenHillsFindMissingPeople ->
            []

        BrokenHillsBeatFrancisAtArmwrestling ->
            []

        RaidersFindEvidenceOfBishopTampering ->
            []

        RaidersKillEverybody ->
            []

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            [ SierraArmyDepotFindChimpanzeeBrainForSkynet
            , SierraArmyDepotFindHumanBrainForSkynet
            , SierraArmyDepotFindCyberneticBrainForSkynet
            ]

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            [ SierraArmyDepotFindHumanBrainForSkynet
            , SierraArmyDepotFindCyberneticBrainForSkynet
            , SierraArmyDepotFindAbnormalBrainForSkynet
            ]

        SierraArmyDepotFindHumanBrainForSkynet ->
            [ SierraArmyDepotFindCyberneticBrainForSkynet
            , SierraArmyDepotFindAbnormalBrainForSkynet
            , SierraArmyDepotFindChimpanzeeBrainForSkynet
            ]

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            [ SierraArmyDepotFindAbnormalBrainForSkynet
            , SierraArmyDepotFindChimpanzeeBrainForSkynet
            , SierraArmyDepotFindHumanBrainForSkynet
            ]

        SierraArmyDepotAssembleBodyForSkynet ->
            []

        MilitaryBaseExcavateTheEntrance ->
            []

        MilitaryBaseKillMelchior ->
            []

        SanFranciscoFindFuelForTanker ->
            []

        SanFranciscoFindLocationOfFobForTanker ->
            []

        SanFranciscoFindNavCompPartForTanker ->
            []

        SanFranciscoFindVertibirdPlansForHubologists ->
            [ SanFranciscoFindVertibirdPlansForShi
            , SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel
            ]

        SanFranciscoFindVertibirdPlansForShi ->
            [ SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel
            , SanFranciscoFindVertibirdPlansForHubologists
            ]

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            [ SanFranciscoFindVertibirdPlansForHubologists
            , SanFranciscoFindVertibirdPlansForShi
            ]

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            []

        SanFranciscoDefeatLoPanInRingForDragon ->
            [ SanFranciscoDefeatDragonInRingForLoPan ]

        SanFranciscoDefeatDragonInRingForLoPan ->
            [ SanFranciscoDefeatLoPanInRingForDragon ]

        SanFranciscoEmbarkForEnclave ->
            []

        NavarroFixK9 ->
            []

        NavarroRetrieveFobForTanker ->
            []

        EnclavePersuadeControlCompanySquadToDesert ->
            []

        EnclaveKillThePresidentStealthily ->
            [ EnclaveKillThePresidentTheUsualWay ]

        EnclaveKillThePresidentTheUsualWay ->
            [ EnclaveKillThePresidentStealthily ]

        EnclaveFindTheGeck ->
            []

        EnclaveRigTurretsToTargetFrankHorrigan ->
            []

        EnclaveForceScientistToInitiateSelfDestruct ->
            []

        EnclaveKillFrankHorrigan ->
            []

        EnclaveReturnToMainland ->
            []


questRequirements : Quest -> List Quest
questRequirements quest =
    -- quests exclusive with each other all count as completed if one is completed
    case quest of
        ArroyoKillEvilPlants ->
            []

        ArroyoFixWellForFeargus ->
            []

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            []

        KlamathRustleTheBrahmin ->
            []

        KlamathKillRatGod ->
            []

        KlamathRescueTorr ->
            [ KlamathRustleTheBrahmin ]

        KlamathSearchForSmileyTrapper ->
            []

        KlamathGetFuelCellRegulator ->
            [ DenDeliverMealToSmitty ]

        ToxicCavesRescueSmileyTrapper ->
            [ KlamathSearchForSmileyTrapper ]

        ToxicCavesRepairTheGenerator ->
            []

        ToxicCavesLootTheBunker ->
            [ NewRenoAcquireElectronicLockpick ]

        DenFreeVicByPayingMetzger ->
            []

        DenFreeVicByKillingOffSlaversGuild ->
            []

        DenDeliverMealToSmitty ->
            []

        DenFixTheCar ->
            [ KlamathGetFuelCellRegulator
            , GeckoGetFuelCellControllerFromSkeeter
            ]

        ModocInvestigateGhostFarm ->
            []

        ModocRemoveInfestationInFarrelsGarden ->
            []

        ModocMediateBetweenSlagsAndJo ->
            [ ModocInvestigateGhostFarm ]

        ModocFindGoldWatchForCornelius ->
            []

        ModocFindGoldWatchForFarrel ->
            []

        VaultCityGetPlowForMrSmith ->
            []

        VaultCityRescueAmandasHusband ->
            []

        GeckoOptimizePowerPlant ->
            []

        GeckoGetFuelCellControllerFromSkeeter ->
            [ DenDeliverMealToSmitty ]

        ReddingClearWanamingoMine ->
            []

        ReddingFindExcavatorChip ->
            []

        NewRenoTrackDownPrettyBoyLloyd ->
            []

        NewRenoHelpGuardSecretTransaction ->
            []

        NewRenoCollectTributeFromCorsicanBrothers ->
            []

        NewRenoWinBoxingTournament ->
            []

        NewRenoAcquireElectronicLockpick ->
            []

        NCRGuardBrahminCaravan ->
            []

        NCRTestMutagenicSerum ->
            []

        NCRRetrieveComputerParts ->
            []

        NCRFreeSlaves ->
            []

        NCRInvestigateBrahminRaids ->
            []

        V15RescueChrissy ->
            []

        V15CompleteDealWithNCR ->
            []

        V13FixVaultComputer ->
            []

        V13FindTheGeck ->
            [ V13FixVaultComputer ]

        BrokenHillsFixMineAirPurifier ->
            []

        BrokenHillsBlowUpMineAirPurifier ->
            []

        BrokenHillsFindMissingPeople ->
            []

        BrokenHillsBeatFrancisAtArmwrestling ->
            []

        RaidersFindEvidenceOfBishopTampering ->
            []

        RaidersKillEverybody ->
            []

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            []

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            []

        SierraArmyDepotFindHumanBrainForSkynet ->
            []

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            []

        SierraArmyDepotAssembleBodyForSkynet ->
            [ SierraArmyDepotFindAbnormalBrainForSkynet
            , SierraArmyDepotFindChimpanzeeBrainForSkynet
            , SierraArmyDepotFindHumanBrainForSkynet
            , SierraArmyDepotFindCyberneticBrainForSkynet
            ]

        MilitaryBaseExcavateTheEntrance ->
            []

        MilitaryBaseKillMelchior ->
            [ MilitaryBaseExcavateTheEntrance ]

        SanFranciscoFindFuelForTanker ->
            [ SanFranciscoFindBadgersGirlfriendInsideShip ]

        SanFranciscoFindLocationOfFobForTanker ->
            [ SanFranciscoFindBadgersGirlfriendInsideShip ]

        SanFranciscoFindNavCompPartForTanker ->
            [ SanFranciscoFindBadgersGirlfriendInsideShip ]

        SanFranciscoFindVertibirdPlansForHubologists ->
            []

        SanFranciscoFindVertibirdPlansForShi ->
            []

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            []

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            []

        SanFranciscoDefeatLoPanInRingForDragon ->
            []

        SanFranciscoDefeatDragonInRingForLoPan ->
            []

        SanFranciscoEmbarkForEnclave ->
            [ SanFranciscoFindFuelForTanker
            , SanFranciscoFindNavCompPartForTanker
            , NavarroRetrieveFobForTanker
            ]

        NavarroFixK9 ->
            []

        NavarroRetrieveFobForTanker ->
            [ SanFranciscoFindLocationOfFobForTanker ]

        EnclavePersuadeControlCompanySquadToDesert ->
            []

        EnclaveKillThePresidentStealthily ->
            []

        EnclaveKillThePresidentTheUsualWay ->
            []

        EnclaveFindTheGeck ->
            []

        EnclaveRigTurretsToTargetFrankHorrigan ->
            []

        EnclaveForceScientistToInitiateSelfDestruct ->
            []

        EnclaveKillFrankHorrigan ->
            []

        EnclaveReturnToMainland ->
            [ EnclaveKillThePresidentStealthily
            , EnclaveKillThePresidentTheUsualWay
            , EnclaveForceScientistToInitiateSelfDestruct
            , EnclaveKillFrankHorrigan
            ]


locationQuestRequirements : Location -> List Quest
locationQuestRequirements loc =
    -- Some locations' quests are locked until certain quests are done
    case loc of
        Location.Arroyo ->
            []

        Location.BrokenHills ->
            []

        Location.Den ->
            []

        Location.EnclavePlatform ->
            [ SanFranciscoEmbarkForEnclave ]

        Location.Gecko ->
            []

        Location.Klamath ->
            []

        Location.MilitaryBase ->
            []

        Location.Modoc ->
            []

        Location.Navarro ->
            [ SanFranciscoFindLocationOfFobForTanker ]

        Location.NewCaliforniaRepublic ->
            []

        Location.NewReno ->
            []

        Location.Raiders ->
            [ NCRInvestigateBrahminRaids ]

        Location.Redding ->
            []

        Location.SanFrancisco ->
            []

        Location.SierraArmyDepot ->
            [ NewRenoTrackDownPrettyBoyLloyd ]

        Location.ToxicCaves ->
            [ KlamathSearchForSmileyTrapper ]

        Location.VaultCity ->
            []

        Location.Vault13 ->
            [ V15CompleteDealWithNCR ]

        Location.Vault15 ->
            [ NCRRetrieveComputerParts ]


forLocation : SeqDict Location (List Quest)
forLocation =
    List.foldl
        (\quest acc ->
            SeqDict.update
                (location quest)
                (\maybeQuests ->
                    case maybeQuests of
                        Nothing ->
                            Just [ quest ]

                        Just quests ->
                            Just <| quest :: quests
                )
                acc
        )
        SeqDict.empty
        all


allForLocation : Location -> List Quest
allForLocation loc =
    SeqDict.get loc forLocation
        |> Maybe.withDefault []


type GlobalReward
    = NewItemsInStock
        { who : Shop
        , what : ItemKind.Kind
        , amount : Int
        }
    | Discount
        { who : Shop
        , percentage : Int
        }
    | VendorAvailable Shop
    | EndTheGame


globalRewardTitle : GlobalReward -> String
globalRewardTitle reward =
    case reward of
        NewItemsInStock { who, what, amount } ->
            "{WHO} starts selling up to {AMOUNT}x {WHAT} each tick"
                |> String.replace "{WHO}" (Shop.personName who)
                |> String.replace "{AMOUNT}" (String.fromInt amount)
                |> String.replace "{WHAT}" (ItemKind.name what)

        Discount { who, percentage } ->
            "{WHO} gives a discount of {PERCENTAGE}% on all items"
                |> String.replace "{WHO}" (Shop.personName who)
                |> String.replace "{PERCENTAGE}" (String.fromInt percentage)

        VendorAvailable who ->
            "{VENDOR}'s shop becomes available in {LOCATION}"
                |> String.replace "{VENDOR}" (Shop.personName who)
                |> String.replace "{LOCATION}" (Shop.location who |> Location.name)

        EndTheGame ->
            "The game ends! Leaderboards are frozen, the winners are declared and a new world begins."


globalRewards : Quest -> List GlobalReward
globalRewards quest =
    case quest of
        ArroyoKillEvilPlants ->
            [ NewItemsInStock { who = Shop.ArroyoHakunin, what = ItemKind.HealingPowder, amount = 4 } ]

        ArroyoFixWellForFeargus ->
            []

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            [ NewItemsInStock { who = Shop.KlamathMaida, what = ItemKind.MeatJerky, amount = 4 } ]

        KlamathRustleTheBrahmin ->
            []

        KlamathKillRatGod ->
            [ Discount { who = Shop.KlamathMaida, percentage = 15 } ]

        KlamathRescueTorr ->
            [ NewItemsInStock { who = Shop.KlamathMaida, what = ItemKind.MeatJerky, amount = 4 } ]

        KlamathSearchForSmileyTrapper ->
            []

        KlamathGetFuelCellRegulator ->
            []

        ToxicCavesRescueSmileyTrapper ->
            []

        ToxicCavesRepairTheGenerator ->
            []

        ToxicCavesLootTheBunker ->
            []

        DenFreeVicByPayingMetzger ->
            [ VendorAvailable Shop.KlamathVic ]

        DenFreeVicByKillingOffSlaversGuild ->
            [ VendorAvailable Shop.KlamathVic ]

        DenDeliverMealToSmitty ->
            []

        DenFixTheCar ->
            []

        ModocInvestigateGhostFarm ->
            [ -- NewItemsInStock { who = Shop.ModocJo, what = ItemKind.CombatKnife, amount = 2 }
              -- NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Dynamite, amount = 3 }
              -- NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Mm762, amount = 10 }
              -- NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Rope, amount = 2 }
              NewItemsInStock { who = Shop.ModocJo, what = ItemKind.HuntingRifle, amount = 1 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Shotgun, amount = 1 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Pistol14mm, amount = 1 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.ShotgunShell, amount = 20 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Ap14mm, amount = 10 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Jhp10mm, amount = 20 }
            , NewItemsInStock { who = Shop.ModocJo, what = ItemKind.Stimpak, amount = 3 }
            ]

        ModocRemoveInfestationInFarrelsGarden ->
            []

        ModocMediateBetweenSlagsAndJo ->
            [ Discount { who = Shop.ModocJo, percentage = 25 } ]

        ModocFindGoldWatchForCornelius ->
            []

        ModocFindGoldWatchForFarrel ->
            []

        VaultCityGetPlowForMrSmith ->
            []

        VaultCityRescueAmandasHusband ->
            [ Discount { who = Shop.VaultCityRandal, percentage = 10 } ]

        GeckoOptimizePowerPlant ->
            [ NewItemsInStock { who = Shop.GeckoSurvivalGearPercy, what = ItemKind.SmallEnergyCell, amount = 30 } ]

        GeckoGetFuelCellControllerFromSkeeter ->
            []

        ReddingClearWanamingoMine ->
            [ Discount { who = Shop.ReddingAscorti, percentage = 15 } ]

        ReddingFindExcavatorChip ->
            []

        NewRenoTrackDownPrettyBoyLloyd ->
            []

        NewRenoHelpGuardSecretTransaction ->
            []

        NewRenoCollectTributeFromCorsicanBrothers ->
            [ -- NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.HKCaws, amount = 1 }
              -- NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.M60, amount = 1 }
              -- NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.Flamer, amount = 1 }
              NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.Bozar, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.SuperSledge, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.Minigun, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.CombatShotgun, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.RocketLauncher, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.SniperRifle, amount = 1 }
            , NewItemsInStock { who = Shop.NewRenoArmsEldridge, what = ItemKind.AssaultRifle, amount = 1 }
            ]

        NewRenoWinBoxingTournament ->
            []

        NewRenoAcquireElectronicLockpick ->
            []

        NCRGuardBrahminCaravan ->
            [ Discount { who = Shop.NCRDuppo, percentage = 5 } ]

        NCRTestMutagenicSerum ->
            []

        NCRRetrieveComputerParts ->
            []

        NCRFreeSlaves ->
            []

        NCRInvestigateBrahminRaids ->
            [ Discount { who = Shop.NCRDuppo, percentage = 10 } ]

        V15RescueChrissy ->
            []

        V15CompleteDealWithNCR ->
            [ Discount { who = Shop.NCRBuster, percentage = 10 } ]

        V13FixVaultComputer ->
            -- TODO autodoc for free for everybody
            []

        V13FindTheGeck ->
            []

        BrokenHillsFixMineAirPurifier ->
            []

        BrokenHillsBlowUpMineAirPurifier ->
            []

        BrokenHillsFindMissingPeople ->
            -- TODO maybe make Jacob hate you and give you -% discount?
            [ Discount { who = Shop.BrokenHillsGeneralStoreLiz, percentage = 10 } ]

        BrokenHillsBeatFrancisAtArmwrestling ->
            []

        RaidersFindEvidenceOfBishopTampering ->
            []

        RaidersKillEverybody ->
            -- TODO possible new clan base
            []

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            []

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            []

        SierraArmyDepotFindHumanBrainForSkynet ->
            []

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            []

        SierraArmyDepotAssembleBodyForSkynet ->
            []

        MilitaryBaseExcavateTheEntrance ->
            []

        MilitaryBaseKillMelchior ->
            []

        SanFranciscoFindFuelForTanker ->
            [ VendorAvailable Shop.SanFranciscoPunksJenna
            ]

        SanFranciscoFindLocationOfFobForTanker ->
            []

        SanFranciscoFindNavCompPartForTanker ->
            [ Discount { who = Shop.SanFranciscoPunksCal, percentage = 10 }
            , Discount { who = Shop.SanFranciscoPunksJenna, percentage = 20 }
            ]

        SanFranciscoFindVertibirdPlansForHubologists ->
            []

        SanFranciscoFindVertibirdPlansForShi ->
            []

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            []

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            [ VendorAvailable Shop.SanFranciscoPunksCal ]

        SanFranciscoDefeatLoPanInRingForDragon ->
            [ NewItemsInStock { who = Shop.SanFranciscoPunksCal, what = ItemKind.GaussRifle, amount = 1 }
            , NewItemsInStock { who = Shop.SanFranciscoPunksCal, what = ItemKind.Ec2mm, amount = 30 }
            ]

        SanFranciscoDefeatDragonInRingForLoPan ->
            [ NewItemsInStock { who = Shop.SanFranciscoPunksCal, what = ItemKind.PlasmaRifle, amount = 1 }
            , NewItemsInStock { who = Shop.SanFranciscoPunksCal, what = ItemKind.MicrofusionCell, amount = 30 }
            ]

        SanFranciscoEmbarkForEnclave ->
            []

        NavarroFixK9 ->
            []

        NavarroRetrieveFobForTanker ->
            []

        EnclavePersuadeControlCompanySquadToDesert ->
            []

        EnclaveKillThePresidentStealthily ->
            []

        EnclaveKillThePresidentTheUsualWay ->
            []

        EnclaveFindTheGeck ->
            []

        EnclaveRigTurretsToTargetFrankHorrigan ->
            []

        EnclaveForceScientistToInitiateSelfDestruct ->
            []

        EnclaveKillFrankHorrigan ->
            []

        EnclaveReturnToMainland ->
            -- TODO end the game
            []


type PlayerReward
    = ItemReward { what : ItemKind.Kind, amount : Int }
    | SkillUpgrade { skill : Skill, percentage : Int }
    | PerkReward Perk
    | CapsReward Int
    | CarReward
    | TravelToEnclaveReward


playerRewardTitle : PlayerReward -> String
playerRewardTitle reward =
    case reward of
        ItemReward { what, amount } ->
            String.fromInt amount
                ++ "x "
                ++ ItemKind.name what

        SkillUpgrade { skill, percentage } ->
            Skill.name skill
                ++ " +"
                ++ String.fromInt percentage
                ++ "%"

        PerkReward perk ->
            "Perk: " ++ Perk.name perk

        CapsReward amount ->
            "$" ++ String.fromInt amount

        CarReward ->
            "A car!"

        TravelToEnclaveReward ->
            "You travel to the Enclave. This is what you wanted, right?"


playerRewards : Quest -> { rewards : List PlayerReward, ticksNeeded : Int }
playerRewards quest =
    let
        mk rs t =
            { rewards = rs, ticksNeeded = t }
    in
    case quest of
        ArroyoKillEvilPlants ->
            mk
                [ ItemReward { what = ItemKind.ScoutHandbook, amount = 1 } ]
                5

        ArroyoFixWellForFeargus ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 5 } ]
                5

        ArroyoRescueNagorsDog ->
            mk
                [ SkillUpgrade { skill = Skill.Unarmed, percentage = 10 } ]
                5

        KlamathRefuelStill ->
            mk
                [ ItemReward { what = ItemKind.Beer, amount = 10 } ]
                5

        KlamathGuardTheBrahmin ->
            mk
                [ CapsReward 300
                , ItemReward { what = ItemKind.BrassKnuckles, amount = 2 }
                , SkillUpgrade { skill = Skill.Outdoorsman, percentage = 10 }
                ]
                5

        KlamathRustleTheBrahmin ->
            mk
                [ SkillUpgrade { skill = Skill.Sneak, percentage = 10 }
                , ItemReward { what = ItemKind.SpikedKnuckles, amount = 2 }
                , CapsReward 200
                ]
                5

        KlamathKillRatGod ->
            mk
                [ ItemReward { what = ItemKind.RedRyderLEBBGun, amount = 1 } ]
                15

        KlamathRescueTorr ->
            mk
                []
                0

        KlamathSearchForSmileyTrapper ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 5 } ]
                5

        KlamathGetFuelCellRegulator ->
            mk
                [ ItemReward { what = ItemKind.FuelCellRegulator, amount = 1 } ]
                5

        ToxicCavesRescueSmileyTrapper ->
            mk
                [ PerkReward Perk.GeckoSkinning
                , SkillUpgrade { skill = Skill.Outdoorsman, percentage = 10 }
                , CapsReward 700
                ]
                5

        ToxicCavesRepairTheGenerator ->
            mk
                [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 100 } ]
                5

        ToxicCavesLootTheBunker ->
            mk
                [ ItemReward { what = ItemKind.TeslaArmor, amount = 1 }
                , ItemReward { what = ItemKind.Bozar, amount = 1 }
                , ItemReward { what = ItemKind.Fmj223, amount = 100 }
                , CapsReward 10000
                ]
                15

        DenFreeVicByPayingMetzger ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 40 } ]
                15

        DenFreeVicByKillingOffSlaversGuild ->
            mk
                [ ItemReward { what = ItemKind.SawedOffShotgun, amount = 1 }
                , ItemReward { what = ItemKind.ShotgunShell, amount = 40 }
                , CapsReward 4000
                ]
                15

        DenDeliverMealToSmitty ->
            mk
                [ ItemReward { what = ItemKind.Tool, amount = 1 } ]
                10

        DenFixTheCar ->
            mk
                [ CarReward ]
                5

        ModocInvestigateGhostFarm ->
            mk
                []
                0

        ModocRemoveInfestationInFarrelsGarden ->
            mk
                [ ItemReward { what = ItemKind.LockPicks, amount = 1 } ]
                15

        ModocMediateBetweenSlagsAndJo ->
            mk
                [ CapsReward 5000 ]
                5

        ModocFindGoldWatchForCornelius ->
            mk
                [ ItemReward { what = ItemKind.Smg10mm, amount = 1 }
                , ItemReward { what = ItemKind.Jhp10mm, amount = 24 }
                , CapsReward 3000
                ]
                15

        ModocFindGoldWatchForFarrel ->
            mk
                [ ItemReward { what = ItemKind.SuperSledge, amount = 1 }
                , CapsReward 2000
                ]
                15

        VaultCityGetPlowForMrSmith ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 10 } ]
                10

        VaultCityRescueAmandasHusband ->
            mk
                [ CapsReward 2000 ]
                5

        GeckoOptimizePowerPlant ->
            mk
                [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 150 }
                , CapsReward 8000
                ]
                10

        GeckoGetFuelCellControllerFromSkeeter ->
            mk
                [ ItemReward { what = ItemKind.FuelCellController, amount = 1 } ]
                5

        ReddingClearWanamingoMine ->
            mk
                [ ItemReward { what = ItemKind.ScopedHuntingRifle, amount = 1 }
                , ItemReward { what = ItemKind.Fmj223, amount = 50 }
                ]
                15

        ReddingFindExcavatorChip ->
            mk
                [ ItemReward { what = ItemKind.ScoutHandbook, amount = 5 }
                , ItemReward { what = ItemKind.Mauser9mm, amount = 1 }
                , ItemReward { what = ItemKind.Mm9, amount = 300 }
                ]
                10

        NewRenoTrackDownPrettyBoyLloyd ->
            mk
                [ ItemReward { what = ItemKind.FragGrenade, amount = 20 }
                , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
                , ItemReward { what = ItemKind.Wakizashi, amount = 1 }
                , CapsReward 4000
                ]
                15

        NewRenoHelpGuardSecretTransaction ->
            mk
                [ ItemReward { what = ItemKind.SniperRifle, amount = 1 }
                , ItemReward { what = ItemKind.Fmj223, amount = 50 }
                , CapsReward 5000
                ]
                15

        NewRenoCollectTributeFromCorsicanBrothers ->
            mk
                [ ItemReward { what = ItemKind.SuperCattleProd, amount = 1 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 50 }
                , CapsReward 12000
                ]
                10

        NewRenoWinBoxingTournament ->
            mk
                [ ItemReward { what = ItemKind.PowerFist, amount = 1 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 50 }
                , ItemReward { what = ItemKind.LittleJesus, amount = 1 }
                , CapsReward 8000
                ]
                15

        NewRenoAcquireElectronicLockpick ->
            mk
                [ ItemReward { what = ItemKind.ElectronicLockpick, amount = 1 } ]
                10

        NCRGuardBrahminCaravan ->
            mk
                [ ItemReward { what = ItemKind.ExpandedAssaultRifle, amount = 1 }
                , ItemReward { what = ItemKind.Jhp5mm, amount = 50 }
                , CapsReward 4000
                ]
                15

        NCRTestMutagenicSerum ->
            mk
                [ ItemReward { what = ItemKind.BigBookOfScience, amount = 2 }
                , CapsReward 2000
                ]
                10

        NCRRetrieveComputerParts ->
            mk
                [ ItemReward { what = ItemKind.DeansElectronics, amount = 2 } ]
                15

        NCRFreeSlaves ->
            mk
                [ ItemReward { what = ItemKind.PancorJackhammer, amount = 1 }
                , ItemReward { what = ItemKind.ShotgunShell, amount = 40 }
                ]
                10

        NCRInvestigateBrahminRaids ->
            mk
                [ CapsReward 3000 ]
                5

        V15RescueChrissy ->
            mk
                [ ItemReward { what = ItemKind.HkP90c, amount = 3 }
                , ItemReward { what = ItemKind.Jhp10mm, amount = 24 }
                , CapsReward 3000
                ]
                15

        V15CompleteDealWithNCR ->
            mk
                [ ItemReward { what = ItemKind.LaserPistol, amount = 2 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 80 }
                , CapsReward 10000
                ]
                15

        V13FixVaultComputer ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 20 }
                , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
                , ItemReward { what = ItemKind.Fmj223, amount = 200 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 150 }
                ]
                15

        V13FindTheGeck ->
            mk
                [ ItemReward { what = ItemKind.GECK, amount = 1 } ]
                10

        BrokenHillsFixMineAirPurifier ->
            mk
                [ ItemReward { what = ItemKind.CombatArmor, amount = 1 }
                , CapsReward 9000
                ]
                10

        BrokenHillsBlowUpMineAirPurifier ->
            mk
                [ ItemReward { what = ItemKind.PlasmaRifle, amount = 1 }
                , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
                ]
                10

        BrokenHillsFindMissingPeople ->
            mk
                [ ItemReward { what = ItemKind.NeedlerPistol, amount = 1 }
                , ItemReward { what = ItemKind.HnNeedlerCartridge, amount = 100 }
                , CapsReward 3000
                ]
                5

        BrokenHillsBeatFrancisAtArmwrestling ->
            mk
                [ ItemReward { what = ItemKind.MegaPowerFist, amount = 1 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 40 }
                ]
                10

        RaidersFindEvidenceOfBishopTampering ->
            mk
                [ ItemReward { what = ItemKind.Stimpak, amount = 20 }
                , CapsReward 8000
                ]
                10

        RaidersKillEverybody ->
            mk
                [ ItemReward { what = ItemKind.CombatArmorMk2, amount = 3 }
                , ItemReward { what = ItemKind.ExpandedAssaultRifle, amount = 3 }
                , ItemReward { what = ItemKind.Jhp5mm, amount = 300 }
                , CapsReward 20000
                ]
                15

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            mk
                [ ItemReward { what = ItemKind.AbnormalBrain, amount = 1 } ]
                10

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            mk
                [ ItemReward { what = ItemKind.ChimpanzeeBrain, amount = 1 } ]
                10

        SierraArmyDepotFindHumanBrainForSkynet ->
            mk
                [ ItemReward { what = ItemKind.HumanBrain, amount = 1 } ]
                10

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            mk
                [ ItemReward { what = ItemKind.CyberneticBrain, amount = 1 } ]
                10

        SierraArmyDepotAssembleBodyForSkynet ->
            mk
                [ ItemReward { what = ItemKind.SkynetAim, amount = 1 } ]
                15

        MilitaryBaseExcavateTheEntrance ->
            mk
                [ ItemReward { what = ItemKind.FragGrenade, amount = 20 }
                , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
                , ItemReward { what = ItemKind.PulsePistol, amount = 1 }
                , ItemReward { what = ItemKind.SmallEnergyCell, amount = 50 }
                ]
                15

        MilitaryBaseKillMelchior ->
            mk
                [ ItemReward { what = ItemKind.GatlingLaser, amount = 1 }
                , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
                , ItemReward { what = ItemKind.RocketAp, amount = 20 }
                ]
                15

        SanFranciscoFindFuelForTanker ->
            mk
                [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 100 } ]
                15

        SanFranciscoFindLocationOfFobForTanker ->
            mk
                [ ItemReward { what = ItemKind.MotionSensor, amount = 1 } ]
                10

        SanFranciscoFindNavCompPartForTanker ->
            mk
                [ ItemReward { what = ItemKind.LaserRifleExtCap, amount = 1 }
                , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
                ]
                5

        SanFranciscoFindVertibirdPlansForHubologists ->
            mk
                [ ItemReward { what = ItemKind.TurboPlasmaRifle, amount = 1 }
                , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
                , CapsReward 20000
                ]
                15

        SanFranciscoFindVertibirdPlansForShi ->
            mk
                [ ItemReward { what = ItemKind.GaussRifle, amount = 1 }
                , ItemReward { what = ItemKind.Ec2mm, amount = 100 }
                , CapsReward 10000
                ]
                15

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            mk
                [ ItemReward { what = ItemKind.PowerArmor, amount = 1 }
                , CapsReward 5000
                ]
                15

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            mk
                [ ItemReward { what = ItemKind.GaussPistol, amount = 1 }
                , ItemReward { what = ItemKind.Ec2mm, amount = 200 }
                , CapsReward 5000
                ]
                15

        SanFranciscoDefeatLoPanInRingForDragon ->
            mk
                [ CapsReward 3000 ]
                5

        SanFranciscoDefeatDragonInRingForLoPan ->
            mk
                [ CapsReward 3000 ]
                5

        SanFranciscoEmbarkForEnclave ->
            mk
                [ TravelToEnclaveReward ]
                5

        NavarroFixK9 ->
            mk
                [ ItemReward { what = ItemKind.K9, amount = 1 } ]
                15

        NavarroRetrieveFobForTanker ->
            mk
                [ ItemReward { what = ItemKind.TankerFob, amount = 1 } ]
                5

        EnclavePersuadeControlCompanySquadToDesert ->
            mk
                [ ItemReward { what = ItemKind.PulseRifle, amount = 2 }
                , ItemReward { what = ItemKind.MicrofusionCell, amount = 100 }
                ]
                10

        EnclaveKillThePresidentStealthily ->
            mk [] 0

        EnclaveKillThePresidentTheUsualWay ->
            mk [] 0

        EnclaveFindTheGeck ->
            mk
                [ ItemReward { what = ItemKind.GECK, amount = 1 } ]
                10

        EnclaveRigTurretsToTargetFrankHorrigan ->
            mk
                [ ItemReward { what = ItemKind.GaussRifle, amount = 3 }
                , ItemReward { what = ItemKind.Ec2mm, amount = 200 }
                ]
                30

        EnclaveForceScientistToInitiateSelfDestruct ->
            mk [] 0

        EnclaveKillFrankHorrigan ->
            mk [] 0

        EnclaveReturnToMainland ->
            mk [] 0


type PlayerRequirement
    = SkillRequirement { skill : SkillRequirement, percentage : Int }
    | ItemRequirementOneOf (List ItemKind.Kind)
    | CapsRequirement Int


type SkillRequirement
    = Combat
    | Specific Skill


playerRequirementTitle : PlayerRequirement -> String
playerRequirementTitle req =
    case req of
        SkillRequirement { skill, percentage } ->
            (case skill of
                Combat ->
                    "Combat skill"

                Specific skill_ ->
                    Skill.name skill_
            )
                ++ " "
                ++ String.fromInt percentage
                ++ "%"

        ItemRequirementOneOf items ->
            case items of
                [ single ] ->
                    "Item: " ++ ItemKind.name single

                _ ->
                    "Items: " ++ String.join ", " (List.map ItemKind.name items)

        CapsRequirement amount ->
            "Caps: $" ++ String.fromInt amount


playerRequirements : Quest -> List PlayerRequirement
playerRequirements quest =
    case quest of
        ArroyoKillEvilPlants ->
            []

        ArroyoFixWellForFeargus ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 25 } ]

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            []

        KlamathRustleTheBrahmin ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 30 } ]

        KlamathKillRatGod ->
            [ SkillRequirement { skill = Combat, percentage = 60 } ]

        KlamathRescueTorr ->
            []

        KlamathSearchForSmileyTrapper ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 20 } ]

        KlamathGetFuelCellRegulator ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 30 }
            , SkillRequirement { skill = Specific Skill.Repair, percentage = 40 }
            ]

        ToxicCavesRescueSmileyTrapper ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 40 } ]

        ToxicCavesRepairTheGenerator ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 90 } ]

        ToxicCavesLootTheBunker ->
            [ SkillRequirement { skill = Combat, percentage = 120 }
            , ItemRequirementOneOf [ ItemKind.ElectronicLockpick ]
            ]

        DenFreeVicByPayingMetzger ->
            [ CapsRequirement 5000 ]

        DenFreeVicByKillingOffSlaversGuild ->
            [ SkillRequirement { skill = Combat, percentage = 70 } ]

        DenDeliverMealToSmitty ->
            []

        DenFixTheCar ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 70 } ]

        ModocInvestigateGhostFarm ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 70 } ]

        ModocRemoveInfestationInFarrelsGarden ->
            [ SkillRequirement { skill = Combat, percentage = 50 } ]

        ModocMediateBetweenSlagsAndJo ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 60 } ]

        ModocFindGoldWatchForCornelius ->
            [ SkillRequirement { skill = Specific Skill.Lockpick, percentage = 70 } ]

        ModocFindGoldWatchForFarrel ->
            [ SkillRequirement { skill = Specific Skill.Lockpick, percentage = 70 } ]

        VaultCityGetPlowForMrSmith ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 60 } ]

        VaultCityRescueAmandasHusband ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 80 } ]

        GeckoOptimizePowerPlant ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 100 } ]

        GeckoGetFuelCellControllerFromSkeeter ->
            [ ItemRequirementOneOf [ ItemKind.SuperToolKit ] ]

        ReddingClearWanamingoMine ->
            [ SkillRequirement { skill = Combat, percentage = 150 } ]

        ReddingFindExcavatorChip ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 80 } ]

        NewRenoTrackDownPrettyBoyLloyd ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 110 } ]

        NewRenoHelpGuardSecretTransaction ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 90 } ]

        NewRenoCollectTributeFromCorsicanBrothers ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 100 } ]

        NewRenoWinBoxingTournament ->
            [ SkillRequirement { skill = Specific Skill.Unarmed, percentage = 100 } ]

        NewRenoAcquireElectronicLockpick ->
            [ SkillRequirement { skill = Specific Skill.Steal, percentage = 90 } ]

        NCRGuardBrahminCaravan ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 80 } ]

        NCRTestMutagenicSerum ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 80 } ]

        NCRRetrieveComputerParts ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 120 } ]

        NCRFreeSlaves ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 110 } ]

        NCRInvestigateBrahminRaids ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 100 } ]

        V15RescueChrissy ->
            [ SkillRequirement { skill = Specific Skill.Traps, percentage = 100 } ]

        V15CompleteDealWithNCR ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 120 } ]

        V13FixVaultComputer ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 120 } ]

        V13FindTheGeck ->
            [ SkillRequirement { skill = Specific Skill.Lockpick, percentage = 150 } ]

        BrokenHillsFixMineAirPurifier ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 100 } ]

        BrokenHillsBlowUpMineAirPurifier ->
            [ SkillRequirement { skill = Specific Skill.Traps, percentage = 100 } ]

        BrokenHillsFindMissingPeople ->
            []

        BrokenHillsBeatFrancisAtArmwrestling ->
            [ SkillRequirement { skill = Specific Skill.Unarmed, percentage = 150 } ]

        RaidersFindEvidenceOfBishopTampering ->
            [ SkillRequirement { skill = Specific Skill.Traps, percentage = 130 } ]

        RaidersKillEverybody ->
            [ SkillRequirement { skill = Combat, percentage = 200 } ]

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 60 } ]

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 100 } ]

        SierraArmyDepotFindHumanBrainForSkynet ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 150 } ]

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 200 } ]

        SierraArmyDepotAssembleBodyForSkynet ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 150 }
            , ItemRequirementOneOf
                [ ItemKind.AbnormalBrain
                , ItemKind.ChimpanzeeBrain
                , ItemKind.HumanBrain
                , ItemKind.CyberneticBrain
                ]
            ]

        MilitaryBaseExcavateTheEntrance ->
            [ SkillRequirement { skill = Specific Skill.Traps, percentage = 180 } ]

        MilitaryBaseKillMelchior ->
            [ SkillRequirement { skill = Combat, percentage = 220 } ]

        SanFranciscoFindFuelForTanker ->
            [ SkillRequirement { skill = Specific Skill.Barter, percentage = 150 } ]

        SanFranciscoFindLocationOfFobForTanker ->
            [ SkillRequirement { skill = Specific Skill.Outdoorsman, percentage = 150 } ]

        SanFranciscoFindNavCompPartForTanker ->
            [ SkillRequirement { skill = Specific Skill.Lockpick, percentage = 180 } ]

        SanFranciscoFindVertibirdPlansForHubologists ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 200 } ]

        SanFranciscoFindVertibirdPlansForShi ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 200 } ]

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 200 } ]

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            [ SkillRequirement { skill = Combat, percentage = 200 } ]

        SanFranciscoDefeatLoPanInRingForDragon ->
            [ SkillRequirement { skill = Specific Skill.Unarmed, percentage = 200 } ]

        SanFranciscoDefeatDragonInRingForLoPan ->
            [ SkillRequirement { skill = Specific Skill.Unarmed, percentage = 200 } ]

        SanFranciscoEmbarkForEnclave ->
            [ ItemRequirementOneOf [ ItemKind.TankerFob ] ]

        NavarroFixK9 ->
            [ SkillRequirement { skill = Specific Skill.Repair, percentage = 200 } ]

        NavarroRetrieveFobForTanker ->
            [ SkillRequirement { skill = Specific Skill.Steal, percentage = 180 } ]

        EnclavePersuadeControlCompanySquadToDesert ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 200 } ]

        EnclaveKillThePresidentStealthily ->
            [ SkillRequirement { skill = Specific Skill.Sneak, percentage = 220 } ]

        EnclaveKillThePresidentTheUsualWay ->
            [ SkillRequirement { skill = Combat, percentage = 220 } ]

        EnclaveFindTheGeck ->
            [ SkillRequirement { skill = Specific Skill.Traps, percentage = 150 }
            , SkillRequirement { skill = Specific Skill.Sneak, percentage = 150 }
            ]

        EnclaveRigTurretsToTargetFrankHorrigan ->
            [ SkillRequirement { skill = Specific Skill.Science, percentage = 250 } ]

        EnclaveForceScientistToInitiateSelfDestruct ->
            [ SkillRequirement { skill = Specific Skill.Speech, percentage = 250 } ]

        EnclaveKillFrankHorrigan ->
            [ SkillRequirement { skill = Combat, percentage = 250 } ]

        EnclaveReturnToMainland ->
            []


codec : Codec Quest
codec =
    Codec.enum Codec.string
        [ ( "ArroyoKillEvilPlants", ArroyoKillEvilPlants )
        , ( "ArroyoFixWellForFeargus", ArroyoFixWellForFeargus )
        , ( "ArroyoRescueNagorsDog", ArroyoRescueNagorsDog )
        , ( "KlamathRefuelStill", KlamathRefuelStill )
        , ( "KlamathGuardTheBrahmin", KlamathGuardTheBrahmin )
        , ( "KlamathRustleTheBrahmin", KlamathRustleTheBrahmin )
        , ( "KlamathKillRatGod", KlamathKillRatGod )
        , ( "KlamathRescueTorr", KlamathRescueTorr )
        , ( "KlamathSearchForSmileyTrapper", KlamathSearchForSmileyTrapper )
        , ( "KlamathGetFuelCellRegulator", KlamathGetFuelCellRegulator )
        , ( "ToxicCavesRescueSmileyTrapper", ToxicCavesRescueSmileyTrapper )
        , ( "ToxicCavesRepairTheGenerator", ToxicCavesRepairTheGenerator )
        , ( "ToxicCavesLootTheBunker", ToxicCavesLootTheBunker )
        , ( "DenFreeVicByPayingMetzger", DenFreeVicByPayingMetzger )
        , ( "DenFreeVicByKillingOffSlaversGuild", DenFreeVicByKillingOffSlaversGuild )
        , ( "DenDeliverMealToSmitty", DenDeliverMealToSmitty )
        , ( "DenFixTheCar", DenFixTheCar )
        , ( "ModocInvestigateGhostFarm", ModocInvestigateGhostFarm )
        , ( "ModocRemoveInfestationInFarrelsGarden", ModocRemoveInfestationInFarrelsGarden )
        , ( "ModocMediateBetweenSlagsAndJo", ModocMediateBetweenSlagsAndJo )
        , ( "ModocFindGoldWatchForCornelius", ModocFindGoldWatchForCornelius )
        , ( "ModocFindGoldWatchForFarrel", ModocFindGoldWatchForFarrel )
        , ( "VaultCityGetPlowForMrSmith", VaultCityGetPlowForMrSmith )
        , ( "VaultCityRescueAmandasHusband", VaultCityRescueAmandasHusband )
        , ( "GeckoOptimizePowerPlant", GeckoOptimizePowerPlant )
        , ( "GeckoGetFuelCellControllerFromSkeeter", GeckoGetFuelCellControllerFromSkeeter )
        , ( "ReddingClearWanamingoMine", ReddingClearWanamingoMine )
        , ( "ReddingFindExcavatorChip", ReddingFindExcavatorChip )
        , ( "NewRenoTrackDownPrettyBoyLloyd", NewRenoTrackDownPrettyBoyLloyd )
        , ( "NewRenoHelpGuardSecretTransaction", NewRenoHelpGuardSecretTransaction )
        , ( "NewRenoCollectTributeFromCorsicanBrothers", NewRenoCollectTributeFromCorsicanBrothers )
        , ( "NewRenoWinBoxingTournament", NewRenoWinBoxingTournament )
        , ( "NewRenoAcquireElectronicLockpick", NewRenoAcquireElectronicLockpick )
        , ( "NCRGuardBrahminCaravan", NCRGuardBrahminCaravan )
        , ( "NCRTestMutagenicSerum", NCRTestMutagenicSerum )
        , ( "NCRRetrieveComputerParts", NCRRetrieveComputerParts )
        , ( "NCRFreeSlaves", NCRFreeSlaves )
        , ( "NCRInvestigateBrahminRaids", NCRInvestigateBrahminRaids )
        , ( "V15RescueChrissy", V15RescueChrissy )
        , ( "V15CompleteDealWithNCR", V15CompleteDealWithNCR )
        , ( "V13FixVaultComputer", V13FixVaultComputer )
        , ( "V13FindTheGeck", V13FindTheGeck )
        , ( "BrokenHillsFixMineAirPurifier", BrokenHillsFixMineAirPurifier )
        , ( "BrokenHillsBlowUpMineAirPurifier", BrokenHillsBlowUpMineAirPurifier )
        , ( "BrokenHillsFindMissingPeople", BrokenHillsFindMissingPeople )
        , ( "BrokenHillsBeatFrancisAtArmwrestling", BrokenHillsBeatFrancisAtArmwrestling )
        , ( "RaidersFindEvidenceOfBishopTampering", RaidersFindEvidenceOfBishopTampering )
        , ( "RaidersKillEverybody", RaidersKillEverybody )
        , ( "SierraArmyDepotFindAbnormalBrainForSkynet", SierraArmyDepotFindAbnormalBrainForSkynet )
        , ( "SierraArmyDepotFindChimpanzeeBrainForSkynet", SierraArmyDepotFindChimpanzeeBrainForSkynet )
        , ( "SierraArmyDepotFindHumanBrainForSkynet", SierraArmyDepotFindHumanBrainForSkynet )
        , ( "SierraArmyDepotFindCyberneticBrainForSkynet", SierraArmyDepotFindCyberneticBrainForSkynet )
        , ( "SierraArmyDepotAssembleBodyForSkynet", SierraArmyDepotAssembleBodyForSkynet )
        , ( "MilitaryBaseExcavateTheEntrance", MilitaryBaseExcavateTheEntrance )
        , ( "MilitaryBaseKillMelchior", MilitaryBaseKillMelchior )
        , ( "SanFranciscoFindFuelForTanker", SanFranciscoFindFuelForTanker )
        , ( "SanFranciscoFindLocationOfFobForTanker", SanFranciscoFindLocationOfFobForTanker )
        , ( "SanFranciscoFindNavCompPartForTanker", SanFranciscoFindNavCompPartForTanker )
        , ( "SanFranciscoFindVertibirdPlansForHubologists", SanFranciscoFindVertibirdPlansForHubologists )
        , ( "SanFranciscoFindVertibirdPlansForShi", SanFranciscoFindVertibirdPlansForShi )
        , ( "SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel", SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel )
        , ( "SanFranciscoFindBadgersGirlfriendInsideShip", SanFranciscoFindBadgersGirlfriendInsideShip )
        , ( "SanFranciscoDefeatLoPanInRingForDragon", SanFranciscoDefeatLoPanInRingForDragon )
        , ( "SanFranciscoDefeatDragonInRingForLoPan", SanFranciscoDefeatDragonInRingForLoPan )
        , ( "SanFranciscoEmbarkForEnclave", SanFranciscoEmbarkForEnclave )
        , ( "NavarroFixK9", NavarroFixK9 )
        , ( "NavarroRetrieveFobForTanker", NavarroRetrieveFobForTanker )
        , ( "EnclavePersuadeControlCompanySquadToDesert", EnclavePersuadeControlCompanySquadToDesert )
        , ( "EnclaveKillThePresidentStealthily", EnclaveKillThePresidentStealthily )
        , ( "EnclaveKillThePresidentTheUsualWay", EnclaveKillThePresidentTheUsualWay )
        , ( "EnclaveFindTheGeck", EnclaveFindTheGeck )
        , ( "EnclaveRigTurretsToTargetFrankHorrigan", EnclaveRigTurretsToTargetFrankHorrigan )
        , ( "EnclaveForceScientistToInitiateSelfDestruct", EnclaveForceScientistToInitiateSelfDestruct )
        , ( "EnclaveKillFrankHorrigan", EnclaveKillFrankHorrigan )
        , ( "EnclaveReturnToMainland", EnclaveReturnToMainland )
        ]


isExclusiveWith : Quest -> Quest -> Bool
isExclusiveWith quest1 quest2 =
    exclusiveWith quest1
        |> List.member quest2


playerRewardCodec : Codec PlayerReward
playerRewardCodec =
    Codec.custom
        (\itemRewardEncoder skillUpgradeEncoder perkRewardEncoder capsRewardEncoder carRewardEncoder travelToEnclaveRewardEncoder value ->
            case value of
                ItemReward arg0 ->
                    itemRewardEncoder arg0

                SkillUpgrade arg0 ->
                    skillUpgradeEncoder arg0

                PerkReward arg0 ->
                    perkRewardEncoder arg0

                CapsReward arg0 ->
                    capsRewardEncoder arg0

                CarReward ->
                    carRewardEncoder

                TravelToEnclaveReward ->
                    travelToEnclaveRewardEncoder
        )
        |> Codec.variant1
            "ItemReward"
            ItemReward
            (Codec.object (\what amount -> { what = what, amount = amount })
                |> Codec.field "what" .what ItemKind.codec
                |> Codec.field "amount" .amount Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "SkillUpgrade"
            SkillUpgrade
            (Codec.object (\skill percentage -> { skill = skill, percentage = percentage })
                |> Codec.field "skill" .skill Skill.codec
                |> Codec.field "percentage" .percentage Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1 "PerkReward" PerkReward Perk.codec
        |> Codec.variant1 "CapsReward" CapsReward Codec.int
        |> Codec.variant0 "CarReward" CarReward
        |> Codec.variant0 "TravelToEnclaveReward" TravelToEnclaveReward
        |> Codec.buildCustom


globalRewardCodec : Codec GlobalReward
globalRewardCodec =
    Codec.custom
        (\newItemsInStockEncoder discountEncoder vendorAvailableEncoder endTheGameEncoder value ->
            case value of
                NewItemsInStock arg0 ->
                    newItemsInStockEncoder arg0

                Discount arg0 ->
                    discountEncoder arg0

                VendorAvailable arg0 ->
                    vendorAvailableEncoder arg0

                EndTheGame ->
                    endTheGameEncoder
        )
        |> Codec.variant1
            "NewItemsInStock"
            NewItemsInStock
            (Codec.object (\who what amount -> { who = who, what = what, amount = amount })
                |> Codec.field "who" .who Shop.codec
                |> Codec.field "what" .what ItemKind.codec
                |> Codec.field "amount" .amount Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "Discount"
            Discount
            (Codec.object (\who percentage -> { who = who, percentage = percentage })
                |> Codec.field "who" .who Shop.codec
                |> Codec.field "percentage" .percentage Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1 "VendorAvailable" VendorAvailable Shop.codec
        |> Codec.variant0 "EndTheGame" EndTheGame
        |> Codec.buildCustom


description : Quest -> String
description quest =
    case quest of
        ArroyoKillEvilPlants ->
            """Hakunin, the village shaman, needs help with his garden. Evil
plants have taken root and are choking out his healing herbs. Clear out these
dangerous plants so he can continue making medicine for the village."""

        ArroyoFixWellForFeargus ->
            """The village well has broken down, leaving Feargus and others
without easy access to water. The rope mechanism needs repair, but the parts are
hard to come by in the primitive village. Find a way to fix it before people get
desperate."""

        ArroyoRescueNagorsDog ->
            """Young Nagor is distraught - his dog Smoke ran off into the
wilderness surrounding Arroyo. The area is dangerous, filled with hostile
wildlife. Find and rescue Smoke before something terrible happens to him."""

        KlamathRefuelStill ->
            """Whiskey Bob runs an illegal still outside of Klamath, but he's
run out of fuel. He needs someone to gather more firewood from the dangerous
gecko-infested woods nearby. The local bootlegging business depends on keeping
his still running."""

        KlamathGuardTheBrahmin ->
            """The simple-minded Torr needs help protecting his brahmin herd
from "bugmen" raiders. Stand guard over the brahmin and deal with any threats
that appear. The brahmin are Klamath's livelihood and must be protected."""

        KlamathRustleTheBrahmin ->
            """The Dunton brothers want someone to help them steal brahmin from
the dimwitted Torr. While morally questionable, it could be profitable. They
promise a good cut of the proceeds if you help drive some brahmin their way at
night."""

        KlamathKillRatGod ->
            """Deep in the rat caves beneath Trapper Town lives a massive,
mutated rat known as Keeng Ra'at. The creature and its followers terrorize the
locals and make the caves too dangerous to explore. Put an end to this "rat
god" and its cult."""

        KlamathRescueTorr ->
            """Torr has gone missing in the dangerous Klamath Canyon while
looking for "bugmen". His sister is worried sick about him. Search the canyon
and bring him back before the raiders or wildlife get to him."""

        KlamathSearchForSmileyTrapper ->
            """Smiley, one of Klamath's best trappers, hasn't returned from his
last expedition to the Toxic Caves. His fiancée Ardin Buckler is worried sick,
but the other trappers are too scared to look for him. Find out what happened
to Smiley."""

        KlamathGetFuelCellRegulator ->
            """Smitty in the Den needs a fuel cell regulator to fix the broken
Highwayman. Word is that the Toxic Caves near Klamath might have some old tech
that could work. Brave the caves and retrieve a working regulator."""

        ToxicCavesRescueSmileyTrapper ->
            """Smiley is trapped deep in the Toxic Caves, surrounded by
dangerous creatures and lethal radiation. He's managed to survive so far but
can't escape on his own. Find a way to get him out safely before it's too
late."""

        ToxicCavesRepairTheGenerator ->
            """The old military generator in the Toxic Caves could still be
valuable if repaired. The radiation and hostile creatures make it a dangerous
job, but the potential reward is significant. Find the parts needed and get it
working again."""

        ToxicCavesLootTheBunker ->
            """A pre-war military bunker lies hidden in the Toxic Caves,
possibly still containing valuable technology and supplies. The radiation and
security systems make it extremely dangerous to explore. Find a way inside and
salvage what you can."""

        DenFreeVicByPayingMetzger ->
            """Vic, a trader who might know about Vault 13, is being held by
Metzger's Slavers Guild for an unpaid debt. Metzger is willing to release him if
someone pays what he owes. Gather enough caps to buy Vic's freedom."""

        DenFreeVicByKillingOffSlaversGuild ->
            """Vic, a trader who might know about Vault 13, is being held by
Metzger's Slavers Guild in the Den. While you could pay his debt, taking down
the slavers would free not just Vic but all their captives. It's more dangerous
but could end their reign of terror permanently."""

        DenDeliverMealToSmitty ->
            """Mom, who runs the local diner, needs someone to deliver a meal to
Smitty at his garage. While a simple task, the streets of the Den are dangerous,
filled with addicts and thugs who might try to steal the food."""

        DenFixTheCar ->
            """A working Chrysalis Motors Highwayman has been discovered in the
Den. Smitty thinks he can get it running with the parts you've found, which
would make travel much easier. Help him repair this rare pre-war vehicle."""

        ModocInvestigateGhostFarm ->
            """Strange stories circulate about the "Ghost Farm" near Modoc,
where people claim to see bodies hanging from poles and mysterious figures at
night. The townspeople are terrified. Investigate the farm and uncover the truth
behind these haunting tales."""

        ModocRemoveInfestationInFarrelsGarden ->
            """Farrel's garden, vital to Modoc's food supply, has been overrun
by unusual rodents. These pests are destroying his crops and seem resistant to
normal pest control. Find a way to eliminate them before they ruin the
harvest."""

        ModocMediateBetweenSlagsAndJo ->
            """A conflict has erupted between Jo, Modoc's trader, and the
mysterious Slags living underground. Both sides are close to violence.
Investigate both claims and find a peaceful resolution before things get out of
hand."""

        ModocFindGoldWatchForCornelius ->
            """Cornelius, Modoc's tanner, has lost his prized gold pocket watch
and suspects his friend Farrel of stealing it. He's devastated by both the loss
of the cherished family heirloom and the strain it's put on their decades-long
friendship. Find the watch and discover what really happened to it."""

        ModocFindGoldWatchForFarrel ->
            """Farrel has been accused by his old friend Cornelius of stealing a
precious gold watch. Though innocent, the accusation has damaged his standing in
the community and a friendship of over thirty years. Help Farrel clear his name
and restore his relationship with Cornelius by finding the missing watch."""

        VaultCityGetPlowForMrSmith ->
            """Mr. Smith, a Vault City farmer, desperately needs a new plow for
his fields. The city's strict regulations make acquiring one difficult. Find a
way to get him a plow while navigating Vault City's bureaucracy."""

        VaultCityRescueAmandasHusband ->
            """Amanda's husband, a Vault City citizen, has been captured by
raiders while traveling. The city guards won't help due to bureaucratic
restrictions. Track him down and bring him back before it's too late."""

        GeckoOptimizePowerPlant ->
            """The atomic power plant in Gecko is running inefficiently, causing
radiation leaks that threaten both Gecko and Vault City. Find a way to optimize
the plant's systems and prevent an environmental disaster."""

        GeckoGetFuelCellControllerFromSkeeter ->
            """Skeeter, Gecko's ghoul mechanic, has a fuel cell controller that
could be useful for the Highwayman in Smitty's garage in Den. He's willing to
part with it, but he needs something in return. Make a deal with him to acquire
this valuable piece of technology."""

        ReddingClearWanamingoMine ->
            """The Wanamingo mine in Redding has been overrun by dangerous
mutant creatures. The miners can't work, and the town's economy is suffering.
Clear out the mine and make it safe for operations to resume."""

        ReddingFindExcavatorChip ->
            """The excavator in Redding's mine has broken down, and its control
chip is missing. Without it, mining operations are at a standstill. Track down
the missing chip and get the excavator working again."""

        NewRenoTrackDownPrettyBoyLloyd ->
            """Pretty Boy Lloyd has stolen money from the Wright family and fled
New Reno. The Wrights want him found and dealt with. Track him down and recover
the stolen money, but be careful - he won't give up easily."""

        NewRenoHelpGuardSecretTransaction ->
            """One of New Reno's crime families needs extra security for a
sensitive transaction. The job pays well but could be dangerous. Guard the
meeting and ensure everything goes smoothly."""

        NewRenoCollectTributeFromCorsicanBrothers ->
            """The Corsican Brothers have fallen behind on their protection
payments. Collect the overdue tribute, but be diplomatic - they're valuable
assets to the family. Find a way to get the money without burning bridges."""

        NewRenoWinBoxingTournament ->
            """The boxing ring at the Jungle Gym is holding a tournament. The
prize money is good, but the competition is fierce. Train hard and fight your
way to the championship."""

        NewRenoAcquireElectronicLockpick ->
            """An advanced electronic lockpick would be invaluable for future
missions. Word is that someone in New Reno has one. Track down this rare tool
and acquire it, legally or otherwise."""

        NCRGuardBrahminCaravan ->
            """The New California Republic needs guards for a brahmin caravan.
The route is dangerous, with raiders and hostile wildlife. Ensure the caravan
reaches its destination safely."""

        NCRTestMutagenicSerum ->
            """A scientist in NCR has developed an experimental mutagenic serum.
They need to test it on a super-mutant, but the effects are unknown and
potentially dangerous. Decide if the risk is worth the reward."""

        NCRRetrieveComputerParts ->
            """President Tandi needs specific computer parts to upgrade NCR's
systems. These parts can only be found in dangerous pre-war ruins. Retrieve them
to help modernize the republic."""

        NCRFreeSlaves ->
            """Despite NCR's anti-slavery laws, slavers still operate in the
region. A group of slaves needs help gaining their freedom. Find them and escort
them to safety while avoiding the slavers."""

        NCRInvestigateBrahminRaids ->
            """Brahmin ranchers near NCR have been hit by mysterious raids. The
attacks seem too organized to be random raiders. Investigate the true source of
these raids and put a stop to them."""

        V15RescueChrissy ->
            """Chrissy, a young woman from Vault 15, has been kidnapped by
squatters. The situation is delicate as NCR wants to maintain peace with the
squatter community. Find a way to rescue her without starting a war."""

        V15CompleteDealWithNCR ->
            """NCR and Vault 15 are negotiating a crucial deal that could
benefit both parties. Help facilitate the negotiations and ensure both sides
reach a satisfactory agreement."""

        V13FixVaultComputer ->
            """The main computer in Vault 13 has stopped responding to voice
commands, preventing Gruthar and the other deathclaw inhabitants from accessing
vital systems. A Vault-Tec voice recognition module is needed to restore
functionality."""

        V13FindTheGeck ->
            """The GECK (Garden of Eden Creation Kit) is somewhere in Vault 13.
This miraculous device could save your dying village. Search the vault and
retrieve it, but beware of the automated security systems."""

        BrokenHillsFixMineAirPurifier ->
            """The air purifier in Broken Hills' uranium mine has broken down,
endangering the miners. Without clean air, the mine will have to shut down.
Repair the system before the miners start getting sick."""

        BrokenHillsBlowUpMineAirPurifier ->
            """Some residents want to sabotage the mine's air purifier to drive
out the mutants. While morally questionable, they're offering good pay. Plant
explosives and destroy the purifier without getting caught."""

        BrokenHillsFindMissingPeople ->
            """Several people have mysteriously disappeared in Broken Hills. The
sheriff suspects foul play but has no leads. Investigate the disappearances and
uncover the dark truth behind them."""

        BrokenHillsBeatFrancisAtArmwrestling ->
            """Francis, a super mutant in Broken Hills, is the undefeated arm
wrestling champion. He's offering a substantial prize to anyone who can beat
him. Train up your strength and try to dethrone the champion."""

        RaidersFindEvidenceOfBishopTampering ->
            """There are rumors that Bishop from New Reno is manipulating the
raiders for his own benefit. Infiltrate the raiders' camp and find proof of his
involvement. The evidence could shift the balance of power in New Reno."""

        RaidersKillEverybody ->
            """The raiders have become too dangerous to ignore, attacking
travelers and settlements with increasing brutality. Put an end to their threat
by eliminating their entire base. It won't be easy - they're well-armed and
numerous."""

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            """Skynet, an AI in Sierra Army Depot, is in need of a brain for
its new body. Any brain will do. Search the facility's medical storage for a
suitable specimen. The security systems are still active, so be careful."""

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            """Skynet, an AI in Sierra Army Depot, is in need of a brain for
its new body. Just pick something human-ish, please. Search the facility's
medical storage for a suitable specimen. The security systems are still active,
so be careful."""

        SierraArmyDepotFindHumanBrainForSkynet ->
            """Skynet, an AI in Sierra Army Depot, is in need of a brain for
its new body. A human brain should be able to hold most of its vast intellect.
Search the facility's medical storage for a suitable specimen. The security
systems are still active, so be careful."""

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            """Skynet, an AI in Sierra Army Depot, is in need of a brain for
its new body. A cybernetic brain would be ideal for Skynet's consciousness
transfer. Search the facility's medical storage for a suitable specimen. The
security systems are still active, so be careful."""

        SierraArmyDepotAssembleBodyForSkynet ->
            """With a brain secured, Skynet needs a robotic body assembled.
Gather the necessary parts from throughout the facility and construct a suitable
vessel for the AI's consciousness."""

        MilitaryBaseExcavateTheEntrance ->
            """The entrance to the old military base is buried under rubble.
Clear a path inside while avoiding detection by any surviving security systems.
The base might hold vital pre-war technology."""

        MilitaryBaseKillMelchior ->
            """Melchior, a dangerous mutant with a penchant for magic tricks,
controls the FEV vats deep in the military base. He must be eliminated to
prevent the creation of more mutants. Fight your way through his guards and end
his experiments."""

        SanFranciscoFindFuelForTanker ->
            """The old tanker in San Francisco harbor needs fuel before it can
sail. Search the city for a suitable fuel source. The various factions might
have what you need, but they'll want something in return."""

        SanFranciscoFindLocationOfFobForTanker ->
            """The tanker requires a key fob to start. Someone in San Francisco
knows where to find one. Track down this information while navigating the city's
complex political landscape."""

        SanFranciscoFindNavCompPartForTanker ->
            """The tanker's navigation computer needs a crucial part to
function. Find out which technical facility to find it in, and go fetch it. Be
prepared to negotiate or fight for it."""

        SanFranciscoFindVertibirdPlansForHubologists ->
            """The Hubologists want vertibird technical plans to further their
'spiritual' goals. These plans are highly classified and heavily protected.
Acquire them without being caught by the authorities."""

        SanFranciscoFindVertibirdPlansForShi ->
            """The Shi scientists seek vertibird technical plans to advance
their research. These advanced aircraft schematics are heavily guarded in a
secure facility. Infiltrate the complex and acquire the plans while avoiding
detection."""

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            """The Brotherhood of Steel wants vertibird plans to maintain their
technological superiority. The plans are kept under heavy security in a military
installation. Break in and steal the documents while dealing with automated
defenses."""

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            """Badger's girlfriend has gone missing somewhere in the hold of the
old tanker ship. The hold is massive and filled with hostile creatures. Find and
rescue her before something terrible happens."""

        SanFranciscoDefeatLoPanInRingForDragon ->
            """Dragon wants you to defeat his rival Lo Pan in the ring to prove
Kung Fu superiority. Lo Pan is a legendary fighter with devastating techniques.
Train hard and face him in honorable combat at the arena."""

        SanFranciscoDefeatDragonInRingForLoPan ->
            """Lo Pan seeks to humiliate his rival by having you defeat Dragon
in the ring. Dragon's mastery of martial arts makes him a fearsome opponent.
Prepare yourself for an intense battle of skill and technique."""

        SanFranciscoEmbarkForEnclave ->
            """The time has come to infiltrate the Enclave's secret base using
the restored tanker. The journey will be dangerous, crossing the irradiated
waters to their offshore facility. Make your final preparations before this
point of no return."""

        NavarroFixK9 ->
            """K9, an advanced cybernetic dog, lies damaged in the Navarro base.
His systems are complex and require careful repair work. Fix this unique
companion while avoiding detection by the base's Enclave personnel."""

        NavarroRetrieveFobForTanker ->
            """The tanker's key fob is stored somewhere in the heavily-guarded
Navarro base. Enclave troops patrol every corner of the facility. Sneak in,
locate the key, and escape without raising the alarm."""

        EnclavePersuadeControlCompanySquadToDesert ->
            """A squad of Enclave soldiers might be convinced to desert their
post and help kill Frank Horrigan. Their loyalty to the Enclave isn't absolute,
but persuading them will require careful diplomacy. Find the right arguments to
sway them without arousing suspicion."""

        EnclaveKillThePresidentStealthily ->
            """The President must be eliminated, but a direct assault would be
suicide. The presidential quarters are heavily guarded by elite troops. Find a
way to assassinate him quietly without alerting the entire base."""

        EnclaveKillThePresidentTheUsualWay ->
            """The President needs to be eliminated, and subtlety isn't an
option. Fight your way through waves of elite Enclave troops to reach him. A
direct assault will be brutal - bring plenty of ammunition and medical
supplies."""

        EnclaveFindTheGeck ->
            """The GECK, vital for saving your village, is somewhere in the
Enclave base. The facility is a maze of high-security areas and deadly traps.
Navigate the complex and retrieve this crucial device before it's too late."""

        EnclaveRigTurretsToTargetFrankHorrigan ->
            """Frank Horrigan seems unstoppable, but the base's defense turrets
might help. The security control systems are heavily encrypted and complex. Hack
in and reprogram the turrets to target this seemingly invincible foe."""

        EnclaveForceScientistToInitiateSelfDestruct ->
            """Tom Murray has access to the base's self-destruct sequence. He's
heavily guarded in the science wing and won't cooperate willingly. Find him and
convince him to trigger the sequence, whether through persuasion or force."""

        EnclaveKillFrankHorrigan ->
            """Frank Horrigan, the Enclave's superhuman enforcer, stands between
you and freedom. He's the most dangerous opponent you've ever faced, augmented
with experimental technology. Survive this final confrontation and end his reign
of terror."""

        EnclaveReturnToMainland ->
            """With the Enclave defeated, you must escape their exploding oil
rig. Time is running out as the facility begins to collapse. Fight your way to
the PMV Valdez and secure transport back to the mainland."""


completionText : Quest -> String
completionText quest =
    case quest of
        ArroyoKillEvilPlants ->
            """You cleared out the toxic plants that were choking Hakunin's
healing garden. The village shaman can now grow his medicinal herbs again,
ensuring the tribe's health. Your quick action prevented the infestation from
spreading to other gardens."""

        ArroyoFixWellForFeargus ->
            """The village well is working again thanks to your repairs. Clean
water now flows freely for all of Arroyo. Feargus is especially grateful, as his
crops will survive the dry season."""

        ArroyoRescueNagorsDog ->
            """You found Smoke trapped in a cave and brought him safely back to
Nagor. The boy was overjoyed to be reunited with his faithful companion. The
village elders noted your compassion in helping even the smallest members of the
tribe."""

        KlamathRefuelStill ->
            """With fresh firewood, Whiskey Bob's still is up and running again.
The local watering holes will have a steady supply of moonshine. Bob even gave
you a few bottles of his special reserve as thanks."""

        KlamathGuardTheBrahmin ->
            """You successfully protected Torr's brahmin herd through the night.
During your watch, you discovered the "bugmen" were actually the Dunton brothers
in disguise trying to rustle cattle. Not a single brahmin was lost, and your
vigilance earned you Torr's gratitude while exposing the brothers' scheme."""

        KlamathRustleTheBrahmin ->
            """You helped the Dunton brothers steal Torr's brahmin under cover
of darkness. The simple-minded herder never knew what happened. The brothers
were pleased with your duplicity."""

        KlamathKillRatGod ->
            """The fearsome Keeng Ra'at lies dead in its lair beneath Trapper
Town. The rat population has dispersed without their leader. The grateful
trappers can now work safely again."""

        KlamathRescueTorr ->
            """You found Torr trapped in the canyon and escorted him safely back
to town. Though rattled by his encounter with the "bugmen", he survived
unharmed. His mother rewarded you generously for saving her simple-minded
son."""

        KlamathSearchForSmileyTrapper ->
            """After asking around town, you learned that Smiley was last seen
heading toward the Toxic Caves. The trail is still fresh enough to follow. His
fiancée Ardin Buckler is distraught with worry but grateful for any lead on his
whereabouts."""

        KlamathGetFuelCellRegulator ->
            """You acquired a working fuel cell regulator from an abandoned
Highwayman in Trapper Town. The part appears to be in good condition despite
its age. This crucial component will help get the car running again."""

        ToxicCavesRescueSmileyTrapper ->
            """You found Smiley trapped deep in the Toxic Caves and got him back
to Klamath safely. Though injured by a gecko bite to his leg, he'll make a full
recovery thanks to your timely rescue. Ardin Buckler was particularly grateful
to have her fiancée back."""

        ToxicCavesRepairTheGenerator ->
            """The old generator is humming smoothly again after your repairs.
Power has been restored to the ancient facility's systems, with lights
flickering back to life throughout the complex. The caves are now much safer
to navigate with the ventilation and lighting working."""

        ToxicCavesLootTheBunker ->
            """After dispatching the ancient sentry bot guarding the bunker, you
cracked open the sealed military facility and claimed its pre-war treasures.
The advanced technology and supplies will fetch a good price. Some items might
be useful to keep for yourself."""

        DenFreeVicByPayingMetzger ->
            """You paid off Vic's substantial debt to Metzger, earning the
trader his freedom. Though your wallet is much lighter, you gained a grateful
ally. Vic immediately packed his things and left the Den behind, returning to
Klamath where he reopened his trading shop."""

        DenFreeVicByKillingOffSlaversGuild ->
            """The Slaver's Guild lies in ruins, its members dead or scattered.
Vic and the other slaves have been freed from their chains. The Den is forever
changed, with a dangerous power vacuum left in the wake of the Guild's
destruction. Vic immediately packed his things and left the Den behind,
returning to Klamath where he reopened his trading shop."""

        DenDeliverMealToSmitty ->
            """You brought Mom's home-cooked meal to the grateful mechanic.
Smitty wolfed down the food, having forgotten to eat while working. Mom was
pleased to hear how much he enjoyed it. While talking, Smitty mentioned an old
Highwayman car rusting away in his junkyard - with some replacement parts, he
thinks he could get it running again for you."""

        DenFixTheCar ->
            """The Highwayman roars to life, its engine purring like new. This
working vehicle will make wasteland travel much easier. Smitty's mechanical
expertise proved invaluable in the restoration."""

        ModocInvestigateGhostFarm ->
            """You uncovered the truth about the Ghost Farm and its inhabitants.
The Slags were just trying to protect their underground home with clever tricks.
Peace was established between the surface dwellers and the Slags."""

        ModocRemoveInfestationInFarrelsGarden ->
            """The rats infesting Farrel's garden have been exterminated. His
crops are safe and can grow without being devoured. The additional food will
help Modoc's food stores last through the coming winter."""

        ModocMediateBetweenSlagsAndJo ->
            """Through careful diplomacy, you negotiated a peaceful resolution
between Jo and the Slags. Both sides agreed to trade and cooperate rather than
fight. The Ghost Farm will now help feed Modoc during hard times."""

        ModocFindGoldWatchForCornelius ->
            """You found Cornelius's cherished gold watch in the sewers behind
the Modoc outhouse toilet, guarded by a vicious mole rat. The old man was
overjoyed to have this family heirloom back and deeply regretted suspecting his
friend of theft. Their decades-long friendship was restored along with
Cornelius's faith in humanity."""

        ModocFindGoldWatchForFarrel ->
            """You found Cornelius's missing watch in the sewers behind the
Modoc outhouse toilet after defeating a nasty mole rat guard. The struggling
farmer was relieved to clear his name in front of the whole community. He
personally returned the watch to Cornelius, rekindling their friendship of over
thirty years."""

        VaultCityGetPlowForMrSmith ->
            """You obtained a working plow for Smith's farming operations. The
new equipment will greatly improve food production for people living in the slum
of Vault City courtyard. Smith was impressed by your resourcefulness in finding
such a rare item."""

        VaultCityRescueAmandasHusband ->
            """You freed Amanda's husband from his unjust imprisonment in the
Servant Allocation Center. The couple was tearfully reunited after their long
separation. They quickly left Vault City to start a new life elsewhere."""

        GeckoOptimizePowerPlant ->
            """The atomic power plant is now running at peak efficiency. Gecko
has a stable power supply, and Vault City is no longer threatened by radiation.
While both communities benefit from your technical expertise, some Vault City
citizens still grumble about having to live near a city of ghouls."""

        GeckoGetFuelCellControllerFromSkeeter ->
            """You acquired the fuel cell controller from Skeeter after finding
him a rare Super Tool Kit. The device is in perfect working condition, but the
shrewd ghoul mechanic would only trade it for this specific tool. Tracking down
the kit was challenging, but at least you got what you needed."""

        ReddingClearWanamingoMine ->
            """The Wanamingo Mine has been cleared of its monstrous inhabitants,
including the fearsome wanamingo queen and all her eggs. You made sure none
survived to threaten Redding again. The miners can now safely work the tunnels,
and the town's economy will recover now that its primary mine is operational."""

        ReddingFindExcavatorChip ->
            """You recovered the excavator control chip from the dangerous mine
tunnels. The mining machinery is operational again with the chip installed.
Redding's mining operations are back at full capacity."""

        NewRenoTrackDownPrettyBoyLloyd ->
            """You hunted down Pretty Boy Lloyd and brought him to justice. The
stolen money was recovered for the Wright family. Lloyd won't be troubling New
Reno again."""

        NewRenoHelpGuardSecretTransaction ->
            """You stood guard while the Salvatore family traded chemical
components to Enclave soldiers in exchange for advanced laser weapons. The
Salvatore guards were visibly intimidated by the power-armored troops. By
staying back and remaining silent during the tense exchange, you helped ensure
the transaction proceeded smoothly. The crime family was pleased with your
discretion."""

        NewRenoCollectTributeFromCorsicanBrothers ->
            """You successfully collected the overdue tribute from the Corsican
Brothers. They won't be late with their payments again after your visit. The
family is pleased with your persuasive methods."""

        NewRenoWinBoxingTournament ->
            """You emerged victorious from the brutal boxing tournament at the
Jungle Gym, despite one opponent fighting dirty with plated gloves and narrowly
avoiding having your ear bitten off by the Masticator. Your name is now
legendary in New Reno's fighting circuit, and the prize money and glory were
worth every bruise."""

        NewRenoAcquireElectronicLockpick ->
            """You got your hands on a sophisticated electronic lockpick. The
device will make breaking into secure areas much easier. Now to remember which
lock did you need this tool for..."""

        NCRGuardBrahminCaravan ->
            """The brahmin caravan reached its destination safely under your
protection, despite encountering remnants of the Master's Army who were
targeting a different caravan nearby. Not a single head of cattle was lost,
though you witnessed the other caravan's fierce battle with the mutant forces
from a distance. The merchants were impressed by your vigilance and relieved
that you chose a route avoiding that conflict."""

        NCRTestMutagenicSerum ->
            """The experimental serum was tested, with devastating results. The
mutant test subject died in agony from the injection, their body rejecting
the serum violently. The data gathered will advance NCR's research in an
unexpected direction. Your grim contribution to science has been noted."""

        NCRRetrieveComputerParts ->
            """You successfully retrieved the computer parts from Vault 15,
navigating the tense political situation between the squatters and NCR. Despite
the vault dwellers' initial reluctance to aid NCR, you secured the vital
components Tandi needed. NCR's systems can now be upgraded and expanded. The
president was pleased with your diplomatic approach and efficient handling of
the delicate matter."""

        NCRFreeSlaves ->
            """Through careful manipulation of the slave pen terminals, requiring
both technical knowledge and lockpicking expertise, you managed to override the
security systems and free all the captives. The Rangers were impressed by your
methodical approach to liberating the slaves without bloodshed. For your
service to their cause, the Rangers awarded you their prestigious pin and
welcomed you as one of their own. The freed slaves are now under NCR
protection, and word of your deeds has spread - NCR Rangers greet you as a
comrade, while slavers now mark you as a dangerous enemy."""

        NCRInvestigateBrahminRaids ->
            """You discovered that a pack of deathclaws was responsible for the
brahmin raids. Using your wilderness tracking skills, you followed their trail
back to their hidden lair. Westin was grateful for the intelligence about these
dangerous predators, allowing ranchers to better protect their herds and avoid
the deathclaws' hunting grounds."""

        V15RescueChrissy ->
            """You tracked Chrissy to a guarded shack in the rocky wilderness.
You dealt with the guards and navigated past traps to free her. Upon returning
her safely to Vault 15, her grateful mother arranged a meeting with the
squatters' leader, who provided access to the vault as a reward."""

        V15CompleteDealWithNCR ->
            """You delivered the good news to President Tandi - the squatters of
Vault 15 have agreed to cooperate with NCR and accept their presence. In
exchange, Zeke and his people received new housing, guaranteed access to food
and water, and protection. This historic agreement paved the way for NCR's
ambitious expansion campaign across Northern California. Both sides emerged
stronger from the deal, marking a new chapter in the region's development."""

        V13FixVaultComputer ->
            """You successfully installed the Vault-Tec voice recognition module,
restoring voice command functionality to Vault 13's main computer. Gruthar and
the other deathclaw inhabitants can once again access vital systems. Your
technical expertise has made life much easier for the vault's unusual residents.
The computer's databases are now fully accessible."""

        V13FindTheGeck ->
            """You discovered that the GECK is no longer in Vault 13. However,
you learned its current location in the Enclave's possession. The search must
continue elsewhere."""

        BrokenHillsFixMineAirPurifier ->
            """The mine's air purification system is working perfectly again.
The miners can work safely without fear of toxic fumes. Both humans and mutants
benefit from the improved air quality."""

        BrokenHillsBlowUpMineAirPurifier ->
            """The air purifier erupted in flames and shrapnel, permanently
disabled. The mine has become too dangerous for anybody to work in. Human
supremacists were pleased with your sabotage."""

        BrokenHillsFindMissingPeople ->
            """Deep in the tunnels beneath Broken Hills, you discovered the grim
truth about the missing townspeople. A trail of bodies led to a woman's corpse
and an incriminating note that revealed Francis and Zaius as the killers. You
brought this dark conspiracy to light, giving closure to grieving families.
Though the revelation shook the town's foundations, Broken Hills can finally
begin to heal from this tragedy."""

        BrokenHillsBeatFrancisAtArmwrestling ->
            """You defeated the super-mutant Francis in an epic battle of
strength and technique. He took his loss with surprising grace. Your victory
earned you respect from both humans and mutants."""

        RaidersFindEvidenceOfBishopTampering ->
            """You uncovered solid evidence of Bishop's manipulation of the
raiders. The proof of his duplicity could be politically devastating. This
information is now a powerful weapon."""

        RaidersKillEverybody ->
            """The raider base has been completely cleared of its violent
inhabitants. Their reign of terror over the region is finally over. Travelers
can now use the roads safely, and Vault City will no longer suffer from the
raiders' attacks."""

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            """You acquired an abnormal brain that meets Skynet's
specifications. Though you worry what will happen to the AI if it tries to
transfer its consciousness to it, you've fulfilled this part of its request. You
can only hope this doesn't lead to any dangerous behavioral changes."""

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            """A preserved chimpanzee brain was recovered for Skynet's use. The
primate neural structure might be compatible with its systems. The AI seems
pleased with this specimen, though the effects of using a simian brain for its
consciousness remain to be seen."""

        SierraArmyDepotFindHumanBrainForSkynet ->
            """You obtained a human brain suitable for Skynet's needs. The
ethical implications are troubling, but the AI is satisfied. The donor's
identity remains unknown."""

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            """A sophisticated cybernetic brain was recovered from the military
facility. This advanced technology is exactly what Skynet wanted. The AI can
now proceed with its plans."""

        SierraArmyDepotAssembleBodyForSkynet ->
            """Skynet's new robotic body proved unstable, its systems overloading
catastrophically. However, the AI managed to transfer its consciousness into a
nearby weapon targeting system at the last moment. Though not the mobility it
hoped for, Skynet can now assist you in combat while providing witty commentary.
The ancient intelligence seems content with this compromise."""

        MilitaryBaseExcavateTheEntrance ->
            """With a few well-placed explosives, you blasted through the debris
blocking the military base entrance. The dynamite made short work of what would
have taken weeks to dig through manually. The pre-war facility now lies open,
its secrets waiting to be uncovered."""

        MilitaryBaseKillMelchior ->
            """The mysterious Melchior lies dead in the ruins of the Vats. His
dangerous experiments have been permanently ended. The surroundings of the
military base are now a bit safer with this threat eliminated."""

        SanFranciscoFindFuelForTanker ->
            """You acquired the fuel needed for the tanker's massive engines.
The ship can now theoretically make the journey to the Enclave oil rig. One step
closer to confronting the Enclave."""

        SanFranciscoFindLocationOfFobForTanker ->
            """From A. Ron Meyers, the self-styled captain of the PMV Valdez who
deserted from Enclave ranks, you learned that the tanker's key fob is being kept
at the Navarro base. The Enclave facility won't be easy to infiltrate. At least you
know where to look now."""

        SanFranciscoFindNavCompPartForTanker ->
            """The PMV Valdez navigation computer part has been recovered and
installed. The tanker can now plot a course to the Enclave oil rig. The ancient
vessel is almost ready to sail."""

        SanFranciscoFindVertibirdPlansForHubologists ->
            """You delivered the vertibird plans to the eager Hubologists. They
believe this technology will help them reach the stars. Their gratitude is
accompanied by promises of spiritual enlightenment."""

        SanFranciscoFindVertibirdPlansForShi ->
            """The Shi scientists received the vertibird technical documents.
They immediately began analyzing the advanced technology. Their research will
advance significantly with this data."""

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            """The Brotherhood now has the vertibird technical specifications.
Their scribes are excited to study this advanced technology. The Brotherhood's
air power may soon rival the Enclave's."""

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            """You found Badger's girlfriend Suze hiding aboard the tanker. The
couple was happily reunited after their separation. Badger is now fully
committed to help you get this tanker running again."""

        SanFranciscoDefeatLoPanInRingForDragon ->
            """Lo Pan fell before your superior fighting skills in the ring.
Dragon's honor has been defended through your victory. The Shi martial arts
community respects your prowess."""

        SanFranciscoDefeatDragonInRingForLoPan ->
            """You defeated the legendary Dragon in honorable combat. Lo Pan's
reputation is restored by your victory. The balance of power has shifted in the
martial arts community."""

        SanFranciscoEmbarkForEnclave ->
            """The PMV Valdez successfully navigated the treacherous waters to
reach the Enclave oil rig. Your team endured the dangerous voyage across the
irradiated ocean. Now the real mission begins as you prepare to infiltrate the
Enclave's headquarters."""

        NavarroFixK9 ->
            """K9's systems are fully repaired and operational again. The
cyber-dog is grateful for your help restoring him. His enhanced capabilities
will be a valuable asset in hand-to-hand combat."""

        NavarroRetrieveFobForTanker ->
            """You successfully stole the tanker's key fob from the Navarro
base. The Enclave never discovered your infiltration. The tanker can now be
activated for the journey ahead and will pass the Enclave oil rig's automated
defense systems."""

        EnclavePersuadeControlCompanySquadToDesert ->
            """Through careful persuasion, you convinced the Control Company to
abandon their posts and help bring down Frank Horrigan. Their squad tactics will
be crucial in the coming battle, along with strength in numbers."""

        EnclaveKillThePresidentStealthily ->
            """The President was eliminated quietly in his quarters. No alarm
was raised by your covert operation. The Enclave leadership is in chaos
following his unexpected death."""

        EnclaveKillThePresidentTheUsualWay ->
            """You dispatched the President in a violent fashion, raising the
Enclave base alarm. The guards are now searching for you, beware."""

        EnclaveFindTheGeck ->
            """The GECK has been recovered from the Enclave's high-security
technology vault. Your village's salvation is finally within reach. The device
appears undamaged despite its age and the long journey it's had to go
through."""

        EnclaveRigTurretsToTargetFrankHorrigan ->
            """The base's defense turrets have been reprogrammed to target Frank
Horrigan. Your hacking skills proved sufficient to bypass the complex security.
The automated defenses will help even the odds against this formidable foe."""

        EnclaveForceScientistToInitiateSelfDestruct ->
            """Tom Murray activated the base's self-destruct sequence after you
revealed the President's true plans to exterminate all 'impure' humans. His
conscience couldn't bear the weight of enabling genocide. Despite the guards,
he bravely chose to help destroy the facility. The countdown has begun and
cannot be stopped - the Enclave's oil rig headquarters is doomed to
destruction."""

        EnclaveKillFrankHorrigan ->
            """The mighty Frank Horrigan has fallen in epic combat. His
cybernetically enhanced body lies split cleanly in half, the two pieces of his
massive frame scattered across the floor. The Enclave's most dangerous enforcer
will never threaten the wasteland again. Your ride's over, mutie."""

        EnclaveReturnToMainland ->
            """You escaped the exploding oil rig aboard the PMV Valdez with your
rescued people. The Enclave's headquarters vanished beneath the waves behind
you as your tribe, finally freed from their cruel experiments, celebrated their
liberation. Your mission complete, you can return together to rebuild your
home."""
