module Data.Map.Location exposing
    ( Location(..)
    , Size(..)
    , allLocations
    , coords
    , default
    , description
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


description : Location -> String
description loc =
    case loc of
        Arroyo ->
            """Your tribal village, where you grew up, hidden away behind a deep
canyon with only a single swaying rope bridge connecting it to the outside
world. A small community struggling with drought, but rich in tradition and
wisdom passed down from the Vault Dweller."""

        BrokenHills ->
            """An uranium mining town where humans, ghouls and super mutants try
to live together in an uneasy peace under the watchful eye of Marcus, the
super mutant sheriff. Not everyone is happy with this arrangement."""

        Den ->
            """A lawless frontier town and haven for slavers, drug dealers, and
other criminals. The east side is dominated by the Slavers' guild, while on
the outskirts you can find Smitty's repair shop. Watch your step and keep
your hand on your wallet."""

        EnclavePlatform ->
            """A heavily fortified oil rig in the Pacific Ocean 175 miles off
the coast of California, officially named Control Station ENCLAVE. The
headquarters of the Enclave, the remnants of the U.S. government who consider
themselves humanity's last, best hope."""

        Gecko ->
            """A settlement of ghouls built around a damaged nuclear power
plant. Despite their appearance, most of the residents are peaceful and simply
trying to survive. The running nuclear reactor certainly helps keep unwanted
visitors away."""

        Klamath ->
            """A small trading town on the Oregon border. Known for its brahmin
trade and gecko hunting. Watch out for the rats in the trapper town. The
residents say ungodly screams can be heard at night. Thankfully you can forget
about all of that while visiting the bathhouse."""

        MilitaryBase ->
            """The ruins of Mariposa Military Base, where the U.S. government first
tested the Forced Evolutionary Virus (FEV) on human subjects. Later became the
birthplace of the super mutant army under the Master. Now allegedly abandoned,
but likely still full of military equipment, and still as dangerous as ever."""

        Modoc ->
            """A small farming community plagued by drought and mysterious crop
failures. Once prosperous from trading brahmin leather and meat, their fortunes
have since declined. The people here are desperate for help. There's also a talk
of ghosts haunting one of the farms nearby - strangely, its crops grow in
abundance even though nobody tends it."""

        Navarro ->
            """A hidden Enclave military base disguised as an old gas station.
Built next to a defunct PoseidonOil facility, it serves as a vital refueling
and maintenance point for vertibird aircraft. Despite housing some of the most
advanced technology in the wasteland, the base struggles with chronic
understaffing and frequent desertions."""

        Vault13 ->
            """The legendary shelter that saved your ancestors, and where your
tribe hoped to find the Garden of Eden Creation Kit (GECK) to save them from
starvation. Now home to intelligent Deathclaws who protect its human
residents."""

        Vault15 ->
            """An abandoned Vault that became the birthplace of several raider
groups. Recent reports suggest squatters have taken up residence there, though
its true value may lie in what secrets remain in its lower levels."""

        NewCaliforniaRepublic ->
            """A growing nation built on the principles of old world democracy,
and on the foundations of Shady Sands. President Tandi works to expand NCR
influence across the wasteland through trade and diplomacy - or military force
when necessary."""

        NewReno ->
            """"The Biggest Little City in the World." A den of vice where four
powerful crime families - the Bishops, Mordinos, Wrights and Salvatores -
compete for control. Drugs, gambling, and prostitution fuel its economy, while
tourists seeking thrills keep the caps flowing."""

        Raiders ->
            """A fortified camp of ruthless raiders who terrorize travelers and
caravans throughout the region. Their numbers and firepower make them a serious
threat to anyone crossing their territory. Even well-armed merchants avoid this
area."""

        Redding ->
            """A bustling gold mining town where fortune seekers still strike it rich.
The mines bring wealth and workers, but also trouble - one had to be sealed
after mutated horrors emerged from its depths. A recent epidemic of Jet
addiction plagues the miners, while the NCR and New Reno crime families wage a
quiet war for control through their rival mining operations."""

        SanFrancisco ->
            """A fog-shrouded city home to Shi - the descendants of the crew of
a Chinese submarine that crashed here. They have built a thriving community
using pre-war and newly developed technology. Their scientists work in secretive
labs while armed guards patrol Chinatown's streets. The dock hosts the tanker
PMV Valdez, now home to a diverse and tolerant band of independent thinkers and
outcasts. The Hubologists cult occupies a space shuttle facility nearby, hoping
to one day launch the shuttle ESS Quetzel into the space."""

        SierraArmyDepot ->
            """Once a regional storage area for the military's arms and
munitions, a significant amount of its holdings were depleted in the Great War,
yet there are still technological wonders to be found - if you brave its
automated defenses."""

        ToxicCaves ->
            """Once a military warehouse, it's a treacherous network of caves,
contaminated by radioactive waste and filled to the brim with geckos that love
this environment. Might still house important technology."""

        VaultCity ->
            """A high-tech settlement in Northern Nevada established by the
inhabitants of Vault 8 after the Great War, who were lucky enough to walk out of
their Vault unscathed and use a GECK to transform their surroundings. Their
advanced medical technology and strict social order have created a prosperous
but deeply prejudiced society that treats outsiders as subhuman."""
