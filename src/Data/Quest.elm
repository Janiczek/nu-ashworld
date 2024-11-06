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
                [ CapsReward 300 ]
                5

        KlamathRustleTheBrahmin ->
            mk
                [ SkillUpgrade { skill = Skill.Sneak, percentage = 10 }
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
                , ItemReward { what = ItemKind.Fmj223, amount = 50 }
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
                , ItemReward { what = ItemKind.Ball9mm, amount = 300 }
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
last expedition to the Toxic Caves. The other trappers are worried but too
scared to look for him. Find out what happened to Smiley."""

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
            """Cornelius, Modoc's tanner, has lost his prized gold pocket watch.
He's devastated by its loss and suspects it was stolen. Find the watch and
discover what really happened to it."""

        ModocFindGoldWatchForFarrel ->
            """Farrel claims that Cornelius stole his gold pocket watch and
wants it returned. The situation has created tension in the small town.
Investigate the conflicting claims and determine the watch's rightful owner."""

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
They need someone to test it, but the effects are unknown and potentially
dangerous. Decide if the risk is worth the reward."""

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
            """The main computer in Vault 13 has malfunctioned, locking down
vital systems. The vault's survival depends on getting it working again. Find
the problem and repair it before it's too late."""

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
