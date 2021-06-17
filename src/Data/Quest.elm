module Data.Quest exposing
    ( GlobalReward(..)
    , Name(..)
    , PlayerRequirement(..)
    , PlayerReward(..)
    , Quest
    , all
    , allForLocation
    , decoder
    , exclusiveWith
    , globalRewardTitle
    , globalRewards
    , location
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

import AssocList as Dict_
import Data.Item as Item exposing (Kind(..))
import Data.Map.Location exposing (Location(..))
import Data.Skill as Skill exposing (Skill(..))
import Data.Special as Special
import Data.Vendor as Vendor exposing (Name(..))
import Json.Decode as JD exposing (Decoder)


type alias Quest =
    { name : Name
    , ticksGiven : Int
    }


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

        _ ->
            Debug.todo <| "Data.Quest.ticksNeeded " ++ Debug.toString name


xpPerTickGiven : Name -> Int
xpPerTickGiven name =
    case name of
        ArroyoKillEvilPlants ->
            50

        ArroyoFixWellForFeargus ->
            100

        ArroyoRescueNagorsDog ->
            75

        _ ->
            Debug.todo <| "Data.Quest.xpPerTickGiven " ++ Debug.toString name


location : Name -> Location
location name =
    case name of
        ArroyoKillEvilPlants ->
            Arroyo

        ArroyoFixWellForFeargus ->
            Arroyo

        ArroyoRescueNagorsDog ->
            Arroyo

        KlamathRefuelStill ->
            Klamath

        KlamathGuardTheBrahmin ->
            Klamath

        KlamathRustleTheBrahmin ->
            Klamath

        KlamathKillRatGod ->
            Klamath

        KlamathRescueTorr ->
            Klamath

        KlamathSearchForSmileyTrapper ->
            Klamath

        ToxicCavesRescueSmileyTrapper ->
            ToxicCaves

        ToxicCavesRepairTheGenerator ->
            ToxicCaves

        ToxicCavesLootTheBunker ->
            ToxicCaves

        DenFreeVicByPayingMetzger ->
            Den

        DenFreeVicByKillingOffSlaversGuild ->
            Den

        DenDeliverMealToSmitty ->
            Den

        DenFindCarParts ->
            Den

        DenFixTheCar ->
            Den

        ModocInvestigateGhostFarm ->
            Modoc

        ModocRemoveInfestationInFarrelsGarden ->
            Modoc

        ModocMediateBetweenSlagsAndJo ->
            Modoc

        ModocFindGoldWatchForCornelius ->
            Modoc

        ModocFindGoldWatchForFarrel ->
            Modoc

        VaultCityGetPlowForMrSmith ->
            VaultCity

        VaultCityRescueAmandasHusband ->
            VaultCity

        GeckoOptimizePowerPlant ->
            Gecko

        ReddingClearWanamingoMine ->
            Redding

        ReddingFindExcavatorChip ->
            Redding

        NewRenoTrackDownPrettyBoyLloyd ->
            NewReno

        NewRenoHelpGuardSecretTransaction ->
            NewReno

        NewRenoCollectTributeFromCorsicanBrothers ->
            NewReno

        NewRenoWinBoxingTournament ->
            NewReno

        NewRenoAcquireElectronicLockpick ->
            NewReno

        NCRGuardBrahminCaravan ->
            NewCaliforniaRepublic

        NCRTestMutagenicSerum ->
            NewCaliforniaRepublic

        NCRRetrieveComputerParts ->
            NewCaliforniaRepublic

        NCRFreeSlaves ->
            NewCaliforniaRepublic

        NCRInvestigateBrahminRaids ->
            NewCaliforniaRepublic

        V15RescueChrissy ->
            Vault15

        V15CompleteDealWithNCR ->
            Vault15

        V13FixVaultComputer ->
            Vault13

        V13FindTheGeck ->
            Vault13

        BrokenHillsFixMineAirPurifier ->
            BrokenHills

        BrokenHillsBlowUpMineAirPurifier ->
            BrokenHills

        BrokenHillsFindMissingPeople ->
            BrokenHills

        BrokenHillsBeatFrancisAtArmwrestling ->
            BrokenHills

        RaidersFindEvidenceOfBishopTampering ->
            Raiders

        RaidersKillEverybody ->
            Raiders

        SierraArmyDepotFindAbnormalBrainForSkynet ->
            SierraArmyDepot

        SierraArmyDepotFindChimpanzeeBrainForSkynet ->
            SierraArmyDepot

        SierraArmyDepotFindHumanBrainForSkynet ->
            SierraArmyDepot

        SierraArmyDepotFindCyberneticBrainForSkynet ->
            SierraArmyDepot

        SierraArmyDepotAssembleBodyForSkynet ->
            SierraArmyDepot

        MilitaryBaseExcavateTheEntrance ->
            MilitaryBase

        MilitaryBaseKillMelchior ->
            MilitaryBase

        SanFranciscoFindFuelForTanker ->
            SanFrancisco

        SanFranciscoFindLocationOfFobForTanker ->
            SanFrancisco

        SanFranciscoFindNavCompPartForTanker ->
            SanFrancisco

        SanFranciscoFindVertibirdPlansForHubologists ->
            SanFrancisco

        SanFranciscoFindVertibirdPlansForShi ->
            SanFrancisco

        SanFranciscoFindVertibirdPlansForBrotherhoodOfSteel ->
            SanFrancisco

        SanFranciscoFindBadgersGirlfriendInsideShip ->
            SanFrancisco

        SanFranciscoDefeatLoPanInRingForDragon ->
            SanFrancisco

        SanFranciscoDefeatDragonInRingForLoPan ->
            SanFrancisco

        SanFranciscoEmbarkForEnclave ->
            SanFrancisco

        NavarroFixK9 ->
            Navarro

        NavarroRetrieveFobForTanker ->
            Navarro

        EnclavePersuadeControlCompanySquadToDesert ->
            EnclavePlatform

        EnclaveKillThePresidentStealthily ->
            EnclavePlatform

        EnclaveKillThePresidentTheUsualWay ->
            EnclavePlatform

        EnclaveFindTheGeck ->
            EnclavePlatform

        EnclaveRigTurretsToTargetFrankHorrigan ->
            EnclavePlatform

        EnclaveForceScientistToInitiateSelfDestruct ->
            EnclavePlatform

        EnclaveKillFrankHorrigan ->
            EnclavePlatform

        EnclaveReturnToMainland ->
            EnclavePlatform


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
        Arroyo ->
            []

        BrokenHills ->
            []

        Den ->
            []

        EnclavePlatform ->
            [ SanFranciscoEmbarkForEnclave ]

        Gecko ->
            []

        Klamath ->
            []

        MilitaryBase ->
            []

        Modoc ->
            []

        Navarro ->
            [ SanFranciscoFindLocationOfFobForTanker ]

        NewCaliforniaRepublic ->
            []

        NewReno ->
            []

        Raiders ->
            [ NCRInvestigateBrahminRaids ]

        Redding ->
            []

        SanFrancisco ->
            []

        SierraArmyDepot ->
            [ NewRenoTrackDownPrettyBoyLloyd ]

        ToxicCaves ->
            [ KlamathSearchForSmileyTrapper ]

        VaultCity ->
            []

        Vault13 ->
            [ V15CompleteDealWithNCR ]

        Vault15 ->
            [ NCRRetrieveComputerParts ]


forLocation : Dict_.Dict Location (List Name)
forLocation =
    List.foldl
        (\quest acc ->
            Dict_.update
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
        Dict_.empty
        all


allForLocation : Location -> List Name
allForLocation loc =
    Dict_.get loc forLocation
        |> Maybe.withDefault []


type GlobalReward
    = SellsGuaranteed
        { who : Vendor.Name
        , what : Item.Kind
        , amount : Int
        }


globalRewardTitle : GlobalReward -> String
globalRewardTitle reward =
    case reward of
        SellsGuaranteed { who, what, amount } ->
            Vendor.name who
                ++ " sells guaranteed "
                ++ String.fromInt amount
                ++ "x "
                ++ Item.name what
                ++ " each tick"


globalRewards : Name -> List GlobalReward
globalRewards name =
    case name of
        ArroyoKillEvilPlants ->
            [ SellsGuaranteed { who = ArroyoHakunin, what = HealingPowder, amount = 4 }
            ]

        ArroyoFixWellForFeargus ->
            []

        ArroyoRescueNagorsDog ->
            []

        _ ->
            Debug.todo <| "Data.Quest.globalRewards " ++ Debug.toString name


type PlayerReward
    = ItemReward { what : Item.Kind, amount : Int }
    | SkillUpgrade { skill : Skill, percentage : Int }


playerRewardTitle : PlayerReward -> String
playerRewardTitle reward =
    case reward of
        ItemReward { what, amount } ->
            String.fromInt amount
                ++ "x "
                ++ Item.name what

        SkillUpgrade { skill, percentage } ->
            Skill.name skill
                ++ " +"
                ++ String.fromInt percentage
                ++ "%"


playerRewards : Name -> List PlayerReward
playerRewards name =
    case name of
        ArroyoKillEvilPlants ->
            [ ItemReward { what = ScoutHandbook, amount = 1 }
            ]

        ArroyoFixWellForFeargus ->
            [ ItemReward { what = Stimpak, amount = 5 }
            ]

        ArroyoRescueNagorsDog ->
            [ SkillUpgrade { skill = Unarmed, percentage = 10 }
            ]

        _ ->
            Debug.todo <| "Data.Quest.playerRewards " ++ Debug.toString name


type PlayerRequirement
    = SkillRequirement { skill : Skill, percentage : Int }
    | SpecialRequirement { attribute : Special.Type, value : Int }


playerRequirementTitle : PlayerRequirement -> String
playerRequirementTitle req =
    case req of
        SkillRequirement { skill, percentage } ->
            Skill.name skill ++ " " ++ String.fromInt percentage ++ "%"

        SpecialRequirement { attribute, value } ->
            Special.label attribute ++ " " ++ String.fromInt value


playerRequirements : Name -> List PlayerRequirement
playerRequirements name =
    case name of
        ArroyoKillEvilPlants ->
            []

        ArroyoFixWellForFeargus ->
            [ SkillRequirement { skill = Repair, percentage = 25 }
            ]

        ArroyoRescueNagorsDog ->
            []

        _ ->
            Debug.todo <| "Data.Quest.playerRequirements " ++ Debug.toString name


ticksNeededForPlayerReward : Name -> Int
ticksNeededForPlayerReward name =
    case name of
        ArroyoKillEvilPlants ->
            5

        ArroyoFixWellForFeargus ->
            4

        ArroyoRescueNagorsDog ->
            4

        _ ->
            Debug.todo <| "Data.Quest.ticksNeededForPlayerReward " ++ Debug.toString name


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
