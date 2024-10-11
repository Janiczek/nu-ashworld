module Data.Quest exposing
    ( Engagement(..)
    , GlobalReward(..)
    , Name(..)
    , PlayerRequirement(..)
    , PlayerReward(..)
    , Progress
    , SkillRequirement(..)
    , all
    , allEngagement
    , allForLocation
    , decoder
    , encode
    , exclusiveWith
    , globalRewardTitle
    , globalRewards
    , locationQuestRequirements
    , playerRequirementTitle
    , playerRequirements
    , playerRewardTitle
    , playerRewards
    , questRequirements
    , ticksNeeded
    , ticksNeededForPlayerReward
    , title
    , xpPerTickGiven
    )

import Data.Item.Kind as ItemKind
import Data.Map.Location as Location exposing (Location)
import Data.Perk as Perk exposing (Perk(..))
import Data.Skill as Skill exposing (Skill(..))
import Data.Vendor.Shop as Shop exposing (Shop)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
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
    | ToxicCavesRescueSmileyTrapper
    | ToxicCavesRepairTheGenerator
    | ToxicCavesLootTheBunker
    | DenFreeVicByPayingMetzger
    | DenFreeVicByKillingOffSlaversGuild
    | DenDeliverMealToSmitty
    | DenFindCarParts
    | DenFixTheCar
    | ModocInvestigateGhostFarm
    | ModocRemoveInfestationInFarrelsGarden
    | ModocMediateBetweenSlagsAndJo
    | ModocFindGoldWatchForCornelius
    | ModocFindGoldWatchForFarrel
    | VaultCityGetPlowForMrSmith
    | VaultCityRescueAmandasHusband
    | GeckoOptimizePowerPlant
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
    , ToxicCavesRescueSmileyTrapper
    , ToxicCavesRepairTheGenerator
    , ToxicCavesLootTheBunker
    , DenFreeVicByPayingMetzger
    , DenFreeVicByKillingOffSlaversGuild
    , DenDeliverMealToSmitty
    , DenFindCarParts
    , DenFixTheCar
    , ModocInvestigateGhostFarm
    , ModocRemoveInfestationInFarrelsGarden
    , ModocMediateBetweenSlagsAndJo
    , ModocFindGoldWatchForCornelius
    , ModocFindGoldWatchForFarrel
    , VaultCityGetPlowForMrSmith
    , VaultCityRescueAmandasHusband
    , GeckoOptimizePowerPlant
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
    }


type Engagement
    = NotProgressing
    | ProgressingSlowly
    | Progressing


allEngagement : List Engagement
allEngagement =
    [ NotProgressing
    , ProgressingSlowly
    , Progressing
    ]


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

        DenFindCarParts ->
            "Find replacement car parts for Smitty"

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

        DenFindCarParts ->
            300

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

        DenFindCarParts ->
            150

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

        DenFindCarParts ->
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

        DenFindCarParts ->
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

        DenFindCarParts ->
            []

        DenFixTheCar ->
            [ DenFindCarParts ]

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
    -- Some locations are locked until certain quests are done
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
    = SellsGuaranteed
        { who : Shop
        , what : ItemKind.Kind
        , amount : Int
        }
    | Discount
        { who : Shop
        , percentage : Int
        }
    | VendorAvailable Shop


globalRewardTitle : GlobalReward -> String
globalRewardTitle reward =
    case reward of
        SellsGuaranteed { who, what, amount } ->
            "{WHO} sells guaranteed {AMOUNT}x {WHAT} each tick"
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


