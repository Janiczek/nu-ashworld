module Data.Map.Location exposing
    ( Location(..)
    , Size(..)
    , allLocations
    , coords
    , default
    , name
    , size
    )

import Data.Map exposing (TileCoords)


default : Location
default =
    -- TODO does this cause issues? Do new players need protection from PKers?
    Arroyo


type Size
    = Large
    | Middle
    | Small


type Location
    = AbandonedHouse
    | Abbey
    | Arroyo
    | BrokenHills
    | Den
    | DenSlaveRun
    | EPA
    | EnclavePlatform
    | FakeVault13
    | Gecko
    | GhostFarm
    | Golgotha
    | HubologistStash
    | Klamath
    | KlamathSafeHouse
    | MilitaryBase
    | Modoc
    | Navarro
    | NewCaliforniaRepublic
    | NewReno
    | NewRenoSafeHouse
    | Raiders
    | Redding
    | ReddingSafeHouse
    | SanFrancisco
    | ShiSubmarine
    | SierraArmyDepot
    | SlaverCamp
    | Stables
    | ToxicCaves
    | UmbraTribe
    | Vault13
    | Vault15
    | VaultCity
    | VillageNearVaultCity


allLocations : List Location
allLocations =
    [ AbandonedHouse
    , Abbey
    , Arroyo
    , BrokenHills
    , Den
    , DenSlaveRun
    , EPA
    , EnclavePlatform
    , FakeVault13
    , Gecko
    , GhostFarm
    , Golgotha
    , HubologistStash
    , Klamath
    , KlamathSafeHouse
    , MilitaryBase
    , Modoc
    , Navarro
    , NewCaliforniaRepublic
    , NewReno
    , NewRenoSafeHouse
    , Raiders
    , Redding
    , ReddingSafeHouse
    , SanFrancisco
    , ShiSubmarine
    , SierraArmyDepot
    , SlaverCamp
    , Stables
    , ToxicCaves
    , UmbraTribe
    , Vault13
    , Vault15
    , VaultCity
    , VillageNearVaultCity
    ]


size : Location -> Size
size location =
    case location of
        Arroyo ->
            Middle

        Klamath ->
            Large

        ToxicCaves ->
            Small

        KlamathSafeHouse ->
            Small

        Den ->
            Large

        DenSlaveRun ->
            Small

        Modoc ->
            Large

        GhostFarm ->
            Small

        Abbey ->
            Middle

        Gecko ->
            Large

        VillageNearVaultCity ->
            Small

        VaultCity ->
            Large

        SlaverCamp ->
            Small

        UmbraTribe ->
            Middle

        Redding ->
            Large

        Navarro ->
            Middle

        ReddingSafeHouse ->
            Small

        Raiders ->
            Middle

        EPA ->
            Middle

        SierraArmyDepot ->
            Middle

        Stables ->
            Small

        NewReno ->
            Large

        Golgotha ->
            Small

        NewRenoSafeHouse ->
            Small

        BrokenHills ->
            Large

        FakeVault13 ->
            Small

        EnclavePlatform ->
            Large

        ShiSubmarine ->
            Small

        SanFrancisco ->
            Large

        HubologistStash ->
            Small

        AbandonedHouse ->
            Small

        MilitaryBase ->
            Large

        Vault13 ->
            Middle

        NewCaliforniaRepublic ->
            Large

        Vault15 ->
            Middle


coords : Location -> TileCoords
coords loc =
    case loc of
        Arroyo ->
            ( 3, 2 )

        Klamath ->
            ( 7, 2 )

        ToxicCaves ->
            ( 6, 1 )

        KlamathSafeHouse ->
            ( 6, 3 )

        Den ->
            ( 9, 5 )

        DenSlaveRun ->
            ( 11, 5 )

        Modoc ->
            ( 18, 5 )

        GhostFarm ->
            ( 19, 4 )

        Abbey ->
            ( 26, 0 )

        Gecko ->
            ( 25, 4 )

        VillageNearVaultCity ->
            ( 24, 5 )

        VaultCity ->
            ( 24, 6 )

        SlaverCamp ->
            ( 4, 7 )

        UmbraTribe ->
            ( 1, 10 )

        Redding ->
            ( 13, 10 )

        Navarro ->
            ( 3, 17 )

        ReddingSafeHouse ->
            ( 11, 13 )

        Raiders ->
            ( 23, 13 )

        EPA ->
            ( 12, 19 )

        SierraArmyDepot ->
            ( 18, 16 )

        Stables ->
            ( 18, 17 )

        NewReno ->
            ( 18, 18 )

        Golgotha ->
            ( 18, 19 )

        NewRenoSafeHouse ->
            ( 20, 19 )

        BrokenHills ->
            ( 23, 17 )

        FakeVault13 ->
            ( 21, 24 )

        EnclavePlatform ->
            ( 0, 26 )

        ShiSubmarine ->
            ( 8, 26 )

        SanFrancisco ->
            ( 9, 26 )

        HubologistStash ->
            ( 9, 27 )

        AbandonedHouse ->
            ( 10, 28 )

        MilitaryBase ->
            ( 13, 28 )

        Vault13 ->
            ( 19, 28 )

        NewCaliforniaRepublic ->
            ( 22, 28 )

        Vault15 ->
            ( 25, 28 )


name : Location -> String
name location =
    case location of
        AbandonedHouse ->
            "Abandoned House"

        Abbey ->
            "Abbey"

        Arroyo ->
            "Arroyo"

        BrokenHills ->
            "Broken Hills"

        Den ->
            "Den"

        DenSlaveRun ->
            "Den Slave Run"

        EPA ->
            "EPA"

        EnclavePlatform ->
            "Enclave Platform"

        FakeVault13 ->
            "Fake Vault 13"

        Gecko ->
            "Gecko"

        GhostFarm ->
            "Ghost Farm"

        Golgotha ->
            "Golgotha"

        HubologistStash ->
            "Hubologist Stash"

        Klamath ->
            "Klamath"

        KlamathSafeHouse ->
            "Safe House"

        MilitaryBase ->
            "Military Base"

        Modoc ->
            "Modoc"

        Navarro ->
            "Navarro"

        NewCaliforniaRepublic ->
            "New California Republic"

        NewReno ->
            "New Reno"

        NewRenoSafeHouse ->
            "Safe House"

        Raiders ->
            "Raiders"

        Redding ->
            "Redding"

        ReddingSafeHouse ->
            "Safe House"

        SanFrancisco ->
            "San Francisco"

        ShiSubmarine ->
            "Shi Submarine"

        SierraArmyDepot ->
            "Sierra Army Depot"

        SlaverCamp ->
            "Slaver Camp"

        Stables ->
            "Stables"

        ToxicCaves ->
            "Toxic Caves"

        UmbraTribe ->
            "Umbra Tribe"

        Vault13 ->
            "Vault 13"

        Vault15 ->
            "Vault 15"

        VaultCity ->
            "Vault City"

        VillageNearVaultCity ->
            "Village"
