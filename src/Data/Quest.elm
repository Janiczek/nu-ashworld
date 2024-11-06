module Data.Quest exposing
    ( GlobalReward(..)
    , Name(..)
    , PlayerRequirement(..)
    , PlayerReward(..)
    , Progress
    , SkillRequirement(..)
    , all
    , allForLocation
    , codec
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


type Name
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


all : List Name
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


title : Name -> String
title name =
    case name of
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
            "Find location of FOB for the tanker"

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
            "Retrieve the FOB for the tanker"

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


ticksNeeded : Name -> Int
ticksNeeded name =
    case name of
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


xpPerTickGiven : Name -> Int
xpPerTickGiven name =
    case name of
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


location : Name -> Location
location name =
    case name of
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


exclusiveWith : Name -> List Name
exclusiveWith name =
    -- if one of these is finished, the rest cannot be done
    -- advancing one impedes the rest (moving along a n-gon?)
    case name of
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


questRequirements : Name -> List Name
questRequirements name =
    -- quests exclusive with each other all count as completed if one is completed
    case name of
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


locationQuestRequirements : Location -> List Name
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


forLocation : SeqDict Location (List Name)
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


allForLocation : Location -> List Name
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


globalRewards : Name -> List GlobalReward
globalRewards name =
    case name of
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


playerRewards : Name -> { rewards : List PlayerReward, ticksNeeded : Int }
playerRewards name =
    let
        mk rs t =
            { rewards = rs, ticksNeeded = t }
    in
    case name of
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


playerRequirements : Name -> List PlayerRequirement
playerRequirements name =
    case name of
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


codec : Codec Name
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


isExclusiveWith : Name -> Name -> Bool
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