globalRewards : Name -> List GlobalReward
globalRewards name =
    case name of
        ArroyoKillEvilPlants ->
            [ SellsGuaranteed { who = Shop.ArroyoHakunin, what = ItemKind.HealingPowder, amount = 4 } ]

        ArroyoFixWellForFeargus ->
            []

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            [ SellsGuaranteed { who = Shop.KlamathMaida, what = ItemKind.MeatJerky, amount = 4 } ]

        KlamathRustleTheBrahmin ->
            []

        KlamathKillRatGod ->
            [ Discount { who = Shop.KlamathMaida, percentage = 15 } ]

        KlamathRescueTorr ->
            [ SellsGuaranteed { who = Shop.KlamathMaida, what = ItemKind.MeatJerky, amount = 4 } ]

        KlamathSearchForSmileyTrapper ->
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

        DenFindCarParts ->
            []

        DenFixTheCar ->
            []

        ModocInvestigateGhostFarm ->
            []

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
            [ SellsGuaranteed { who = Shop.GeckoSurvivalGearPercy, what = ItemKind.SmallEnergyCell, amount = 30 } ]

        ReddingClearWanamingoMine ->
            [ Discount { who = Shop.ReddingAscorti, percentage = 15 } ]

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
            [ SellsGuaranteed { who = Shop.SanFranciscoPunksCal, what = ItemKind.GaussRifle, amount = 1 }
            , SellsGuaranteed { who = Shop.SanFranciscoPunksCal, what = ItemKind.Ec2mm, amount = 30 }
            ]

        SanFranciscoDefeatDragonInRingForLoPan ->
            [ SellsGuaranteed { who = Shop.SanFranciscoPunksCal, what = ItemKind.PlasmaRifle, amount = 1 }
            , SellsGuaranteed { who = Shop.SanFranciscoPunksCal, what = ItemKind.MicrofusionCell, amount = 30 }
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
    | CarReward


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

        CarReward ->
            "A car!"


playerRewards : Name -> List PlayerReward
playerRewards name =
    case name of
        ArroyoKillEvilPlants ->
            [ ItemReward { what = ItemKind.ScoutHandbook, amount = 1 } ]

        ArroyoFixWellForFeargus ->
            [ ItemReward { what = ItemKind.Stimpak, amount = 5 } ]

        ArroyoRescueNagorsDog ->
            [ SkillUpgrade { skill = Unarmed, percentage = 10 } ]

        KlamathRefuelStill ->
            [ ItemReward { what = ItemKind.Beer, amount = 10 } ]

        KlamathGuardTheBrahmin ->
            []

        KlamathRustleTheBrahmin ->
            [ SkillUpgrade { skill = Sneak, percentage = 10 } ]

        KlamathKillRatGod ->
            [ ItemReward { what = ItemKind.RedRyderLEBBGun, amount = 1 } ]

        KlamathRescueTorr ->
            []

        KlamathSearchForSmileyTrapper ->
            [ ItemReward { what = ItemKind.Stimpak, amount = 5 } ]

        ToxicCavesRescueSmileyTrapper ->
            [ PerkReward GeckoSkinning ]

        ToxicCavesRepairTheGenerator ->
            [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 100 } ]

        ToxicCavesLootTheBunker ->
            [ ItemReward { what = ItemKind.TeslaArmor, amount = 1 }
            , ItemReward { what = ItemKind.Bozar, amount = 1 }
            , ItemReward { what = ItemKind.Fmj223, amount = 50 }
            ]

        DenFreeVicByPayingMetzger ->
            [ ItemReward { what = ItemKind.SawedOffShotgun, amount = 1 }
            , ItemReward { what = ItemKind.ShotgunShell, amount = 40 }
            ]

        DenFreeVicByKillingOffSlaversGuild ->
            [ ItemReward { what = ItemKind.SawedOffShotgun, amount = 1 }
            , ItemReward { what = ItemKind.ShotgunShell, amount = 40 }
            ]

        DenDeliverMealToSmitty ->
            [ ItemReward { what = ItemKind.Tool, amount = 1 } ]

        DenFindCarParts ->
            [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 60 } ]

        DenFixTheCar ->
            [ CarReward ]

        ModocInvestigateGhostFarm ->
            []

        ModocRemoveInfestationInFarrelsGarden ->
            [ ItemReward { what = ItemKind.LockPicks, amount = 1 } ]

        ModocMediateBetweenSlagsAndJo ->
            []

        ModocFindGoldWatchForCornelius ->
            [ ItemReward { what = ItemKind.Smg10mm, amount = 1 }
            , ItemReward { what = ItemKind.Jhp10mm, amount = 24 }
            ]

        ModocFindGoldWatchForFarrel ->
            [ ItemReward { what = ItemKind.SuperSledge, amount = 1 } ]

        VaultCityGetPlowForMrSmith ->
            [ ItemReward { what = ItemKind.Stimpak, amount = 10 } ]

        VaultCityRescueAmandasHusband ->
            []

        GeckoOptimizePowerPlant ->
            [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 150 } ]

        ReddingClearWanamingoMine ->
            [ ItemReward { what = ItemKind.ScopedHuntingRifle, amount = 1 }
            , ItemReward { what = ItemKind.Fmj223, amount = 50 }
            ]

        ReddingFindExcavatorChip ->
            [ ItemReward { what = ItemKind.ScoutHandbook, amount = 5 } ]

        NewRenoTrackDownPrettyBoyLloyd ->
            [ ItemReward { what = ItemKind.FragGrenade, amount = 20 }
            , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
            ]

        NewRenoHelpGuardSecretTransaction ->
            [ ItemReward { what = ItemKind.SniperRifle, amount = 1 }
            , ItemReward { what = ItemKind.Fmj223, amount = 50 }
            ]

        NewRenoCollectTributeFromCorsicanBrothers ->
            []

        NewRenoWinBoxingTournament ->
            [ ItemReward { what = ItemKind.PowerFist, amount = 1 }
            , ItemReward { what = ItemKind.SmallEnergyCell, amount = 50 }
            ]

        NewRenoAcquireElectronicLockpick ->
            [ ItemReward { what = ItemKind.ElectronicLockpick, amount = 1 } ]

        NCRGuardBrahminCaravan ->
            [ ItemReward { what = ItemKind.ExpandedAssaultRifle, amount = 1 }
            , ItemReward { what = ItemKind.Jhp5mm, amount = 50 }
            ]

        NCRTestMutagenicSerum ->
            [ ItemReward { what = ItemKind.BigBookOfScience, amount = 2 } ]

        NCRRetrieveComputerParts ->
            [ ItemReward { what = ItemKind.DeansElectronics, amount = 2 } ]

        NCRFreeSlaves ->
            [ ItemReward { what = ItemKind.PancorJackhammer, amount = 1 }
            , ItemReward { what = ItemKind.ShotgunShell, amount = 40 }
            ]

        NCRInvestigateBrahminRaids ->
            []

        V15RescueChrissy ->
            [ ItemReward { what = ItemKind.HkP90c, amount = 3 }
            , ItemReward { what = ItemKind.Jhp10mm, amount = 24 }
            ]

        V15CompleteDealWithNCR ->
            [ ItemReward { what = ItemKind.LaserPistol, amount = 2 }
            , ItemReward { what = ItemKind.SmallEnergyCell, amount = 80 }
            ]

        V13FixVaultComputer ->
            [ ItemReward { what = ItemKind.Stimpak, amount = 20 }
            , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
            , ItemReward { what = ItemKind.Fmj223, amount = 200 }
            , ItemReward { what = ItemKind.SmallEnergyCell, amount = 150 }
            ]

        V13FindTheGeck ->
            [ ItemReward { what = ItemKind.GECK, amount = 1 } ]

        BrokenHillsFixMineAirPurifier ->
            [ ItemReward { what = ItemKind.CombatArmor, amount = 1 } ]

        BrokenHillsBlowUpMineAirPurifier ->
            [ ItemReward { what = ItemKind.PlasmaRifle, amount = 1 }
            , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
            ]

        BrokenHillsFindMissingPeople ->
            []

        BrokenHillsBeatFrancisAtArmwrestling ->
            [ ItemReward { what = ItemKind.MegaPowerFist, amount = 1 }
            , ItemReward { what = ItemKind.SmallEnergyCell, amount = 40 }
            ]

        RaidersFindEvidenceOfBishopTampering ->
            [ ItemReward { what = ItemKind.Stimpak, amount = 20 } ]

        RaidersKillEverybody ->
            [ ItemReward { what = ItemKind.CombatArmorMk2, amount = 1 }
            , ItemReward { what = ItemKind.ExpandedAssaultRifle, amount = 1 }
            , ItemReward { what = ItemKind.Jhp5mm, amount = 50 }
            ]

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            [ ItemReward { what = ItemKind.AbnormalBrain, amount = 1 } ]

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            [ ItemReward { what = ItemKind.ChimpanzeeBrain, amount = 1 } ]

        SierraArmyDepotFindHumanBrainForSkynet ->
            [ ItemReward { what = ItemKind.HumanBrain, amount = 1 } ]

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            [ ItemReward { what = ItemKind.CyberneticBrain, amount = 1 } ]

        SierraArmyDepotAssembleBodyForSkynet ->
            [ ItemReward { what = ItemKind.SkynetAim, amount = 1 } ]

        MilitaryBaseExcavateTheEntrance ->
            [ ItemReward { what = ItemKind.FragGrenade, amount = 20 }
            , ItemReward { what = ItemKind.SuperStimpak, amount = 10 }
            ]

        MilitaryBaseKillMelchior ->
            [ ItemReward { what = ItemKind.GatlingLaser, amount = 1 }
            , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
            ]

        SanFranciscoFindFuelForTanker ->
            [ ItemReward { what = ItemKind.SmallEnergyCell, amount = 100 } ]

        SanFranciscoFindLocationOfFobForTanker ->
            [ ItemReward { what = ItemKind.MotionSensor, amount = 1 } ]

        SanFranciscoFindNavCompPartForTanker ->
            []

        SanFranciscoFindVertibirdPlansForHubologists ->
            [ ItemReward { what = ItemKind.TurboPlasmaRifle, amount = 1 }
            , ItemReward { what = ItemKind.MicrofusionCell, amount = 50 }
            ]

        SanFranciscoFindVertibirdPlansForShi ->
            [ ItemReward { what = ItemKind.GaussRifle, amount = 1 }
            , ItemReward { what = ItemKind.Ec2mm, amount = 100 }
            ]

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            [ ItemReward { what = ItemKind.PowerArmor, amount = 1 } ]

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            [ ItemReward { what = ItemKind.GaussPistol, amount = 1 }
            , ItemReward { what = ItemKind.Ec2mm, amount = 200 }
            ]

        SanFranciscoDefeatLoPanInRingForDragon ->
            []

        SanFranciscoDefeatDragonInRingForLoPan ->
            []

        SanFranciscoEmbarkForEnclave ->
            []

        NavarroFixK9 ->
            [ ItemReward { what = ItemKind.K9, amount = 1 } ]

        NavarroRetrieveFobForTanker ->
            []

        EnclavePersuadeControlCompanySquadToDesert ->
            [ ItemReward { what = ItemKind.PulseRifle, amount = 2 }
            , ItemReward { what = ItemKind.MicrofusionCell, amount = 100 }
            ]

        EnclaveKillThePresidentStealthily ->
            []

        EnclaveKillThePresidentTheUsualWay ->
            []

        EnclaveFindTheGeck ->
            [ ItemReward { what = ItemKind.GECK, amount = 1 } ]

        EnclaveRigTurretsToTargetFrankHorrigan ->
            [ ItemReward { what = ItemKind.GaussRifle, amount = 3 }
            , ItemReward { what = ItemKind.Ec2mm, amount = 200 }
            ]

        EnclaveForceScientistToInitiateSelfDestruct ->
            []

        EnclaveKillFrankHorrigan ->
            []

        EnclaveReturnToMainland ->
            []


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
            [ SkillRequirement { skill = Specific Repair, percentage = 25 } ]

        ArroyoRescueNagorsDog ->
            []

        KlamathRefuelStill ->
            []

        KlamathGuardTheBrahmin ->
            []

        KlamathRustleTheBrahmin ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 30 } ]

        KlamathKillRatGod ->
            [ SkillRequirement { skill = Combat, percentage = 60 } ]

        KlamathRescueTorr ->
            []

        KlamathSearchForSmileyTrapper ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 20 } ]

        ToxicCavesRescueSmileyTrapper ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 40 } ]

        ToxicCavesRepairTheGenerator ->
            [ SkillRequirement { skill = Specific Repair, percentage = 90 } ]

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

        DenFindCarParts ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 50 } ]

        DenFixTheCar ->
            [ SkillRequirement { skill = Specific Repair, percentage = 70 } ]

        ModocInvestigateGhostFarm ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 70 } ]

        ModocRemoveInfestationInFarrelsGarden ->
            [ SkillRequirement { skill = Combat, percentage = 50 } ]

        ModocMediateBetweenSlagsAndJo ->
            [ SkillRequirement { skill = Specific Speech, percentage = 60 } ]

        ModocFindGoldWatchForCornelius ->
            [ SkillRequirement { skill = Specific Lockpick, percentage = 70 } ]

        ModocFindGoldWatchForFarrel ->
            [ SkillRequirement { skill = Specific Lockpick, percentage = 70 } ]

        VaultCityGetPlowForMrSmith ->
            [ SkillRequirement { skill = Specific Science, percentage = 60 } ]

        VaultCityRescueAmandasHusband ->
            [ SkillRequirement { skill = Specific Speech, percentage = 80 } ]

        GeckoOptimizePowerPlant ->
            [ SkillRequirement { skill = Specific Science, percentage = 100 } ]

        ReddingClearWanamingoMine ->
            [ SkillRequirement { skill = Combat, percentage = 150 } ]

        ReddingFindExcavatorChip ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 80 } ]

        NewRenoTrackDownPrettyBoyLloyd ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 110 } ]

        NewRenoHelpGuardSecretTransaction ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 90 } ]

        NewRenoCollectTributeFromCorsicanBrothers ->
            [ SkillRequirement { skill = Specific Speech, percentage = 100 } ]

        NewRenoWinBoxingTournament ->
            [ SkillRequirement { skill = Specific Unarmed, percentage = 100 } ]

        NewRenoAcquireElectronicLockpick ->
            [ SkillRequirement { skill = Specific Steal, percentage = 90 } ]

        NCRGuardBrahminCaravan ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 80 } ]

        NCRTestMutagenicSerum ->
            [ SkillRequirement { skill = Specific Science, percentage = 80 } ]

        NCRRetrieveComputerParts ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 120 } ]

        NCRFreeSlaves ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 110 } ]

        NCRInvestigateBrahminRaids ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 100 } ]

        V15RescueChrissy ->
            [ SkillRequirement { skill = Specific Traps, percentage = 100 } ]

        V15CompleteDealWithNCR ->
            [ SkillRequirement { skill = Specific Speech, percentage = 120 } ]

        V13FixVaultComputer ->
            [ SkillRequirement { skill = Specific Repair, percentage = 120 } ]

        V13FindTheGeck ->
            [ SkillRequirement { skill = Specific Lockpick, percentage = 150 } ]

        BrokenHillsFixMineAirPurifier ->
            [ SkillRequirement { skill = Specific Repair, percentage = 100 } ]

        BrokenHillsBlowUpMineAirPurifier ->
            [ SkillRequirement { skill = Specific Traps, percentage = 100 } ]

        BrokenHillsFindMissingPeople ->
            []

        BrokenHillsBeatFrancisAtArmwrestling ->
            [ SkillRequirement { skill = Specific Unarmed, percentage = 150 } ]

        RaidersFindEvidenceOfBishopTampering ->
            [ SkillRequirement { skill = Specific Traps, percentage = 130 } ]

        RaidersKillEverybody ->
            [ SkillRequirement { skill = Combat, percentage = 200 } ]

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            [ SkillRequirement { skill = Specific Science, percentage = 60 } ]

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            [ SkillRequirement { skill = Specific Science, percentage = 100 } ]

        SierraArmyDepotFindHumanBrainForSkynet ->
            [ SkillRequirement { skill = Specific Science, percentage = 150 } ]

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            [ SkillRequirement { skill = Specific Science, percentage = 200 } ]

        SierraArmyDepotAssembleBodyForSkynet ->
            [ SkillRequirement { skill = Specific Repair, percentage = 150 }
            , ItemRequirementOneOf
                [ ItemKind.AbnormalBrain
                , ItemKind.ChimpanzeeBrain
                , ItemKind.HumanBrain
                , ItemKind.CyberneticBrain
                ]
            ]

        MilitaryBaseExcavateTheEntrance ->
            [ SkillRequirement { skill = Specific Traps, percentage = 180 } ]

        MilitaryBaseKillMelchior ->
            [ SkillRequirement { skill = Combat, percentage = 220 } ]

        SanFranciscoFindFuelForTanker ->
            [ SkillRequirement { skill = Specific Barter, percentage = 150 } ]

        SanFranciscoFindLocationOfFobForTanker ->
            [ SkillRequirement { skill = Specific Outdoorsman, percentage = 150 } ]

        SanFranciscoFindNavCompPartForTanker ->
            [ SkillRequirement { skill = Specific Lockpick, percentage = 180 } ]

        SanFranciscoFindVertibirdPlansForHubologists ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 200 } ]

        SanFranciscoFindVertibirdPlansForShi ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 200 } ]

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 200 } ]

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            [ SkillRequirement { skill = Combat, percentage = 200 } ]

        SanFranciscoDefeatLoPanInRingForDragon ->
            [ SkillRequirement { skill = Specific Unarmed, percentage = 200 } ]

        SanFranciscoDefeatDragonInRingForLoPan ->
            [ SkillRequirement { skill = Specific Unarmed, percentage = 200 } ]

        SanFranciscoEmbarkForEnclave ->
            []

        NavarroFixK9 ->
            [ SkillRequirement { skill = Specific Repair, percentage = 200 } ]

        NavarroRetrieveFobForTanker ->
            [ SkillRequirement { skill = Specific Steal, percentage = 180 } ]

        EnclavePersuadeControlCompanySquadToDesert ->
            [ SkillRequirement { skill = Specific Speech, percentage = 200 } ]

        EnclaveKillThePresidentStealthily ->
            [ SkillRequirement { skill = Specific Sneak, percentage = 220 } ]

        EnclaveKillThePresidentTheUsualWay ->
            [ SkillRequirement { skill = Combat, percentage = 220 } ]

        EnclaveFindTheGeck ->
            [ SkillRequirement { skill = Specific Traps, percentage = 150 }
            , SkillRequirement { skill = Specific Sneak, percentage = 150 }
            ]

        EnclaveRigTurretsToTargetFrankHorrigan ->
            [ SkillRequirement { skill = Specific Science, percentage = 250 } ]

        EnclaveForceScientistToInitiateSelfDestruct ->
            [ SkillRequirement { skill = Specific Speech, percentage = 250 } ]

        EnclaveKillFrankHorrigan ->
            [ SkillRequirement { skill = Combat, percentage = 250 } ]

        EnclaveReturnToMainland ->
            []


