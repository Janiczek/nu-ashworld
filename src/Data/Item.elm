module Data.Item exposing
    ( Effect(..)
    , Id
    , Item
    , Kind(..)
    , Type(..)
    , UniqueKey
    , all
    , allHealing
    , allHealingNonempty
    , allNonempty
    , armorClass
    , baseValue
    , create
    , damageResistanceNormal
    , damageThresholdNormal
    , decoder
    , encode
    , encodeKind
    , findMergeableId
    , getUniqueKey
    , healAmountGenerator
    , healAmountGenerator_
    , isArmor
    , isHandEquippable
    , isHealing
    , kindDecoder
    , name
    , typeName
    , type_
    , usageEffects
    )

import Data.Skill as Skill exposing (Skill)
import Dict exposing (Dict)
import Dict.Extra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)



-- TODO weight : Kind -> Int


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


type Kind
    = Fruit
    | HealingPowder
    | MeatJerky
    | Beer
      --
    | Stimpak
    | SuperStimpak
      --
    | BigBookOfScience
    | DeansElectronics
    | FirstAidBook
    | GunsAndBullets
    | ScoutHandbook
      --
    | Robes
    | LeatherJacket
    | LeatherArmor
    | MetalArmor
    | TeslaArmor
    | CombatArmor
    | CombatArmorMk2
    | PowerArmor
      --
    | PowerFist
    | MegaPowerFist
      --
      -- TODO knives? crowbar? etc
    | SuperSledge
      --
    | Grenade
      --
    | BBGun
    | HuntingRifle
    | ScopedHuntingRifle
    | Bozar
    | SawedOffShotgun
    | SniperRifle
    | AssaultRifle
    | ExpandedAssaultRifle
    | PancorJackhammer
    | HkP90c
    | LaserPistol
    | PlasmaRifle
    | GatlingLaser
    | TurboPlasmaRifle
    | GaussRifle
    | GaussPistol
    | PulseRifle
      --
    | BBAmmo
    | SmallEnergyCell
    | Fmj223
    | ShotgunShell
    | Smg10mm
    | Jhp10mm
    | Jhp5mm
    | MicrofusionCell
    | Ec2mm
      --
    | Tool
    | LockPicks
    | ElectronicLockpick
    | AbnormalBrain
    | ChimpanzeeBrain
    | HumanBrain
    | CyberneticBrain
    | GECK
    | SkynetAim
    | MotionSensor
    | K9


all : List Kind
all =
    [ Fruit
    , HealingPowder
    , MeatJerky
    , Stimpak
    , BigBookOfScience
    , DeansElectronics
    , FirstAidBook
    , GunsAndBullets
    , ScoutHandbook
    , Robes
    , LeatherJacket
    , LeatherArmor
    , MetalArmor
    , Beer
    , BBGun
    , BBAmmo
    , ElectronicLockpick
    , AbnormalBrain
    , ChimpanzeeBrain
    , HumanBrain
    , CyberneticBrain
    , HuntingRifle
    , ScopedHuntingRifle
    ]


allNonempty : ( Kind, List Kind )
allNonempty =
    case all of
        [] ->
            -- Just a sentinel, shouldn't happen
            ( Fruit, [] )

        x :: xs ->
            ( x, xs )


allHealing : List Kind
allHealing =
    List.filter isHealing all


allHealingNonempty : ( Kind, List Kind )
allHealingNonempty =
    case allHealing of
        [] ->
            -- Just a sentinel, shouldn't happen
            ( Fruit, [] )

        x :: xs ->
            ( x, xs )


isHealing : Kind -> Bool
isHealing kind =
    List.any isHealingEffect (usageEffects kind)


isHealingEffect : Effect -> Bool
isHealingEffect effect =
    getHealingEffect effect /= Nothing


getHealingEffect : Effect -> Maybe { min : Int, max : Int }
getHealingEffect effect =
    case effect of
        Heal r ->
            Just r

        RemoveAfterUse ->
            Nothing

        BookRemoveTicks ->
            Nothing

        BookAddSkillPercent _ ->
            Nothing


