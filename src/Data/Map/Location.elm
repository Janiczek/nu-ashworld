module Data.Map.Location exposing
    ( Location(..)
    , Size(..)
    , allLocations
    , coords
    , default
    , location
    , name
    , size
    )

import Data.Map as Map exposing (TileCoords, TileNum)
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
      --| Navarro
      --| NewRenoSafeHouse
      --| Raiders
      --| ReddingSafeHouse
      --| ShiSubmarine
      --| SierraArmyDepot
      --| SlaverCamp
      --| Stables
      --| ToxicCaves
      --| UmbraTribe
      --| Vault13
      --| Vault15
      --| VillageNearVaultCity
    | BrokenHills
    | Den
    | EnclavePlatform
    | Gecko
    | Klamath
    | MilitaryBase
    | Modoc
    | NewCaliforniaRepublic
    | NewReno
    | Redding
    | SanFrancisco
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
    --, Navarro
    --, NewRenoSafeHouse
    --, Raiders
    --, ReddingSafeHouse
    --, ShiSubmarine
    --, SierraArmyDepot
    --, SlaverCamp
    --, Stables
    --, ToxicCaves
    --, UmbraTribe
    --, Vault13
    --, Vault15
    --, VillageNearVaultCity
    , BrokenHills
    , Den
    , EnclavePlatform
    , Gecko
    , Klamath
    , MilitaryBase
    , Modoc
    , NewCaliforniaRepublic
    , NewReno
    , Redding
    , SanFrancisco
    , VaultCity
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
        --Navarro -> Middle
        --NewRenoSafeHouse -> Small
        --Raiders -> Middle
        --ReddingSafeHouse -> Small
        --ShiSubmarine -> Small
        --SierraArmyDepot -> Middle
        --SlaverCamp -> Small
        --Stables -> Small
        --ToxicCaves -> Small
        --UmbraTribe -> Middle
        --Vault13 -> Middle
        --Vault15 -> Middle
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

        NewCaliforniaRepublic ->
            Large

        NewReno ->
            Large

        Redding ->
            Large

        SanFrancisco ->
            Large

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
        --Navarro -> ( 3, 17 )
        --NewRenoSafeHouse -> ( 20, 19 )
        --Raiders -> ( 23, 13 )
        --ReddingSafeHouse -> ( 11, 13 )
        --ShiSubmarine -> ( 8, 26 )
        --SierraArmyDepot -> ( 18, 16 )
        --SlaverCamp -> ( 4, 7 )
        --Stables -> ( 18, 17 )
        --ToxicCaves -> ( 6, 1 )
        --UmbraTribe -> ( 1, 10 )
        --Vault13 -> ( 19, 28 )
        --Vault15 -> ( 25, 28 )
        --VillageNearVaultCity -> ( 24, 5 )
        Arroyo ->
            ( 3, 2 )

        BrokenHills ->
            ( 23, 17 )

        Den ->
            ( 9, 5 )

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

        Redding ->
            ( 13, 10 )

        SanFrancisco ->
            ( 9, 26 )

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
        --Navarro -> "Navarro"
        --NewRenoSafeHouse -> "Safe House"
        --Raiders -> "Raiders"
        --ReddingSafeHouse -> "Safe House"
        --ShiSubmarine -> "Shi Submarine"
        --SierraArmyDepot -> "Sierra Army Depot"
        --SlaverCamp -> "Slaver Camp"
        --Stables -> "Stables"
        --ToxicCaves -> "Toxic Caves"
        --UmbraTribe -> "Umbra Tribe"
        --Vault13 -> "Vault 13"
        --Vault15 -> "Vault 15"
        --VillageNearVaultCity -> "Village"
        Arroyo ->
            "Arroyo"

        BrokenHills ->
            "Broken Hills"

        Den ->
            "Den"

        EnclavePlatform ->
            "Enclave Platform"

        Gecko ->
            "Gecko"

        Klamath ->
            "Klamath"

        MilitaryBase ->
            "Military Base"

        Modoc ->
            "Modoc"

        NewCaliforniaRepublic ->
            "New California Republic"

        NewReno ->
            "New Reno"

        Redding ->
            "Redding"

        SanFrancisco ->
            "San Francisco"

        VaultCity ->
            "Vault City"


dict : Dict TileNum Location
dict =
    allLocations
        |> List.map (\loc -> ( Map.toTileNum <| coords loc, loc ))
        |> Dict.fromList


location : TileNum -> Maybe Location
location tile =
    Dict.get tile dict
