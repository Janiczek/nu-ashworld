module Data.Map.BigChunk exposing
    ( BigChunk(..)
    , all
    , difficulty
    , forCoords
    , fromSmallChunk
    , tileCoords
    )

import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import Data.Map as Map exposing (TileCoords)
import Data.Map.SmallChunk as SmallChunk exposing (SmallChunk(..))


type BigChunk
    = C1 -- Arroyo, Klamath, Den
    | C2 -- Modoc, Vault City, Gecko
    | C3 -- New Reno, Broken Hills, Redding, Raiders
    | C4 -- NCR, Vault 13, Vault 15, Military Base
    | C5 -- San Francisco, Navarro, Enclave


all : List BigChunk
all =
    [ C1, C2, C3, C4, C5 ]


difficulty : BigChunk -> String
difficulty bigChunk =
    case bigChunk of
        C1 ->
            "1/5"

        C2 ->
            "2/5"

        C3 ->
            "3/5"

        C4 ->
            "4/5"

        C5 ->
            "5/5"


forCoords : TileCoords -> BigChunk
forCoords coords =
    fromSmallChunk (SmallChunk.forCoords coords)


fromSmallChunk : SmallChunk -> BigChunk
fromSmallChunk smallChunk =
    case smallChunk of
        ArroyoOcean ->
            C1

        ArroyoDesert ->
            C1

        ArroyoMountain ->
            C1

        ArroyoKlamathDesert ->
            C1

        ArroyoKlamathMountain ->
            C1

        KlamathDesert ->
            C1

        KlamathMountain ->
            C1

        KlamathDenDesert ->
            C1

        RouteDenModocReddingVaultCityDesert ->
            C2

        RouteDenModocReddingVaultCityMountain ->
            C2

        DenDesert ->
            C1

        DenMountain ->
            C1

        BanditsPassMountain ->
            C2

        ModocMountain ->
            C2

        RouteDenVaultCityModocDesert ->
            C2

        RouteDenVaultCityModocMountain ->
            C2

        WildernessNorthOfModocDesert ->
            C2

        WildernessNorthOfModocMountain ->
            C2

        WildernessNorthOfVaultCityDesert ->
            C2

        WildernessNorthOfVaultCityMountain ->
            C2

        VaultCityDesert ->
            C2

        VaultCityMountain ->
            C2

        GeckoDesert ->
            C2

        GeckoMountain ->
            C2

        NorthCoast ->
            C1

        PrimitiveTribeDesert ->
            C1

        PrimitiveTribeMountain ->
            C1

        RouteDenNewRenoReddingVaultCityDesert ->
            C1

        RouteDenNewRenoReddingVaultCityMountain ->
            C1

        ReddingDesert ->
            C3

        ReddingMountain ->
            C3

        WildernessReddingRaiders ->
            C3

        RouteVaultCityNewRenoGeckoBrokenHillsDesert ->
            C3

        RouteVaultCityNewRenoGeckoBrokenHillsMountain ->
            C3

        RaidersDesert ->
            C3

        RaidersMountain ->
            C3

        NavarroOcean ->
            C5

        NavarroDesert ->
            C5

        NavarroMountain ->
            C5

        EpaDesert ->
            C5

        EpaMountain ->
            C5

        EpaCity ->
            C5

        WildernessEpaCoastOcean ->
            C5

        WildernessEpaCoastDesert ->
            C5

        WildernessEpaCoastMountain ->
            C5

        RouteSanFranciscoNcrReddingNewRenoDesert ->
            C3

        RouteSanFranciscoNcrReddingNewRenoMountain ->
            C3

        NewRenoDesert ->
            C4

        NewRenoMountain ->
            C4

        NewRenoCity ->
            C4

        BrokenHillsDesert ->
            C4

        BrokenHillsMountain ->
            C4

        SanFranciscoOcean ->
            C5

        SanFranciscoDesert ->
            C5

        SanFranciscoMountain ->
            C5

        SanFranciscoCity ->
            C5

        RouteSanFranciscoReddingDesert ->
            C5

        RouteSanFranciscoReddingCity ->
            C5

        WildernessSanFranciscoNcrDesert ->
            C4

        WildernessSanFranciscoNcrMountain ->
            C4

        RouteNcrNewRenoReddingDesert ->
            C4

        RouteNcrNewRenoReddingMountain ->
            C4

        WildernessNewRenoNcrDesert ->
            C4

        WildernessNewRenoNcrMountain ->
            C4

        RouteVault15NewRenoNcrBrokenHillsDesert ->
            C4

        RouteVault15NewRenoNcrBrokenHillsMountain ->
            C4

        NcrDesert ->
            C4

        NcrMountain ->
            C4

        Vault15Desert ->
            C4

        Vault15Mountain ->
            C4


groupedCoords : SeqDict BigChunk (List TileCoords)
groupedCoords =
    Map.allTileCoords
        |> SeqDict.groupBy forCoords


tileCoords : BigChunk -> List TileCoords
tileCoords bigChunk =
    SeqDict.get bigChunk groupedCoords
        -- shouldn't happen:
        |> Maybe.withDefault []