type Effect
    = Heal { min : Int, max : Int }
    | RemoveAfterUse
    | BookRemoveTicks
    | BookAddSkillPercent Skill


baseValue : Kind -> Int
baseValue kind =
    case kind of
        Fruit ->
            10

        HealingPowder ->
            20

        MeatJerky ->
            30

        Stimpak ->
            175

        BigBookOfScience ->
            400

        DeansElectronics ->
            130

        FirstAidBook ->
            175

        GunsAndBullets ->
            425

        ScoutHandbook ->
            200

        Robes ->
            90

        LeatherJacket ->
            250

        LeatherArmor ->
            700

        MetalArmor ->
            1100

        Beer ->
            200

        BBGun ->
            3500

        BBAmmo ->
            20

        ElectronicLockpick ->
            375

        AbnormalBrain ->
            50

        ChimpanzeeBrain ->
            200

        HumanBrain ->
            500

        CyberneticBrain ->
            1000

        HuntingRifle ->
            1000

        ScopedHuntingRifle ->
            1500

        SuperStimpak ->
            225

        TeslaArmor ->
            4500

        CombatArmor ->
            6500

        CombatArmorMk2 ->
            8000

        PowerArmor ->
            12500

        SuperSledge ->
            3750

        PowerFist ->
            2200

        MegaPowerFist ->
            3200

        Grenade ->
            150

        Bozar ->
            5250

        SawedOffShotgun ->
            800

        SniperRifle ->
            2200

        AssaultRifle ->
            1300

        ExpandedAssaultRifle ->
            2300

        PancorJackhammer ->
            5500

        HkP90c ->
            2500

        LaserPistol ->
            1400

        PlasmaRifle ->
            4000

        GatlingLaser ->
            7500

        TurboPlasmaRifle ->
            10000

        GaussRifle ->
            8250

        GaussPistol ->
            5250

        PulseRifle ->
            17500

        SmallEnergyCell ->
            400

        Fmj223 ->
            200

        ShotgunShell ->
            225

        Smg10mm ->
            1000

        Jhp10mm ->
            75

        Jhp5mm ->
            100

        MicrofusionCell ->
            1000

        Ec2mm ->
            400

        Tool ->
            200

        GECK ->
            30000

        SkynetAim ->
            10000

        MotionSensor ->
            800

        K9 ->
            5000

        LockPicks ->
            150


armorClass : Kind -> Int
armorClass kind =
    case kind of
        Robes ->
            5

        LeatherJacket ->
            8

        LeatherArmor ->
            15

        MetalArmor ->
            10

        TeslaArmor ->
            15

        CombatArmor ->
            20

        CombatArmorMk2 ->
            25

        PowerArmor ->
            25

        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Beer ->
            0

        Stimpak ->
            0

        SuperStimpak ->
            0

        BigBookOfScience ->
            0

        DeansElectronics ->
            0

        FirstAidBook ->
            0

        GunsAndBullets ->
            0

        ScoutHandbook ->
            0

        PowerFist ->
            0

        MegaPowerFist ->
            0

        SuperSledge ->
            0

        Grenade ->
            0

        BBGun ->
            0

        HuntingRifle ->
            0

        ScopedHuntingRifle ->
            0

        Bozar ->
            0

        SawedOffShotgun ->
            0

        SniperRifle ->
            0

        AssaultRifle ->
            0

        ExpandedAssaultRifle ->
            0

        PancorJackhammer ->
            0

        HkP90c ->
            0

        LaserPistol ->
            0

        PlasmaRifle ->
            0

        GatlingLaser ->
            0

        TurboPlasmaRifle ->
            0

        GaussRifle ->
            0

        GaussPistol ->
            0

        PulseRifle ->
            0

        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            0

        ShotgunShell ->
            0

        Smg10mm ->
            0

        Jhp10mm ->
            0

        Jhp5mm ->
            0

        MicrofusionCell ->
            0

        Ec2mm ->
            0

        Tool ->
            0

        LockPicks ->
            0

        ElectronicLockpick ->
            0

        AbnormalBrain ->
            0

        ChimpanzeeBrain ->
            0

        HumanBrain ->
            0

        CyberneticBrain ->
            0

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0