ticksNeededForPlayerReward : Name -> Int
ticksNeededForPlayerReward name =
    case name of
        ArroyoKillEvilPlants ->
            5

        ArroyoFixWellForFeargus ->
            4

        ArroyoRescueNagorsDog ->
            4

        KlamathRefuelStill ->
            5

        KlamathGuardTheBrahmin ->
            0

        KlamathRustleTheBrahmin ->
            4

        KlamathKillRatGod ->
            15

        KlamathRescueTorr ->
            0

        KlamathSearchForSmileyTrapper ->
            4

        ToxicCavesRescueSmileyTrapper ->
            5

        ToxicCavesRepairTheGenerator ->
            5

        ToxicCavesLootTheBunker ->
            20

        DenFreeVicByPayingMetzger ->
            20

        DenFreeVicByKillingOffSlaversGuild ->
            20

        DenDeliverMealToSmitty ->
            10

        DenFindCarParts ->
            20

        DenFixTheCar ->
            5

        ModocInvestigateGhostFarm ->
            0

        ModocRemoveInfestationInFarrelsGarden ->
            15

        ModocMediateBetweenSlagsAndJo ->
            0

        ModocFindGoldWatchForCornelius ->
            15

        ModocFindGoldWatchForFarrel ->
            15

        VaultCityGetPlowForMrSmith ->
            10

        VaultCityRescueAmandasHusband ->
            0

        GeckoOptimizePowerPlant ->
            10

        ReddingClearWanamingoMine ->
            20

        ReddingFindExcavatorChip ->
            10

        NewRenoTrackDownPrettyBoyLloyd ->
            20

        NewRenoHelpGuardSecretTransaction ->
            15

        NewRenoCollectTributeFromCorsicanBrothers ->
            0

        NewRenoWinBoxingTournament ->
            30

        NewRenoAcquireElectronicLockpick ->
            10

        NCRGuardBrahminCaravan ->
            15

        NCRTestMutagenicSerum ->
            10

        NCRRetrieveComputerParts ->
            15

        NCRFreeSlaves ->
            10

        NCRInvestigateBrahminRaids ->
            0

        V15RescueChrissy ->
            20

        V15CompleteDealWithNCR ->
            20

        V13FixVaultComputer ->
            15

        V13FindTheGeck ->
            10

        BrokenHillsFixMineAirPurifier ->
            10

        BrokenHillsBlowUpMineAirPurifier ->
            10

        BrokenHillsFindMissingPeople ->
            0

        BrokenHillsBeatFrancisAtArmwrestling ->
            10

        RaidersFindEvidenceOfBishopTampering ->
            10

        RaidersKillEverybody ->
            20

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            10

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            10

        SierraArmyDepotFindHumanBrainForSkynet ->
            10

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            10

        SierraArmyDepotAssembleBodyForSkynet ->
            20

        MilitaryBaseExcavateTheEntrance ->
            20

        MilitaryBaseKillMelchior ->
            15

        SanFranciscoFindFuelForTanker ->
            20

        SanFranciscoFindLocationOfFobForTanker ->
            10

        SanFranciscoFindNavCompPartForTanker ->
            0

        SanFranciscoFindVertibirdPlansForHubologists ->
            30

        SanFranciscoFindVertibirdPlansForShi ->
            30

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            30

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            20

        SanFranciscoDefeatLoPanInRingForDragon ->
            0

        SanFranciscoDefeatDragonInRingForLoPan ->
            0

        SanFranciscoEmbarkForEnclave ->
            0

        NavarroFixK9 ->
            30

        NavarroRetrieveFobForTanker ->
            0

        EnclavePersuadeControlCompanySquadToDesert ->
            10

        EnclaveKillThePresidentStealthily ->
            0

        EnclaveKillThePresidentTheUsualWay ->
            0

        EnclaveFindTheGeck ->
            10

        EnclaveRigTurretsToTargetFrankHorrigan ->
            30

        EnclaveForceScientistToInitiateSelfDestruct ->
            0

        EnclaveKillFrankHorrigan ->
            0

        EnclaveReturnToMainland ->
            0


