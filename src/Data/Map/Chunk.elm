module Data.Map.Chunk exposing (Chunk(..), chunk)

import Data.Map exposing (TileCoords)
import Dict exposing (Dict)
import List.ExtraExtra as List


type Chunk
    = ArroyoOcean -- Arro_O
    | ArroyoDesert -- Arro_D
    | ArroyoMountain -- Arro_M
    | ArroyoKlamathDesert -- Arrok_D
    | ArroyoKlamathMountain -- Arrok_M
    | KlamathDesert -- Kla_D
    | KlamathMountain -- Kla_M
    | KlamathDenDesert -- Klad_D
    | RouteDenModocReddingVaultCityDesert -- DMRV_D
    | RouteDenModocReddingVaultCityMountain -- DMRV_M
    | DenDesert -- Den_D
    | DenMountain -- Den_M
    | BanditsPassMountain -- Band_M
    | ModocMountain -- Mod_M
    | RouteDenVaultCityModocDesert -- DVMV_D
    | RouteDenVaultCityModocMountain -- DVMV_M
    | WildernessNorthOfModocDesert -- Wild1_D
    | WildernessNorthOfModocMountain -- Wild1_M
    | WildernessNorthOfVaultCityDesert -- Wild2_D
    | WildernessNorthOfVaultCityMountain -- Wild2_M
    | VaultCityDesert -- VPat_D
    | VaultCityMountain -- VPat_M
    | GeckoDesert -- Geck_D
    | GeckoMountain -- Geck_M
    | NorthCoast -- Fish_O
    | PrimitiveTribeDesert -- Prim_D
    | PrimitiveTribeMountain -- Prim_M
    | RouteDenNewRenoReddingVaultCityDesert -- DNRV_D
    | RouteDenNewRenoReddingVaultCityMountain -- DNRV_M
    | ReddingDesert -- Red_D
    | ReddingMountain -- Red_M
    | WildernessReddingRaiders -- Wild3_M
    | RouteVaultCityNewRenoGeckoBrokenHillsDesert -- RDRC_D
    | RouteVaultCityNewRenoGeckoBrokenHillsMountain -- RDRC_M
    | RaidersDesert -- Raid_D
    | RaidersMountain -- Raid_M
    | NavarroOcean -- Nav_O
    | NavarroDesert -- Nav_D
    | NavarroMountain -- Nav_M
    | EpaDesert -- EPA_D
    | EpaMountain -- EPA_M
    | EpaCity -- EPA_C
    | WildernessEpaCoastOcean -- Wild4_O
    | WildernessEpaCoastDesert -- Wild4_D
    | WildernessEpaCoastMountain -- Wild4_M
    | RouteSanFranciscoNcrReddingNewRenoDesert -- SRNRRN_D
    | RouteSanFranciscoNcrReddingNewRenoMountain -- SRNRRN_M
    | NewRenoDesert -- New_D
    | NewRenoMountain -- New_M
    | NewRenoCity -- New_C
    | BrokenHillsDesert -- Brok_D
    | BrokenHillsMountain -- Brok_M
    | SanFranciscoOcean -- Fran_O
    | SanFranciscoDesert -- Fran_D
    | SanFranciscoMountain -- Fran_M
    | SanFranciscoCity -- Fran_C
    | RouteSanFranciscoReddingDesert -- Fran2_D
    | RouteSanFranciscoReddingCity -- Fran2_C
    | WildernessSanFranciscoNcrDesert -- Wild5_D
    | WildernessSanFranciscoNcrMountain -- Wild5_M
    | RouteNcrNewRenoReddingDesert -- NRNR_D
    | RouteNcrNewRenoReddingMountain -- NRNR_M
    | WildernessNewRenoNcrDesert -- Wild6_D
    | WildernessNewRenoNcrMountain -- Wild6_M
    | RouteVault15NewRenoNcrBrokenHillsDesert -- VNNB_D
    | RouteVault15NewRenoNcrBrokenHillsMountain -- VNNB_M
    | NcrDesert -- NCR_D
    | NcrMountain -- NCR_M
    | Vault15Desert -- V15_D
    | Vault15Mountain -- V15_M