damageThresholdNormal : Kind -> Int
damageThresholdNormal kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            2

        MetalArmor ->
            4

        TeslaArmor ->
            4

        CombatArmor ->
            5

        CombatArmorMk2 ->
            6

        PowerArmor ->
            12

        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Beer ->
            0

        Stimpak ->
            0

        SuperStimpak ->
            0

        BigBookOfScience ->
            0

        DeansElectronics ->
            0

        FirstAidBook ->
            0

        GunsAndBullets ->
            0

        ScoutHandbook ->
            0

        PowerFist ->
            0

        MegaPowerFist ->
            0

        SuperSledge ->
            0

        Grenade ->
            0

        BBGun ->
            0

        HuntingRifle ->
            0

        ScopedHuntingRifle ->
            0

        Bozar ->
            0

        SawedOffShotgun ->
            0

        SniperRifle ->
            0

        AssaultRifle ->
            0

        ExpandedAssaultRifle ->
            0

        PancorJackhammer ->
            0

        HkP90c ->
            0

        LaserPistol ->
            0

        PlasmaRifle ->
            0

        GatlingLaser ->
            0

        TurboPlasmaRifle ->
            0

        GaussRifle ->
            0

        GaussPistol ->
            0

        PulseRifle ->
            0

        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            0

        ShotgunShell ->
            0

        Smg10mm ->
            0

        Jhp10mm ->
            0

        Jhp5mm ->
            0

        MicrofusionCell ->
            0

        Ec2mm ->
            0

        Tool ->
            0

        LockPicks ->
            0

        ElectronicLockpick ->
            0

        AbnormalBrain ->
            0

        ChimpanzeeBrain ->
            0

        HumanBrain ->
            0

        CyberneticBrain ->
            0

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0


damageResistanceNormal : Kind -> Int
damageResistanceNormal kind =
    case kind of
        Robes ->
            20

        LeatherJacket ->
            20

        LeatherArmor ->
            25

        MetalArmor ->
            30

        TeslaArmor ->
            20

        CombatArmor ->
            40

        CombatArmorMk2 ->
            40

        PowerArmor ->
            40

        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Beer ->
            0

        Stimpak ->
            0

        SuperStimpak ->
            0

        BigBookOfScience ->
            0

        DeansElectronics ->
            0

        FirstAidBook ->
            0

        GunsAndBullets ->
            0

        ScoutHandbook ->
            0

        PowerFist ->
            0

        MegaPowerFist ->
            0

        SuperSledge ->
            0

        Grenade ->
            0

        BBGun ->
            0

        HuntingRifle ->
            0

        ScopedHuntingRifle ->
            0

        Bozar ->
            0

        SawedOffShotgun ->
            0

        SniperRifle ->
            0

        AssaultRifle ->
            0

        ExpandedAssaultRifle ->
            0

        PancorJackhammer ->
            0

        HkP90c ->
            0

        LaserPistol ->
            0

        PlasmaRifle ->
            0

        GatlingLaser ->
            0

        TurboPlasmaRifle ->
            0

        GaussRifle ->
            0

        GaussPistol ->
            0

        PulseRifle ->
            0

        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            0

        ShotgunShell ->
            0

        Smg10mm ->
            0

        Jhp10mm ->
            0

        Jhp5mm ->
            0

        MicrofusionCell ->
            0

        Ec2mm ->
            0

        Tool ->
            0

        LockPicks ->
            0

        ElectronicLockpick ->
            0

        AbnormalBrain ->
            0

        ChimpanzeeBrain ->
            0

        HumanBrain ->
            0

        CyberneticBrain ->
            0

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0


encode : Item -> JE.Value
encode item =
    JE.object
        [ ( "id", JE.int item.id )
        , ( "kind", encodeKind item.kind )
        , ( "count", JE.int item.count )
        ]


decoder : Decoder Item
decoder =
    JD.succeed Item
        |> JD.andMap (JD.field "id" JD.int)
        |> JD.andMap (JD.field "kind" kindDecoder)
        |> JD.andMap (JD.field "count" JD.int)


