module Data.Location exposing
    ( Location(..)
    , coords
    , default
    )

import Data.Map exposing (Coords)


default : Location
default =
    -- TODO does this cause issues? Do new players need protection from PKers?
    Arroyo


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


coords : Location -> Coords
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