encode : Name -> JE.Value
encode name =
    JE.string <|
        case name of
            ArroyoKillEvilPlants ->
                "ArroyoKillEvilPlants"

            ArroyoFixWellForFeargus ->
                "ArroyoFixWellForFeargus"

            ArroyoRescueNagorsDog ->
                "ArroyoRescueNagorsDog"

            KlamathRefuelStill ->
                "KlamathRefuelStill"

            KlamathGuardTheBrahmin ->
                "KlamathGuardTheBrahmin"

            KlamathRustleTheBrahmin ->
                "KlamathRustleTheBrahmin"

            KlamathKillRatGod ->
                "KlamathKillRatGod"

            KlamathRescueTorr ->
                "KlamathRescueTorr"

            KlamathSearchForSmileyTrapper ->
                "KlamathSearchForSmileyTrapper"

            ToxicCavesRescueSmileyTrapper ->
                "ToxicCavesRescueSmileyTrapper"

            ToxicCavesRepairTheGenerator ->
                "ToxicCavesRepairTheGenerator"

            ToxicCavesLootTheBunker ->
                "ToxicCavesLootTheBunker"

            DenFreeVicByPayingMetzger ->
                "DenFreeVicByPayingMetzger"

            DenFreeVicByKillingOffSlaversGuild ->
                "DenFreeVicByKillingOffSlaversGuild"

            DenDeliverMealToSmitty ->
                "DenDeliverMealToSmitty"

            DenFindCarParts ->
                "DenFindCarParts"

            DenFixTheCar ->
                "DenFixTheCar"

            ModocInvestigateGhostFarm ->
                "ModocInvestigateGhostFarm"

            ModocRemoveInfestationInFarrelsGarden ->
                "ModocRemoveInfestationInFarrelsGarden"

            ModocMediateBetweenSlagsAndJo ->
                "ModocMediateBetweenSlagsAndJo"

            ModocFindGoldWatchForCornelius ->
                "ModocFindGoldWatchForCornelius"

            ModocFindGoldWatchForFarrel ->
                "ModocFindGoldWatchForFarrel"

            VaultCityGetPlowForMrSmith ->
                "VaultCityGetPlowForMrSmith"

            VaultCityRescueAmandasHusband ->
                "VaultCityRescueAmandasHusband"

            GeckoOptimizePowerPlant ->
                "GeckoOptimizePowerPlant"

            ReddingClearWanamingoMine ->
                "ReddingClearWanamingoMine"

            ReddingFindExcavatorChip ->
                "ReddingFindExcavatorChip"

            NewRenoTrackDownPrettyBoyLloyd ->
                "NewRenoTrackDownPrettyBoyLloyd"

            NewRenoHelpGuardSecretTransaction ->
                "NewRenoHelpGuardSecretTransaction"

            NewRenoCollectTributeFromCorsicanBrothers ->
                "NewRenoCollectTributeFromCorsicanBrothers"

            NewRenoWinBoxingTournament ->
                "NewRenoWinBoxingTournament"

            NewRenoAcquireElectronicLockpick ->
                "NewRenoAcquireElectronicLockpick"

            NCRGuardBrahminCaravan ->
                "NCRGuardBrahminCaravan"

            NCRTestMutagenicSerum ->
                "NCRTestMutagenicSerum"

            NCRRetrieveComputerParts ->
                "NCRRetrieveComputerParts"

            NCRFreeSlaves ->
                "NCRFreeSlaves"

            NCRInvestigateBrahminRaids ->
                "NCRInvestigateBrahminRaids"

            V15RescueChrissy ->
                "V15RescueChrissy"

            V15CompleteDealWithNCR ->
                "V15CompleteDealWithNCR"

            V13FixVaultComputer ->
                "V13FixVaultComputer"

            V13FindTheGeck ->
                "V13FindTheGeck"

            BrokenHillsFixMineAirPurifier ->
                "BrokenHillsFixMineAirPurifier"

            BrokenHillsBlowUpMineAirPurifier ->
                "BrokenHillsBlowUpMineAirPurifier"

            BrokenHillsFindMissingPeople ->
                "BrokenHillsFindMissingPeople"

            BrokenHillsBeatFrancisAtArmwrestling ->
                "BrokenHillsBeatFrancisAtArmwrestling"

            RaidersFindEvidenceOfBishopTampering ->
                "RaidersFindEvidenceOfBishopTampering"

            RaidersKillEverybody ->
                "RaidersKillEverybody"

            SierraArmyDepotFindAbnormalBrainForSkynet ->
                "SierraArmyDepotFindAbnormalBrainForSkynet"

            SierraArmyDepotFindChimpanzeeBrainForSkynet ->
                "SierraArmyDepotFindChimpanzeeBrainForSkynet"

            SierraArmyDepotFindHumanBrainForSkynet ->
                "SierraArmyDepotFindHumanBrainForSkynet"

            SierraArmyDepotFindCyberneticBrainForSkynet ->
                "SierraArmyDepotFindCyberneticBrainForSkynet"

            SierraArmyDepotAssembleBodyForSkynet ->
                "SierraArmyDepotAssembleBodyForSkynet"

            MilitaryBaseExcavateTheEntrance ->
                "MilitaryBaseExcavateTheEntrance"

            MilitaryBaseKillMelchior ->
                "MilitaryBaseKillMelchior"

            SanFranciscoFindFuelForTanker ->
                "SanFranciscoFindFuelForTanker"

            SanFranciscoFindLocationOfFobForTanker ->
                "SanFranciscoFindLocationOfFobForTanker"

            SanFranciscoFindNavCompPartForTanker ->
                "SanFranciscoFindNavCompPartForTanker"

            SanFranciscoFindVertibirdPlansForHubologists ->
                "SanFranciscoFindVertibirdPlansForHubologists"

            SanFranciscoFindVertibirdPlansForShi ->
                "SanFranciscoFindVertibirdPlansForShi"

            SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
                "SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel"

            SanFranciscoFindBadgersGirlfriendInsideShip ->
                "SanFranciscoFindBadgersGirlfriendInsideShip"

            SanFranciscoDefeatLoPanInRingForDragon ->
                "SanFranciscoDefeatLoPanInRingForDragon"

            SanFranciscoDefeatDragonInRingForLoPan ->
                "SanFranciscoDefeatDragonInRingForLoPan"

            SanFranciscoEmbarkForEnclave ->
                "SanFranciscoEmbarkForEnclave"

            NavarroFixK9 ->
                "NavarroFixK9"

            NavarroRetrieveFobForTanker ->
                "NavarroRetrieveFobForTanker"

            EnclavePersuadeControlCompanySquadToDesert ->
                "EnclavePersuadeControlCompanySquadToDesert"

            EnclaveKillThePresidentStealthily ->
                "EnclaveKillThePresidentStealthily"

            EnclaveKillThePresidentTheUsualWay ->
                "EnclaveKillThePresidentTheUsualWay"

            EnclaveFindTheGeck ->
                "EnclaveFindTheGeck"

            EnclaveRigTurretsToTargetFrankHorrigan ->
                "EnclaveRigTurretsToTargetFrankHorrigan"

            EnclaveForceScientistToInitiateSelfDestruct ->
                "EnclaveForceScientistToInitiateSelfDestruct"

            EnclaveKillFrankHorrigan ->
                "EnclaveKillFrankHorrigan"

            EnclaveReturnToMainland ->
                "EnclaveReturnToMainland"