encodeKind : Kind -> JE.Value
encodeKind kind =
    case kind of
        Fruit ->
            JE.string "fruit"

        HealingPowder ->
            JE.string "healing-powder"

        MeatJerky ->
            JE.string "meat-jerky"

        Stimpak ->
            JE.string "stimpak"

        BigBookOfScience ->
            JE.string "big-book-of-science"

        DeansElectronics ->
            JE.string "deans-electronics"

        FirstAidBook ->
            JE.string "first-aid-book"

        GunsAndBullets ->
            JE.string "guns-and-bullets"

        ScoutHandbook ->
            JE.string "scout-handbook"

        Robes ->
            JE.string "robes"

        LeatherJacket ->
            JE.string "leather-jacket"

        LeatherArmor ->
            JE.string "leather-armor"

        MetalArmor ->
            JE.string "metal-armor"

        Beer ->
            JE.string "beer"

        BBGun ->
            JE.string "bb-gun"

        BBAmmo ->
            JE.string "bb-ammo"

        ElectronicLockpick ->
            JE.string "electronic-lockpick"

        AbnormalBrain ->
            JE.string "abnormal-brain"

        ChimpanzeeBrain ->
            JE.string "chimpanzee-brain"

        HumanBrain ->
            JE.string "human-brain"

        CyberneticBrain ->
            JE.string "cybernetic-brain"

        HuntingRifle ->
            JE.string "hunting-rifle"

        ScopedHuntingRifle ->
            JE.string "scoped-hunting-rifle"

        SuperStimpak ->
            JE.string "super-stimpak"

        TeslaArmor ->
            JE.string "tesla-armor"

        CombatArmor ->
            JE.string "combat-armor"

        CombatArmorMk2 ->
            JE.string "combat-armor-mk2"

        PowerArmor ->
            JE.string "power-armor"

        SuperSledge ->
            JE.string "super-sledge"

        PowerFist ->
            JE.string "power-fist"

        MegaPowerFist ->
            JE.string "mega-power-fist"

        Grenade ->
            JE.string "grenade"

        Bozar ->
            JE.string "bozar"

        SawedOffShotgun ->
            JE.string "sawed-off-shotgun"

        SniperRifle ->
            JE.string "sniper-rifle"

        AssaultRifle ->
            JE.string "assault-rifle"

        ExpandedAssaultRifle ->
            JE.string "expanded-assault-rifle"

        PancorJackhammer ->
            JE.string "pancor-jackhammer"

        HkP90c ->
            JE.string "hk-p90c"

        LaserPistol ->
            JE.string "laser-pistol"

        PlasmaRifle ->
            JE.string "plasma-rifle"

        GatlingLaser ->
            JE.string "gatling-laser"

        TurboPlasmaRifle ->
            JE.string "turbo-plasma-rifle"

        GaussRifle ->
            JE.string "gauss-rifle"

        GaussPistol ->
            JE.string "gauss-pistol"

        PulseRifle ->
            JE.string "pulse-rifle"

        SmallEnergyCell ->
            JE.string "small-energy-cell"

        Fmj223 ->
            JE.string "fmj-223"

        ShotgunShell ->
            JE.string "shotgun-shell"

        Smg10mm ->
            JE.string "smg-10mm"

        Jhp10mm ->
            JE.string "jhp-10mm"

        Jhp5mm ->
            JE.string "jhp-5mm"

        MicrofusionCell ->
            JE.string "microfusion-cell"

        Ec2mm ->
            JE.string "ec-2mm"

        Tool ->
            JE.string "tool"

        GECK ->
            JE.string "geck"

        SkynetAim ->
            JE.string "skynet-aim"

        MotionSensor ->
            JE.string "motion-sensor"

        K9 ->
            JE.string "k9"

        LockPicks ->
            JE.string "lock-picks"