coordChunks : Dict TileCoords Chunk
coordChunks =
    -- It's transposed: the order is like [[(0,0),(0,1),(0,2),...], [(1,0),(1,1),...], ...]
    [ [ NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NorthCoast, PrimitiveTribeMountain, PrimitiveTribeMountain, NorthCoast, NorthCoast, NorthCoast, NorthCoast, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ ArroyoMountain, ArroyoOcean, ArroyoMountain, ArroyoMountain, ArroyoDesert, ArroyoMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeDesert, NorthCoast, NorthCoast, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ ArroyoMountain, ArroyoMountain, ArroyoMountain, ArroyoMountain, ArroyoDesert, ArroyoMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, NavarroMountain, NavarroMountain, NavarroMountain, NavarroMountain, NavarroOcean, NavarroOcean, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ ArroyoMountain, ArroyoMountain, ArroyoMountain, ArroyoMountain, ArroyoDesert, ArroyoMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeDesert, PrimitiveTribeMountain, NavarroMountain, NavarroDesert, NavarroMountain, NavarroMountain, NavarroMountain, NavarroOcean, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ ArroyoMountain, ArroyoMountain, ArroyoKlamathDesert, ArroyoDesert, ArroyoMountain, ArroyoMountain, PrimitiveTribeMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, NavarroMountain, NavarroDesert, NavarroDesert, NavarroMountain, NavarroDesert, NavarroMountain, NavarroOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathMountain, ArroyoKlamathMountain, KlamathDesert, KlamathDesert, KlamathDesert, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, NavarroMountain, NavarroDesert, NavarroDesert, NavarroMountain, NavarroDesert, NavarroDesert, NavarroMountain, WildernessEpaCoastOcean, WildernessEpaCoastOcean, WildernessEpaCoastOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathDesert, KlamathMountain, KlamathMountain, KlamathDesert, DenDesert, DenDesert, DenMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeMountain, WildernessEpaCoastMountain, WildernessEpaCoastMountain, WildernessEpaCoastDesert, WildernessEpaCoastMountain, WildernessEpaCoastDesert, WildernessEpaCoastDesert, WildernessEpaCoastMountain, WildernessEpaCoastMountain, WildernessEpaCoastMountain, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathMountain, KlamathMountain, KlamathDenDesert, KlamathDenDesert, DenDesert, DenDesert, DenDesert, RouteDenNewRenoReddingVaultCityDesert, RouteDenNewRenoReddingVaultCityDesert, PrimitiveTribeDesert, PrimitiveTribeMountain, PrimitiveTribeMountain, PrimitiveTribeDesert, WildernessEpaCoastDesert, WildernessEpaCoastDesert, WildernessEpaCoastDesert, WildernessEpaCoastMountain, WildernessEpaCoastMountain, WildernessEpaCoastDesert, WildernessEpaCoastDesert, WildernessEpaCoastMountain, WildernessEpaCoastMountain, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathDesert, KlamathMountain, DenDesert, KlamathDenDesert, DenDesert, RouteDenNewRenoReddingVaultCityDesert, RouteDenNewRenoReddingVaultCityDesert, RouteDenNewRenoReddingVaultCityMountain, RouteDenNewRenoReddingVaultCityMountain, RouteDenNewRenoReddingVaultCityMountain, PrimitiveTribeDesert, PrimitiveTribeDesert, PrimitiveTribeDesert, WildernessEpaCoastDesert, WildernessEpaCoastDesert, EpaDesert, EpaMountain, EpaMountain, EpaMountain, EpaMountain, EpaDesert, EpaMountain, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoOcean, SanFranciscoCity, RouteSanFranciscoReddingCity, SanFranciscoOcean, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathDesert, KlamathDesert, RouteDenModocReddingVaultCityDesert, RouteDenModocReddingVaultCityDesert, DenMountain, DenMountain, DenMountain, ReddingMountain, ReddingMountain, RouteDenNewRenoReddingVaultCityDesert, RouteDenNewRenoReddingVaultCityDesert, ReddingDesert, ReddingDesert, WildernessEpaCoastDesert, WildernessEpaCoastDesert, EpaDesert, EpaDesert, EpaMountain, EpaMountain, EpaMountain, EpaDesert, EpaDesert, SanFranciscoDesert, SanFranciscoMountain, SanFranciscoCity, SanFranciscoCity, SanFranciscoCity, RouteSanFranciscoReddingCity, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathDesert, RouteDenModocReddingVaultCityDesert, RouteDenModocReddingVaultCityDesert, DenMountain, DenMountain, DenMountain, DenMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingDesert, ReddingDesert, RouteSanFranciscoNcrReddingNewRenoDesert, RouteSanFranciscoNcrReddingNewRenoDesert, EpaMountain, EpaDesert, EpaMountain, EpaDesert, EpaDesert, EpaDesert, EpaDesert, SanFranciscoDesert, SanFranciscoMountain, RouteSanFranciscoReddingCity, RouteSanFranciscoReddingCity, RouteSanFranciscoReddingCity, RouteSanFranciscoReddingCity, SanFranciscoOcean ]
    , [ KlamathMountain, KlamathMountain, RouteDenModocReddingVaultCityMountain, DenMountain, DenMountain, DenMountain, DenMountain, DenMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingDesert, ReddingDesert, ReddingDesert, RouteSanFranciscoNcrReddingNewRenoDesert, RouteSanFranciscoNcrReddingNewRenoDesert, EpaDesert, EpaDesert, EpaDesert, EpaMountain, EpaMountain, EpaDesert, EpaDesert, RouteSanFranciscoReddingDesert, RouteSanFranciscoReddingDesert, SanFranciscoMountain, SanFranciscoMountain, SanFranciscoMountain, SanFranciscoDesert, SanFranciscoCity ]
    , [ BanditsPassMountain, BanditsPassMountain, RouteDenModocReddingVaultCityMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingDesert, ReddingDesert, RouteSanFranciscoNcrReddingNewRenoDesert, RouteSanFranciscoNcrReddingNewRenoDesert, EpaDesert, EpaDesert, EpaDesert, EpaDesert, EpaDesert, EpaCity, EpaCity, WildernessEpaCoastDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrDesert ]
    , [ BanditsPassMountain, BanditsPassMountain, RouteDenModocReddingVaultCityMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, RouteSanFranciscoNcrReddingNewRenoMountain, RouteSanFranciscoNcrReddingNewRenoDesert, EpaMountain, EpaDesert, EpaDesert, EpaDesert, EpaDesert, EpaCity, EpaCity, RouteNcrNewRenoReddingDesert, RouteNcrNewRenoReddingDesert, RouteNcrNewRenoReddingDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain ]
    , [ BanditsPassMountain, BanditsPassMountain, RouteDenModocReddingVaultCityMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, BanditsPassMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, RouteSanFranciscoNcrReddingNewRenoMountain, RouteSanFranciscoNcrReddingNewRenoMountain, EpaMountain, EpaMountain, EpaMountain, EpaDesert, EpaMountain, EpaCity, EpaCity, RouteNcrNewRenoReddingMountain, RouteNcrNewRenoReddingDesert, RouteNcrNewRenoReddingMountain, RouteNcrNewRenoReddingDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrMountain ]
    , [ WildernessNorthOfModocMountain, WildernessNorthOfModocMountain, RouteDenModocReddingVaultCityMountain, ModocMountain, ModocMountain, ModocMountain, ModocMountain, ModocMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, ReddingMountain, WildernessReddingRaiders, WildernessReddingRaiders, NewRenoMountain, NewRenoMountain, NewRenoDesert, NewRenoMountain, NewRenoMountain, NewRenoMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, RouteNcrNewRenoReddingMountain, RouteNcrNewRenoReddingDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert ]
    , [ WildernessNorthOfModocDesert, WildernessNorthOfModocDesert, RouteDenModocReddingVaultCityMountain, ModocMountain, ModocMountain, ModocMountain, ModocMountain, ModocMountain, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, NewRenoMountain, NewRenoMountain, NewRenoDesert, NewRenoMountain, NewRenoMountain, NewRenoMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, RouteNcrNewRenoReddingMountain, RouteNcrNewRenoReddingDesert, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert ]
    , [ WildernessNorthOfModocMountain, WildernessNorthOfModocMountain, RouteDenModocReddingVaultCityMountain, RouteDenModocReddingVaultCityDesert, RouteDenModocReddingVaultCityDesert, ModocMountain, ModocMountain, ModocMountain, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, NewRenoMountain, NewRenoMountain, NewRenoCity, NewRenoCity, NewRenoCity, NewRenoCity, NewRenoCity, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, RouteNcrNewRenoReddingMountain, RouteNcrNewRenoReddingMountain, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrDesert ]
    , [ WildernessNorthOfModocDesert, WildernessNorthOfModocDesert, WildernessNorthOfModocDesert, RouteDenModocReddingVaultCityMountain, RouteDenVaultCityModocDesert, ModocMountain, ModocMountain, ModocMountain, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, NewRenoMountain, NewRenoMountain, NewRenoCity, NewRenoMountain, NewRenoCity, NewRenoMountain, NewRenoMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, RouteNcrNewRenoReddingMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrDesert ]
    , [ WildernessNorthOfModocMountain, WildernessNorthOfModocMountain, WildernessNorthOfModocMountain, RouteDenModocReddingVaultCityMountain, RouteDenVaultCityModocDesert, ModocMountain, ModocMountain, ModocMountain, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, WildernessReddingRaiders, RaidersMountain, RaidersMountain, WildernessReddingRaiders, NewRenoMountain, NewRenoMountain, NewRenoCity, NewRenoCity, NewRenoCity, NewRenoMountain, NewRenoMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, NcrMountain, NcrDesert, NcrDesert ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityDesert, WildernessNorthOfVaultCityDesert, WildernessNorthOfVaultCityDesert, RouteDenVaultCityModocMountain, VaultCityDesert, VaultCityMountain, VaultCityMountain, RaidersMountain, RaidersMountain, RaidersDesert, RaidersDesert, RaidersMountain, RaidersMountain, RaidersMountain, BrokenHillsMountain, NewRenoDesert, NewRenoMountain, NewRenoMountain, NewRenoMountain, NewRenoDesert, NewRenoDesert, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, RouteVault15NewRenoNcrBrokenHillsMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, NcrMountain, NcrDesert, NcrDesert ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, RouteDenVaultCityModocMountain, VaultCityDesert, VaultCityMountain, VaultCityMountain, VaultCityMountain, RaidersMountain, RaidersMountain, RaidersMountain, RaidersMountain, RaidersMountain, RaidersMountain, BrokenHillsDesert, BrokenHillsDesert, BrokenHillsDesert, BrokenHillsMountain, BrokenHillsMountain, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsMountain, RouteVault15NewRenoNcrBrokenHillsMountain, RouteVault15NewRenoNcrBrokenHillsMountain, NcrMountain, NcrMountain, NcrMountain ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityDesert, RouteDenVaultCityModocDesert, RouteDenVaultCityModocMountain, VaultCityMountain, VaultCityMountain, VaultCityMountain, RaidersMountain, RaidersMountain, RaidersMountain, RaidersMountain, RaidersMountain, RouteVaultCityNewRenoGeckoBrokenHillsDesert, BrokenHillsDesert, BrokenHillsDesert, BrokenHillsDesert, BrokenHillsDesert, BrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsDesert, RouteVault15NewRenoNcrBrokenHillsMountain, RouteVault15NewRenoNcrBrokenHillsMountain, Vault15Mountain, NcrMountain, NcrMountain, NcrMountain ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityDesert, WildernessNorthOfVaultCityDesert, GeckoDesert, GeckoMountain, RouteDenVaultCityModocDesert, VaultCityDesert, VaultCityMountain, VaultCityMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsDesert, RouteVaultCityNewRenoGeckoBrokenHillsDesert, BrokenHillsDesert, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsDesert, WildernessNewRenoNcrDesert, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, Vault15Desert, Vault15Desert, Vault15Mountain, Vault15Mountain ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, GeckoMountain, GeckoDesert, RouteDenVaultCityModocDesert, VaultCityDesert, VaultCityDesert, VaultCityMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsDesert, RouteVaultCityNewRenoGeckoBrokenHillsDesert, RouteVaultCityNewRenoGeckoBrokenHillsDesert, BrokenHillsDesert, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsDesert, BrokenHillsMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, Vault15Mountain, Vault15Desert, Vault15Mountain, Vault15Mountain ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, GeckoDesert, GeckoMountain, GeckoMountain, VaultCityDesert, VaultCityDesert, VaultCityMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsMountain, RouteVaultCityNewRenoGeckoBrokenHillsDesert, RaidersDesert, RaidersDesert, BrokenHillsDesert, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrDesert, WildernessSanFranciscoNcrMountain, Vault15Mountain, Vault15Mountain, Vault15Mountain, Vault15Desert ]
    , [ WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, WildernessNorthOfVaultCityMountain, GeckoDesert, GeckoDesert, GeckoDesert, VaultCityDesert, VaultCityDesert, VaultCityMountain, RaidersMountain, RaidersMountain, RaidersDesert, RaidersDesert, RaidersDesert, RaidersMountain, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, BrokenHillsMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessNewRenoNcrMountain, WildernessSanFranciscoNcrMountain, WildernessSanFranciscoNcrMountain, Vault15Mountain, Vault15Mountain, Vault15Mountain, Vault15Desert ]
    ]
        |> List.indexedMap (\column list -> list |> List.indexedMap (\row chunk_ -> ( ( row, column ), chunk_ )))
        |> List.fastConcat
        |> Dict.fromList


chunk : TileCoords -> Chunk
chunk coords =
    Dict.get coords coordChunks
        |> Maybe.withDefault ArroyoDesert
