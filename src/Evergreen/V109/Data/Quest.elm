module Evergreen.V109.Data.Quest exposing (..)


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


type alias Progress =
    { playersActive : Int
    , ticksPerHour : Int
    , ticksGiven : Int
    , ticksGivenByPlayer : Int
    }