kindDecoder : Decoder Kind
kindDecoder =
    JD.string
        |> JD.andThen
            (\kind ->
                case kind of
                    "fruit" ->
                        JD.succeed Fruit

                    "healing-powder" ->
                        JD.succeed HealingPowder

                    "meat-jerky" ->
                        JD.succeed MeatJerky

                    "stimpak" ->
                        JD.succeed Stimpak

                    "big-book-of-science" ->
                        JD.succeed BigBookOfScience

                    "deans-electronics" ->
                        JD.succeed DeansElectronics

                    "first-aid-book" ->
                        JD.succeed FirstAidBook

                    "guns-and-bullets" ->
                        JD.succeed GunsAndBullets

                    "scout-handbook" ->
                        JD.succeed ScoutHandbook

                    "robes" ->
                        JD.succeed Robes

                    "leather-jacket" ->
                        JD.succeed LeatherJacket

                    "leather-armor" ->
                        JD.succeed LeatherArmor

                    "metal-armor" ->
                        JD.succeed MetalArmor

                    "beer" ->
                        JD.succeed Beer

                    "bb-gun" ->
                        JD.succeed BBGun

                    "bb-ammo" ->
                        JD.succeed BBAmmo

                    "electronic-lockpick" ->
                        JD.succeed ElectronicLockpick

                    "abnormal-brain" ->
                        JD.succeed AbnormalBrain

                    "chimpanzee-brain" ->
                        JD.succeed ChimpanzeeBrain

                    "human-brain" ->
                        JD.succeed HumanBrain

                    "cybernetic-brain" ->
                        JD.succeed CyberneticBrain

                    "hunting-rifle" ->
                        JD.succeed HuntingRifle

                    "scoped-hunting-rifle" ->
                        JD.succeed ScopedHuntingRifle

                    "super-stimpak" ->
                        JD.succeed SuperStimpak

                    "tesla-armor" ->
                        JD.succeed TeslaArmor

                    "combat-armor" ->
                        JD.succeed CombatArmor

                    "combat-armor-mk2" ->
                        JD.succeed CombatArmorMk2

                    "power-armor" ->
                        JD.succeed PowerArmor

                    "super-sledge" ->
                        JD.succeed SuperSledge

                    "power-fist" ->
                        JD.succeed PowerFist

                    "mega-power-fist" ->
                        JD.succeed MegaPowerFist

                    "grenade" ->
                        JD.succeed Grenade

                    "bozar" ->
                        JD.succeed Bozar

                    "sawed-off-shotgun" ->
                        JD.succeed SawedOffShotgun

                    "sniper-rifle" ->
                        JD.succeed SniperRifle

                    "assault-rifle" ->
                        JD.succeed AssaultRifle

                    "expanded-assault-rifle" ->
                        JD.succeed ExpandedAssaultRifle

                    "pancor-jackhammer" ->
                        JD.succeed PancorJackhammer

                    "hk-p90c" ->
                        JD.succeed HkP90c

                    "laser-pistol" ->
                        JD.succeed LaserPistol

                    "plasma-rifle" ->
                        JD.succeed PlasmaRifle

                    "gatling-laser" ->
                        JD.succeed GatlingLaser

                    "turbo-plasma-rifle" ->
                        JD.succeed TurboPlasmaRifle

                    "gauss-rifle" ->
                        JD.succeed GaussRifle

                    "gauss-pistol" ->
                        JD.succeed GaussPistol

                    "pulse-rifle" ->
                        JD.succeed PulseRifle

                    "small-energy-cell" ->
                        JD.succeed SmallEnergyCell

                    "fmj-223" ->
                        JD.succeed Fmj223

                    "shotgun-shell" ->
                        JD.succeed ShotgunShell

                    "smg-10mm" ->
                        JD.succeed Smg10mm

                    "jhp-10mm" ->
                        JD.succeed Jhp10mm

                    "jhp-5mm" ->
                        JD.succeed Jhp5mm

                    "microfusion-cell" ->
                        JD.succeed MicrofusionCell

                    "ec-2mm" ->
                        JD.succeed Ec2mm

                    "tool" ->
                        JD.succeed Tool

                    "geck" ->
                        JD.succeed GECK

                    "skynet-aim" ->
                        JD.succeed SkynetAim

                    "motion-sensor" ->
                        JD.succeed MotionSensor

                    "k9" ->
                        JD.succeed K9

                    "lock-picks" ->
                        JD.succeed LockPicks

                    _ ->
                        JD.fail <| "Unknown item kind: '" ++ kind ++ "'"
            )