decoder : Decoder Name
decoder =
    JD.string
        |> JD.andThen
            (\string ->
                case string of
                    "ArroyoKillEvilPlants" ->
                        JD.succeed ArroyoKillEvilPlants

                    "ArroyoFixWellForFeargus" ->
                        JD.succeed ArroyoFixWellForFeargus

                    "ArroyoRescueNagorsDog" ->
                        JD.succeed ArroyoRescueNagorsDog

                    "KlamathRefuelStill" ->
                        JD.succeed KlamathRefuelStill

                    "KlamathGuardTheBrahmin" ->
                        JD.succeed KlamathGuardTheBrahmin

                    "KlamathRustleTheBrahmin" ->
                        JD.succeed KlamathRustleTheBrahmin

                    "KlamathKillRatGod" ->
                        JD.succeed KlamathKillRatGod

                    "KlamathRescueTorr" ->
                        JD.succeed KlamathRescueTorr

                    "KlamathSearchForSmileyTrapper" ->
                        JD.succeed KlamathSearchForSmileyTrapper

                    "ToxicCavesRescueSmileyTrapper" ->
                        JD.succeed ToxicCavesRescueSmileyTrapper

                    "ToxicCavesRepairTheGenerator" ->
                        JD.succeed ToxicCavesRepairTheGenerator

                    "ToxicCavesLootTheBunker" ->
                        JD.succeed ToxicCavesLootTheBunker

                    "DenFreeVicByPayingMetzger" ->
                        JD.succeed DenFreeVicByPayingMetzger

                    "DenFreeVicByKillingOffSlaversGuild" ->
                        JD.succeed DenFreeVicByKillingOffSlaversGuild

                    "DenDeliverMealToSmitty" ->
                        JD.succeed DenDeliverMealToSmitty

                    "DenFindCarParts" ->
                        JD.succeed DenFindCarParts

                    "DenFixTheCar" ->
                        JD.succeed DenFixTheCar

                    "ModocInvestigateGhostFarm" ->
                        JD.succeed ModocInvestigateGhostFarm

                    "ModocRemoveInfestationInFarrelsGarden" ->
                        JD.succeed ModocRemoveInfestationInFarrelsGarden

                    "ModocMediateBetweenSlagsAndJo" ->
                        JD.succeed ModocMediateBetweenSlagsAndJo

                    "ModocFindGoldWatchForCornelius" ->
                        JD.succeed ModocFindGoldWatchForCornelius

                    "ModocFindGoldWatchForFarrel" ->
                        JD.succeed ModocFindGoldWatchForFarrel

                    "VaultCityGetPlowForMrSmith" ->
                        JD.succeed VaultCityGetPlowForMrSmith

                    "VaultCityRescueAmandasHusband" ->
                        JD.succeed VaultCityRescueAmandasHusband

                    "GeckoOptimizePowerPlant" ->
                        JD.succeed GeckoOptimizePowerPlant

                    "ReddingClearWanamingoMine" ->
                        JD.succeed ReddingClearWanamingoMine

                    "ReddingFindExcavatorChip" ->
                        JD.succeed ReddingFindExcavatorChip

                    "NewRenoTrackDownPrettyBoyLloyd" ->
                        JD.succeed NewRenoTrackDownPrettyBoyLloyd

                    "NewRenoHelpGuardSecretTransaction" ->
                        JD.succeed NewRenoHelpGuardSecretTransaction

                    "NewRenoCollectTributeFromCorsicanBrothers" ->
                        JD.succeed NewRenoCollectTributeFromCorsicanBrothers

                    "NewRenoWinBoxingTournament" ->
                        JD.succeed NewRenoWinBoxingTournament

                    "NewRenoAcquireElectronicLockpick" ->
                        JD.succeed NewRenoAcquireElectronicLockpick

                    "NCRGuardBrahminCaravan" ->
                        JD.succeed NCRGuardBrahminCaravan

                    "NCRTestMutagenicSerum" ->
                        JD.succeed NCRTestMutagenicSerum

                    "NCRRetrieveComputerParts" ->
                        JD.succeed NCRRetrieveComputerParts

                    "NCRFreeSlaves" ->
                        JD.succeed NCRFreeSlaves

                    "NCRInvestigateBrahminRaids" ->
                        JD.succeed NCRInvestigateBrahminRaids

                    "V15RescueChrissy" ->
                        JD.succeed V15RescueChrissy

                    "V15CompleteDealWithNCR" ->
                        JD.succeed V15CompleteDealWithNCR

                    "V13FixVaultComputer" ->
                        JD.succeed V13FixVaultComputer

                    "V13FindTheGeck" ->
                        JD.succeed V13FindTheGeck

                    "BrokenHillsFixMineAirPurifier" ->
                        JD.succeed BrokenHillsFixMineAirPurifier

                    "BrokenHillsBlowUpMineAirPurifier" ->
                        JD.succeed BrokenHillsBlowUpMineAirPurifier

                    "BrokenHillsFindMissingPeople" ->
                        JD.succeed BrokenHillsFindMissingPeople

                    "BrokenHillsBeatFrancisAtArmwrestling" ->
                        JD.succeed BrokenHillsBeatFrancisAtArmwrestling

                    "RaidersFindEvidenceOfBishopTampering" ->
                        JD.succeed RaidersFindEvidenceOfBishopTampering

                    "RaidersKillEverybody" ->
                        JD.succeed RaidersKillEverybody

                    "SierraArmyDepotFindAbnormalBrainForSkynet" ->
                        JD.succeed SierraArmyDepotFindAbnormalBrainForSkynet

                    "SierraArmyDepotFindChimpanzeeBrainForSkynet" ->
                        JD.succeed SierraArmyDepotFindChimpanzeeBrainForSkynet

                    "SierraArmyDepotFindHumanBrainForSkynet" ->
                        JD.succeed SierraArmyDepotFindHumanBrainForSkynet

                    "SierraArmyDepotFindCyberneticBrainForSkynet" ->
                        JD.succeed SierraArmyDepotFindCyberneticBrainForSkynet

                    "SierraArmyDepotAssembleBodyForSkynet" ->
                        JD.succeed SierraArmyDepotAssembleBodyForSkynet

                    "MilitaryBaseExcavateTheEntrance" ->
                        JD.succeed MilitaryBaseExcavateTheEntrance

                    "MilitaryBaseKillMelchior" ->
                        JD.succeed MilitaryBaseKillMelchior

                    "SanFranciscoFindFuelForTanker" ->
                        JD.succeed SanFranciscoFindFuelForTanker

                    "SanFranciscoFindLocationOfFobForTanker" ->
                        JD.succeed SanFranciscoFindLocationOfFobForTanker

                    "SanFranciscoFindNavCompPartForTanker" ->
                        JD.succeed SanFranciscoFindNavCompPartForTanker

                    "SanFranciscoFindVertibirdPlansForHubologists" ->
                        JD.succeed SanFranciscoFindVertibirdPlansForHubologists

                    "SanFranciscoFindVertibirdPlansForShi" ->
                        JD.succeed SanFranciscoFindVertibirdPlansForShi

                    "SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel" ->
                        JD.succeed SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel

                    "SanFranciscoFindBadgersGirlfriendInsideShip" ->
                        JD.succeed SanFranciscoFindBadgersGirlfriendInsideShip

                    "SanFranciscoDefeatLoPanInRingForDragon" ->
                        JD.succeed SanFranciscoDefeatLoPanInRingForDragon

                    "SanFranciscoDefeatDragonInRingForLoPan" ->
                        JD.succeed SanFranciscoDefeatDragonInRingForLoPan

                    "SanFranciscoEmbarkForEnclave" ->
                        JD.succeed SanFranciscoEmbarkForEnclave

                    "NavarroFixK9" ->
                        JD.succeed NavarroFixK9

                    "NavarroRetrieveFobForTanker" ->
                        JD.succeed NavarroRetrieveFobForTanker

                    "EnclavePersuadeControlCompanySquadToDesert" ->
                        JD.succeed EnclavePersuadeControlCompanySquadToDesert

                    "EnclaveKillThePresidentStealthily" ->
                        JD.succeed EnclaveKillThePresidentStealthily

                    "EnclaveKillThePresidentTheUsualWay" ->
                        JD.succeed EnclaveKillThePresidentTheUsualWay

                    "EnclaveFindTheGeck" ->
                        JD.succeed EnclaveFindTheGeck

                    "EnclaveRigTurretsToTargetFrankHorrigan" ->
                        JD.succeed EnclaveRigTurretsToTargetFrankHorrigan

                    "EnclaveForceScientistToInitiateSelfDestruct" ->
                        JD.succeed EnclaveForceScientistToInitiateSelfDestruct

                    "EnclaveKillFrankHorrigan" ->
                        JD.succeed EnclaveKillFrankHorrigan

                    "EnclaveReturnToMainland" ->
                        JD.succeed EnclaveReturnToMainland

                    _ ->
                        JD.fail <| "Unknown quest name: '" ++ string ++ "'"
            )
