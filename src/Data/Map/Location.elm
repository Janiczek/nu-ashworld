module Data.Map.Location exposing
    ( Location(..)
    , Size(..)
    , allLocations
    , coords
    , default
    , enclave
    , location
    , name
    , size
    )

import Data.Map exposing (TileCoords)
import Dict exposing (Dict)


default : Location
default =
    Arroyo


type Size
    = Large
    | Middle
    | Small


type Location
    = Arroyo
      --| AbandonedHouse
      --| Abbey
      --| DenSlaveRun
      --| EPA
      --| FakeVault13
      --| GhostFarm
      --| Golgotha
      --| HubologistStash
      --| KlamathSafeHouse
      --| NewRenoSafeHouse
      --| ReddingSafeHouse
      --| ShiSubmarine
      --| SlaverCamp
      --| Stables
      --| UmbraTribe
      --| VillageNearVaultCity
    | BrokenHills
    | Den
    | EnclavePlatform
    | Gecko
    | Klamath
    | MilitaryBase
    | Modoc
    | Navarro
    | NewCaliforniaRepublic
    | NewReno
    | Raiders
    | Redding
    | SanFrancisco
    | SierraArmyDepot
    | ToxicCaves
    | Vault13
    | Vault15
    | VaultCity


allLocations : List Location
allLocations =
    [ Arroyo

    --, AbandonedHouse
    --, Abbey
    --, DenSlaveRun
    --, EPA
    --, FakeVault13
    --, GhostFarm
    --, Golgotha
    --, HubologistStash
    --, KlamathSafeHouse
    --, NewRenoSafeHouse
    --, ReddingSafeHouse
    --, ShiSubmarine
    --, SlaverCamp
    --, Stables
    --, UmbraTribe
    --, VillageNearVaultCity
    , BrokenHills
    , Den
    , EnclavePlatform
    , Gecko
    , Klamath
    , MilitaryBase
    , Modoc
    , Navarro
    , NewCaliforniaRepublic
    , NewReno
    , Raiders
    , Redding
    , SanFrancisco
    , SierraArmyDepot
    , ToxicCaves
    , VaultCity
    , Vault13
    , Vault15
    ]


size : Location -> Size
size loc =
    case loc of
        --AbandonedHouse -> Small
        --Abbey -> Middle
        --DenSlaveRun -> Small
        --EPA -> Middle
        --FakeVault13 -> Small
        --GhostFarm -> Small
        --Golgotha -> Small
        --HubologistStash -> Small
        --KlamathSafeHouse -> Small
        --NewRenoSafeHouse -> Small
        --ReddingSafeHouse -> Small
        --ShiSubmarine -> Small
        --SlaverCamp -> Small
        --Stables -> Small
        --UmbraTribe -> Middle
        --VillageNearVaultCity -> Small
        Arroyo ->
            Middle

        BrokenHills ->
            Large

        Den ->
            Large

        EnclavePlatform ->
            Large

        Gecko ->
            Large

        Klamath ->
            Large

        MilitaryBase ->
            Large

        Modoc ->
            Large

        Navarro ->
            Middle

        Vault13 ->
            Middle

        Vault15 ->
            Middle

        NewCaliforniaRepublic ->
            Large

        NewReno ->
            Large

        Raiders ->
            Middle

        Redding ->
            Large

        SanFrancisco ->
            Large

        SierraArmyDepot ->
            Middle

        ToxicCaves ->
            Small

        VaultCity ->
            Large


coords : Location -> TileCoords
coords loc =
    case loc of
        --AbandonedHouse -> ( 10, 28 )
        --Abbey -> ( 26, 0 )
        --DenSlaveRun -> ( 11, 5 )
        --EPA -> ( 12, 19 )
        --FakeVault13 -> ( 21, 24 )
        --GhostFarm -> ( 19, 4 )
        --Golgotha -> ( 18, 19 )
        --HubologistStash -> ( 9, 27 )
        --KlamathSafeHouse -> ( 6, 3 )
        --NewRenoSafeHouse -> ( 20, 19 )
        --ReddingSafeHouse -> ( 11, 13 )
        --ShiSubmarine -> ( 8, 26 )
        --SlaverCamp -> ( 4, 7 )
        --Stables -> ( 18, 17 )
        --UmbraTribe -> ( 1, 10 )
        --VillageNearVaultCity -> ( 24, 5 )
        Arroyo ->
            ( 3, 2 )

        BrokenHills ->
            ( 23, 17 )

        Den ->
            ( 9, 5 )

        Navarro ->
            ( 3, 17 )

        Vault13 ->
            ( 19, 28 )

        Vault15 ->
            ( 25, 28 )

        EnclavePlatform ->
            ( 0, 26 )

        Gecko ->
            ( 25, 4 )

        Klamath ->
            ( 7, 2 )

        MilitaryBase ->
            ( 13, 28 )

        Modoc ->
            ( 18, 5 )

        NewCaliforniaRepublic ->
            ( 22, 28 )

        NewReno ->
            ( 18, 18 )

        Raiders ->
            ( 23, 13 )

        Redding ->
            ( 13, 10 )

        SanFrancisco ->
            ( 9, 26 )

        SierraArmyDepot ->
            ( 18, 16 )

        ToxicCaves ->
            ( 6, 1 )

        VaultCity ->
            ( 24, 6 )


name : Location -> String
name loc =
    case loc of
        --AbandonedHouse -> "Abandoned House"
        --Abbey -> "Abbey"
        --DenSlaveRun -> "Den Slave Run"
        --EPA -> "EPA"
        --FakeVault13 -> "Fake Vault 13"
        --GhostFarm -> "Ghost Farm"
        --Golgotha -> "Golgotha"
        --HubologistStash -> "Hubologist Stash"
        --KlamathSafeHouse -> "Safe House"
        --NewRenoSafeHouse -> "Safe House"
        --ReddingSafeHouse -> "Safe House"
        --ShiSubmarine -> "Shi Submarine"
        --SlaverCamp -> "Slaver Camp"
        --Stables -> "Stables"
        --UmbraTribe -> "Umbra Tribe"
        --VillageNearVaultCity -> "Village"
        Arroyo ->
            "Arroyo"

        BrokenHills ->
            "Broken Hills"

        Den ->
            "Den"

        EnclavePlatform ->
            "Enclave\nPlatform"

        Gecko ->
            "Gecko"

        Klamath ->
            "Klamath"

        MilitaryBase ->
            "Military Base"

        Modoc ->
            "Modoc"

        Navarro ->
            "Navarro"

        Vault13 ->
            "Vault 13"

        Vault15 ->
            "Vault 15"

        NewCaliforniaRepublic ->
            "New California Republic"

        NewReno ->
            "New Reno"

        Raiders ->
            "Raiders"

        Redding ->
            "Redding"

        SanFrancisco ->
            "San Francisco"

        SierraArmyDepot ->
            "Sierra Army Depot"

        ToxicCaves ->
            "Toxic Caves"

        VaultCity ->
            "Vault City"


dict : Dict TileCoords Location
dict =
    allLocations
        |> List.map (\loc -> ( coords loc, loc ))
        |> Dict.fromList


location : TileCoords -> Maybe Location
location tile =
    Dict.get tile dict


enclave : TileCoords
enclave =
    coords EnclavePlatform