name : Kind -> String
name kind =
    case kind of
        Fruit ->
            "Fruit"

        HealingPowder ->
            "Healing Powder"

        MeatJerky ->
            "Meat Jerky"

        Stimpak ->
            "Stimpak"

        BigBookOfScience ->
            "Big Book of Science"

        DeansElectronics ->
            "Dean's Electronics"

        FirstAidBook ->
            "First Aid Book"

        GunsAndBullets ->
            "Guns and Bullets"

        ScoutHandbook ->
            "Scout Handbook"

        Robes ->
            "Robes"

        LeatherJacket ->
            "Leather Jacket"

        LeatherArmor ->
            "Leather Armor"

        MetalArmor ->
            "Metal Armor"

        Beer ->
            "Beer"

        BBGun ->
            "BB Gun"

        BBAmmo ->
            "BB Ammo"

        ElectronicLockpick ->
            "Electronic Lockpick"

        AbnormalBrain ->
            "Abnormal Brain"

        ChimpanzeeBrain ->
            "Chimpanzee Brain"

        HumanBrain ->
            "Human Brain"

        CyberneticBrain ->
            "Cybernetic Brain"

        HuntingRifle ->
            "Hunting Rifle"

        ScopedHuntingRifle ->
            "Scoped Hunting Rifle"

        SuperStimpak ->
            "Super Stimpak"

        TeslaArmor ->
            "Tesla Armor"

        CombatArmor ->
            "Combat Armor"

        CombatArmorMk2 ->
            "Combat Armor MK2"

        PowerArmor ->
            "Power Armor"

        SuperSledge ->
            "Super Sledge"

        PowerFist ->
            "Power Fist"

        MegaPowerFist ->
            "Mega Power Fist"

        Grenade ->
            "Grenade"

        Bozar ->
            "Bozar"

        SawedOffShotgun ->
            "Sawed-off Shotgun"

        SniperRifle ->
            "Sniper Rifle"

        AssaultRifle ->
            "Assault Rifle"

        ExpandedAssaultRifle ->
            "Expanded Assault Rifle"

        PancorJackhammer ->
            "Pancor Jackhammer"

        HkP90c ->
            "HK P90c"

        LaserPistol ->
            "Laser Pistol"

        PlasmaRifle ->
            "Plasma Rifle"

        GatlingLaser ->
            "Gatling Laser"

        TurboPlasmaRifle ->
            "Turbo Plasma Rifle"

        GaussRifle ->
            "Gauss Rifle"

        GaussPistol ->
            "Gauss Pistol"

        PulseRifle ->
            "Pulse Rifle"

        SmallEnergyCell ->
            "Small Energy Cell"

        Fmj223 ->
            ".223 FMJ"

        ShotgunShell ->
            "Shotgun Shell"

        Smg10mm ->
            "10mm SMG"

        Jhp10mm ->
            "10mm JHP"

        Jhp5mm ->
            "5mm JHP"

        MicrofusionCell ->
            "Microfusion Cell"

        Ec2mm ->
            "2mm EC"

        Tool ->
            "Tool"

        GECK ->
            "GECK"

        SkynetAim ->
            "Skynet Aim"

        MotionSensor ->
            "Motion Sensor"

        K9 ->
            "K9"

        LockPicks ->
            "Lock Picks"


create :
    { lastId : Int
    , uniqueKey : UniqueKey
    , count : Int
    }
    -> ( Item, Int )
create { lastId, uniqueKey, count } =
    let
        newLastId : Int
        newLastId =
            lastId + 1

        item : Item
        item =
            { id = newLastId
            , kind = uniqueKey.kind
            , count = count
            }
    in
    ( item, newLastId )


{-| This identifies item.

---- the below written before we tried to do mods a bit differently ----

Right now this is just the item Kind (eg.
HuntingRifle) but later when we add Mods, UniqueKey will also contain them and
so you will be able to differentiate between (HuntingRifle, []) and
(HuntingRifle, [HuntingRifleUpgrade]) or
(HuntingRifle, [HasAmmo (24, Ammo223FMJ)]) or something.

This hopefully will prevent bugs like player with upgraded weapon buying a
non-upgraded one and it becoming automatically (wrongly) upgraded too.

-}
type alias UniqueKey =
    -- TODO mods
    { kind : Kind
    }


getUniqueKey : Item -> UniqueKey
getUniqueKey item =
    { kind = item.kind }


findMergeableId : Item -> Dict Id Item -> Maybe Id
findMergeableId item items =
    let
        uniqueKey : UniqueKey
        uniqueKey =
            getUniqueKey item
    in
    items
        |> Dict.find (\_ item_ -> getUniqueKey item_ == uniqueKey)
        |> Maybe.map Tuple.first


usageEffects : Kind -> List Effect
usageEffects kind =
    case kind of
        Fruit ->
            -- TODO radiation +1 after some time (2x)
            [ Heal { min = 1, max = 4 }
            , RemoveAfterUse
            ]

        HealingPowder ->
            -- TODO temporary perception -1?
            [ Heal { min = 8, max = 18 }
            , RemoveAfterUse
            ]

        MeatJerky ->
            [ Heal { min = 5, max = 10 }
            , RemoveAfterUse
            ]

        Stimpak ->
            [ Heal { min = 10, max = 20 }
            , RemoveAfterUse
            ]

        BigBookOfScience ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Science
            ]

        DeansElectronics ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Repair
            ]

        FirstAidBook ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.FirstAid
            ]

        GunsAndBullets ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.SmallGuns
            ]

        ScoutHandbook ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Outdoorsman
            ]

        Robes ->
            []

        LeatherJacket ->
            []

        LeatherArmor ->
            []

        MetalArmor ->
            []

        Beer ->
            []

        BBGun ->
            []

        BBAmmo ->
            []

        ElectronicLockpick ->
            []

        AbnormalBrain ->
            []

        ChimpanzeeBrain ->
            []

        HumanBrain ->
            []

        CyberneticBrain ->
            []

        HuntingRifle ->
            []

        ScopedHuntingRifle ->
            []

        SuperStimpak ->
            -- TODO lose HP after some time
            [ Heal { min = 75, max = 75 }
            , RemoveAfterUse
            ]

        TeslaArmor ->
            []

        CombatArmor ->
            []

        CombatArmorMk2 ->
            []

        PowerArmor ->
            []

        SuperSledge ->
            []

        PowerFist ->
            []

        MegaPowerFist ->
            []

        Grenade ->
            []

        Bozar ->
            []

        SawedOffShotgun ->
            []

        SniperRifle ->
            []

        AssaultRifle ->
            []

        ExpandedAssaultRifle ->
            []

        PancorJackhammer ->
            []

        HkP90c ->
            []

        LaserPistol ->
            []

        PlasmaRifle ->
            []

        GatlingLaser ->
            []

        TurboPlasmaRifle ->
            []

        GaussRifle ->
            []

        GaussPistol ->
            []

        PulseRifle ->
            []

        SmallEnergyCell ->
            []

        Fmj223 ->
            []

        ShotgunShell ->
            []

        Smg10mm ->
            []

        Jhp10mm ->
            []

        Jhp5mm ->
            []

        MicrofusionCell ->
            []

        Ec2mm ->
            []

        Tool ->
            []

        GECK ->
            -- TODO what do we want to do with this one?
            []

        SkynetAim ->
            []

        MotionSensor ->
            []

        K9 ->
            []

        LockPicks ->
            []


type Type
    = Food
    | Armor
    | UnarmedWeapon
    | MeleeWeapon
    | ThrownWeapon
    | SmallGun
    | BigGun
    | EnergyWeapon
    | Book
    | Misc
    | Ammo


isHandEquippableType : Type -> Bool
isHandEquippableType type__ =
    case type__ of
        Food ->
            False

        Armor ->
            False

        UnarmedWeapon ->
            True

        MeleeWeapon ->
            True

        ThrownWeapon ->
            True

        SmallGun ->
            True

        BigGun ->
            True

        EnergyWeapon ->
            True

        Book ->
            False

        Misc ->
            False

        Ammo ->
            False


type_ : Kind -> Type
type_ kind =
    case kind of
        Fruit ->
            Food

        HealingPowder ->
            Food

        MeatJerky ->
            Food

        Stimpak ->
            Food

        BigBookOfScience ->
            Book

        DeansElectronics ->
            Book

        FirstAidBook ->
            Book

        GunsAndBullets ->
            Book

        ScoutHandbook ->
            Book

        Robes ->
            Armor

        LeatherJacket ->
            Armor

        LeatherArmor ->
            Armor

        MetalArmor ->
            Armor

        Beer ->
            Misc

        BBGun ->
            SmallGun

        BBAmmo ->
            Ammo

        ElectronicLockpick ->
            Misc

        AbnormalBrain ->
            Misc

        ChimpanzeeBrain ->
            Misc

        HumanBrain ->
            Misc

        CyberneticBrain ->
            Misc

        HuntingRifle ->
            SmallGun

        ScopedHuntingRifle ->
            SmallGun

        SuperStimpak ->
            Food

        TeslaArmor ->
            Armor

        CombatArmor ->
            Armor

        CombatArmorMk2 ->
            Armor

        PowerArmor ->
            Armor

        SuperSledge ->
            MeleeWeapon

        PowerFist ->
            UnarmedWeapon

        MegaPowerFist ->
            UnarmedWeapon

        Grenade ->
            ThrownWeapon

        Bozar ->
            BigGun

        SawedOffShotgun ->
            SmallGun

        SniperRifle ->
            SmallGun

        AssaultRifle ->
            SmallGun

        ExpandedAssaultRifle ->
            SmallGun

        PancorJackhammer ->
            SmallGun

        HkP90c ->
            SmallGun

        LaserPistol ->
            EnergyWeapon

        PlasmaRifle ->
            EnergyWeapon

        GatlingLaser ->
            EnergyWeapon

        TurboPlasmaRifle ->
            EnergyWeapon

        GaussRifle ->
            SmallGun

        GaussPistol ->
            SmallGun

        PulseRifle ->
            EnergyWeapon

        SmallEnergyCell ->
            Ammo

        Fmj223 ->
            Ammo

        ShotgunShell ->
            Ammo

        Smg10mm ->
            SmallGun

        Jhp10mm ->
            Ammo

        Jhp5mm ->
            Ammo

        MicrofusionCell ->
            Ammo

        Ec2mm ->
            Ammo

        Tool ->
            Misc

        GECK ->
            Misc

        SkynetAim ->
            Misc

        MotionSensor ->
            Misc

        K9 ->
            Misc

        LockPicks ->
            Misc


isHandEquippable : Kind -> Bool
isHandEquippable kind =
    isHandEquippableType (type_ kind)


isArmor : Kind -> Bool
isArmor kind =
    type_ kind == Armor


typeName : Type -> String
typeName type__ =
    case type__ of
        Food ->
            "Food"

        Book ->
            "Book"

        Armor ->
            "Armor"

        Misc ->
            "Miscellaneous"

        UnarmedWeapon ->
            "Unarmed Weapon"

        MeleeWeapon ->
            "Melee Weapon"

        ThrownWeapon ->
            "Thrown Weapon"

        SmallGun ->
            "Small Gun"

        BigGun ->
            "Big Gun"

        EnergyWeapon ->
            "Energy Weapon"

        Ammo ->
            "Ammo"


healAmount : Kind -> Maybe { min : Int, max : Int }
healAmount kind =
    kind
        |> usageEffects
        |> List.filterMap getHealingEffect
        |> List.head


healAmountGenerator : Kind -> Generator Int
healAmountGenerator kind =
    case healAmount kind of
        Just r ->
            healAmountGenerator_ r

        Nothing ->
            Random.constant 0


healAmountGenerator_ : { min : Int, max : Int } -> Generator Int
healAmountGenerator_ { min, max } =
    Random.int min max
