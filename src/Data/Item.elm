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
    , damageResistanceEMP
    , damageResistanceElectrical
    , damageResistanceExplosion
    , damageResistanceFire
    , damageResistanceLaser
    , damageResistanceNormal
    , damageResistancePlasma
    , damageThresholdEMP
    , damageThresholdElectrical
    , damageThresholdExplosion
    , damageThresholdFire
    , damageThresholdLaser
    , damageThresholdNormal
    , damageThresholdPlasma
    , decoder
    , encode
    , encodeKind
    , findMergeableId
    , getUniqueKey
    , healAmountGenerator
    , healAmountGenerator_
    , isArmor
    , isHealing
    , isLongRangeWeapon
    , isWeapon
    , kindDecoder
    , name
    , range
    , typeName
    , type_
    , usageEffects
    )

import Data.Fight.AttackStyle exposing (AttackStyle(..))
import Data.Fight.ShotType exposing (ShotType(..))
import Data.Skill as Skill exposing (Skill)
import Dict exposing (Dict)
import Dict.Extra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Random exposing (Generator)



-- TODO weight : Kind -> Int
-- TODO strengthRequirement : Kind -> Int


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


type Kind
    = -----------------
      -- CONSUMABLES --
      -----------------
      -- Antidote
      Beer
      -- Booze
      -- Buffout
      -- Cookie
    | Fruit
      -- Gamma Gulp Beer
    | HealingPowder
      -- Hypo
      -- Iguana Bits
      -- Iguana-on-a-stick
      -- Jet
      -- Jet Antidote
      -- Mentats
      -- Monument Chunk
      -- Nuka-Cola
      -- Poison
      -- Psycho
      -- Rad-X
      -- RadAway
      -- Roentgen Rum
      -- Rot Gut
    | Stimpak
    | SuperStimpak
      -----------
      -- BOOKS --
      -----------
    | BigBookOfScience
      -- Cat's Paw Issue no.5
    | DeansElectronics
      -- Fallout 2 Hintbook
    | FirstAidBook
    | GunsAndBullets
    | ScoutHandbook
      -----------
      -- ARMOR --
      -----------
    | Robes
      -- Bridgekeeper's Robes
    | LeatherJacket
      -- Combat Leather Jacket
    | LeatherArmor
      -- Leather Armor Mk2
    | MetalArmor
      -- Metal Armor Mk2
    | TeslaArmor
    | CombatArmor
    | CombatArmorMk2
      -- Brotherhood Armor
    | PowerArmor
      -- Hardened Power Armor
      -- Advanced Power Armor
      -- Advanced Power Armor Mk2
      -------------
      -- UNARMED --
      -------------
      -- Brass Knuckles
      -- Spiked Knuckles
    | PowerFist
    | MegaPowerFist
      -- Rock (also in throwing)
      -- Gold Nugget (also in throwing)
      -- Uranium ore (also in throwing)
      -- Refined uranium ore (also in throwing)
      -- Boxing Gloves
      -- Plated Boxing Gloves
      -------------------
      -- MELEE WEAPONS --
      -------------------
      -- Club
      -- Wrench
      -- Crowbar
      -- Cattle Prod
      -- Super Cattle Prod
      -- Shiv
      -- Switchblade
      -- Knife
      -- Combat Knife
      -- Wakizashi
      -- "Little Jesus"
      -- Ripper
      -- Throwing Knife (also in Throwing)
      -- Sharpened Pole (also in Throwing)
      -- Spear (also in Throwing)
      -- Sharpened Spear (also in Throwing)
      ------------
      -- Sledgehammer
    | SuperSledge
      -- Louisville Slugger
      ----------------
      -- SMALL GUNS --
      ----------------
      -- 223 Pistol
      -- 9mm Mauser
      -- 10mm Pistol
      -- 14mm Pistol
      -- Desert Eagle .44
      -- Desert Eagle (Exp. Mag.)
      -- 44 Magnum Revolver
      -- 44 Magnum (Speed Load)
      -- Needler Pistol
    | GaussPistol
      -- Zip Gun
      ----------
      -- 10mm SMG
      -- M3A1 Grease Gun SMG
      -- Tommy gun
    | HkP90c
      -- H&K G11
      -- H&K G11E
      -----------
    | AssaultRifle
    | ExpandedAssaultRifle
      -- XL70E3
      -- FN FAL
      -- FN FAL (Night Sight)
      -- FN FAL HPFA
    | HuntingRifle
    | ScopedHuntingRifle
      -- Pipe Rifle
      -- Red Ryder BB Gun
      -- Jonny's BB Gun
    | RedRyderLEBBGun
    | SniperRifle
    | GaussRifle
      -------------
      -- Combat Shotgun
      -- H&K CAWS
    | PancorJackhammer
      -- Shotgun
    | SawedOffShotgun
      --------------
      -- BIG GUNS --
      --------------
    | Minigun
      -- AvengerMinigun
      -- VindicatorMinigun
      -- LightSupportWeapon
    | Bozar
      -- M60
      -- Flamer
      -- Improved Flamer
    | RocketLauncher
      --------------------
      -- ENERGY WEAPONS --
      --------------------
      -- Alien Blaster
    | LaserPistol
      -- Magneto-Laser Pistol
      -- Plasma Pistol
      -- Plasma Pistol (Ext. Cap.)
      -- Phazer
      -- Solar Scorcher
      -- YK32 Pulse Pistol
      ------------
    | GatlingLaser
    | LaserRifle
    | LaserRifleExtCap
    | PlasmaRifle
    | TurboPlasmaRifle
    | PulseRifle
      --------------
      -- THROWING --
      --------------
      -- Flare
      -- Plant spike
    | FragGrenade
      -- Molotov cocktail
      -- Plasma grenade
      -- Pulse grenade
      -- Holy hand grenade
      -- Rock
      -- Gold nugget
      -- Uranium ore
      -- Refined uranium ore
      -- Sharpened pole
      -- Spear
      -- Sharpened spear
      -- Throwing knife
      ----------
      -- AMMO --
      ----------
    | BBAmmo
    | SmallEnergyCell
    | Fmj223
      -- Fmj44Magnum
      -- Jhp44Magnum
      -- Caliber45
      -- Caseless47mm
      -- Ap5mm
      -- Mm762
      -- Mm9
      -- Ball9mm
      -- Ap10mm
      -- Ap14mm
      -- ExplosiveRocket
      -- RocketAp
      -- FlamethrowerFuel
      -- FlamethrowerFuelMk2
      -- HnNeedlerCartridge
      -- HnApNeedlerCartridge
      -- SmallEnergyCell
    | ShotgunShell
    | Smg10mm
    | Jhp10mm
    | Jhp5mm
    | MicrofusionCell
    | Ec2mm
      ----------
      -- MISC --
      ----------
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
    | MeatJerky


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
    , RedRyderLEBBGun
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

        RedRyderLEBBGun ->
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

        FragGrenade ->
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

        Minigun ->
            3800

        RocketLauncher ->
            2300

        LaserRifle ->
            5000

        LaserRifleExtCap ->
            -- balance?
            5000


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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdExplosion : Kind -> Int
damageThresholdExplosion kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            4

        TeslaArmor ->
            4

        CombatArmor ->
            6

        CombatArmorMk2 ->
            9

        PowerArmor ->
            20

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdElectrical : Kind -> Int
damageThresholdElectrical kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            0

        TeslaArmor ->
            12

        CombatArmor ->
            2

        CombatArmorMk2 ->
            3

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdEMP : Kind -> Int
damageThresholdEMP kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            0

        TeslaArmor ->
            0

        CombatArmor ->
            0

        CombatArmorMk2 ->
            0

        PowerArmor ->
            0

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdLaser : Kind -> Int
damageThresholdLaser kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            6

        TeslaArmor ->
            19

        CombatArmor ->
            8

        CombatArmorMk2 ->
            9

        PowerArmor ->
            18

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdFire : Kind -> Int
damageThresholdFire kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            4

        TeslaArmor ->
            4

        CombatArmor ->
            4

        CombatArmorMk2 ->
            5

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageThresholdPlasma : Kind -> Int
damageThresholdPlasma kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            4

        TeslaArmor ->
            10

        CombatArmor ->
            4

        CombatArmorMk2 ->
            5

        PowerArmor ->
            10

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistanceExplosion : Kind -> Int
damageResistanceExplosion kind =
    case kind of
        Robes ->
            20

        LeatherJacket ->
            20

        LeatherArmor ->
            20

        MetalArmor ->
            25

        TeslaArmor ->
            20

        CombatArmor ->
            40

        CombatArmorMk2 ->
            45

        PowerArmor ->
            50

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistanceElectrical : Kind -> Int
damageResistanceElectrical kind =
    case kind of
        Robes ->
            40

        LeatherJacket ->
            30

        LeatherArmor ->
            30

        MetalArmor ->
            0

        TeslaArmor ->
            80

        CombatArmor ->
            50

        CombatArmorMk2 ->
            55

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistanceEMP : Kind -> Int
damageResistanceEMP kind =
    case kind of
        Robes ->
            500

        LeatherJacket ->
            500

        LeatherArmor ->
            500

        MetalArmor ->
            500

        TeslaArmor ->
            500

        CombatArmor ->
            500

        CombatArmorMk2 ->
            500

        PowerArmor ->
            500

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistanceLaser : Kind -> Int
damageResistanceLaser kind =
    case kind of
        Robes ->
            25

        LeatherJacket ->
            20

        LeatherArmor ->
            20

        MetalArmor ->
            75

        TeslaArmor ->
            90

        CombatArmor ->
            60

        CombatArmorMk2 ->
            65

        PowerArmor ->
            80

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistanceFire : Kind -> Int
damageResistanceFire kind =
    case kind of
        Robes ->
            10

        LeatherJacket ->
            10

        LeatherArmor ->
            20

        MetalArmor ->
            10

        TeslaArmor ->
            10

        CombatArmor ->
            30

        CombatArmorMk2 ->
            35

        PowerArmor ->
            60

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


damageResistancePlasma : Kind -> Int
damageResistancePlasma kind =
    case kind of
        Robes ->
            10

        LeatherJacket ->
            10

        LeatherArmor ->
            10

        MetalArmor ->
            20

        TeslaArmor ->
            180

        CombatArmor ->
            50

        CombatArmorMk2 ->
            50

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

        FragGrenade ->
            0

        RedRyderLEBBGun ->
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

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
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
    JE.string <|
        case kind of
            Fruit ->
                "fruit"

            HealingPowder ->
                "healing-powder"

            MeatJerky ->
                "meat-jerky"

            Stimpak ->
                "stimpak"

            BigBookOfScience ->
                "big-book-of-science"

            DeansElectronics ->
                "deans-electronics"

            FirstAidBook ->
                "first-aid-book"

            GunsAndBullets ->
                "guns-and-bullets"

            ScoutHandbook ->
                "scout-handbook"

            Robes ->
                "robes"

            LeatherJacket ->
                "leather-jacket"

            LeatherArmor ->
                "leather-armor"

            MetalArmor ->
                "metal-armor"

            Beer ->
                "beer"

            RedRyderLEBBGun ->
                "bb-gun"

            BBAmmo ->
                "bb-ammo"

            ElectronicLockpick ->
                "electronic-lockpick"

            AbnormalBrain ->
                "abnormal-brain"

            ChimpanzeeBrain ->
                "chimpanzee-brain"

            HumanBrain ->
                "human-brain"

            CyberneticBrain ->
                "cybernetic-brain"

            HuntingRifle ->
                "hunting-rifle"

            ScopedHuntingRifle ->
                "scoped-hunting-rifle"

            SuperStimpak ->
                "super-stimpak"

            TeslaArmor ->
                "tesla-armor"

            CombatArmor ->
                "combat-armor"

            CombatArmorMk2 ->
                "combat-armor-mk2"

            PowerArmor ->
                "power-armor"

            SuperSledge ->
                "super-sledge"

            PowerFist ->
                "power-fist"

            MegaPowerFist ->
                "mega-power-fist"

            FragGrenade ->
                "frag-grenade"

            Bozar ->
                "bozar"

            SawedOffShotgun ->
                "sawed-off-shotgun"

            SniperRifle ->
                "sniper-rifle"

            AssaultRifle ->
                "assault-rifle"

            ExpandedAssaultRifle ->
                "expanded-assault-rifle"

            PancorJackhammer ->
                "pancor-jackhammer"

            HkP90c ->
                "hk-p90c"

            LaserPistol ->
                "laser-pistol"

            PlasmaRifle ->
                "plasma-rifle"

            GatlingLaser ->
                "gatling-laser"

            TurboPlasmaRifle ->
                "turbo-plasma-rifle"

            GaussRifle ->
                "gauss-rifle"

            GaussPistol ->
                "gauss-pistol"

            PulseRifle ->
                "pulse-rifle"

            SmallEnergyCell ->
                "small-energy-cell"

            Fmj223 ->
                "fmj-223"

            ShotgunShell ->
                "shotgun-shell"

            Smg10mm ->
                "smg-10mm"

            Jhp10mm ->
                "jhp-10mm"

            Jhp5mm ->
                "jhp-5mm"

            MicrofusionCell ->
                "microfusion-cell"

            Ec2mm ->
                "ec-2mm"

            Tool ->
                "tool"

            GECK ->
                "geck"

            SkynetAim ->
                "skynet-aim"

            MotionSensor ->
                "motion-sensor"

            K9 ->
                "k9"

            LockPicks ->
                "lock-picks"

            Minigun ->
                "minigun"

            RocketLauncher ->
                "rocket-launcher"

            LaserRifle ->
                "laser-rifle"

            LaserRifleExtCap ->
                "laser-rifle-ext-cap"


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
                        JD.succeed RedRyderLEBBGun

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

                    "frag-grenade" ->
                        JD.succeed FragGrenade

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

                    "minigun" ->
                        JD.succeed Minigun

                    "rocket-launcher" ->
                        JD.succeed RocketLauncher

                    "laser-rifle" ->
                        JD.succeed LaserRifle

                    "laser-rifle-ext-cap" ->
                        JD.succeed LaserRifleExtCap

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

        RedRyderLEBBGun ->
            "Red Ryder LE BB Gun"

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

        FragGrenade ->
            "Frag Grenade"

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

        Minigun ->
            "Minigun"

        RocketLauncher ->
            "Rocket Launcher"

        LaserRifle ->
            "Laser Rifle"

        LaserRifleExtCap ->
            "Laser Rifle (Extended Capacity)"


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

        Stimpak ->
            [ Heal { min = 10, max = 20 }
            , RemoveAfterUse
            ]

        MeatJerky ->
            []

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

        RedRyderLEBBGun ->
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

        FragGrenade ->
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

        Minigun ->
            []

        RocketLauncher ->
            []

        LaserRifle ->
            []

        LaserRifleExtCap ->
            []


type Type
    = Consumable
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


isWeaponType : Type -> Bool
isWeaponType type__ =
    case type__ of
        Consumable ->
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
            Consumable

        HealingPowder ->
            Consumable

        Stimpak ->
            Consumable

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

        RedRyderLEBBGun ->
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

        MeatJerky ->
            Misc

        HuntingRifle ->
            SmallGun

        ScopedHuntingRifle ->
            SmallGun

        SuperStimpak ->
            Consumable

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

        FragGrenade ->
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

        Minigun ->
            BigGun

        RocketLauncher ->
            BigGun

        LaserRifle ->
            EnergyWeapon

        LaserRifleExtCap ->
            EnergyWeapon


isWeapon : Kind -> Bool
isWeapon kind =
    isWeaponType (type_ kind)


isArmor : Kind -> Bool
isArmor kind =
    type_ kind == Armor


typeName : Type -> String
typeName type__ =
    case type__ of
        Consumable ->
            "Consumable"

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


unaimedRange : Kind -> Int
unaimedRange kind =
    case kind of
        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Stimpak ->
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

        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            0

        Beer ->
            0

        RedRyderLEBBGun ->
            30

        BBAmmo ->
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

        HuntingRifle ->
            40

        ScopedHuntingRifle ->
            40

        SuperStimpak ->
            0

        TeslaArmor ->
            0

        CombatArmor ->
            0

        CombatArmorMk2 ->
            0

        PowerArmor ->
            0

        SuperSledge ->
            2

        PowerFist ->
            1

        MegaPowerFist ->
            1

        FragGrenade ->
            15

        Bozar ->
            35

        SawedOffShotgun ->
            7

        SniperRifle ->
            50

        AssaultRifle ->
            45

        ExpandedAssaultRifle ->
            45

        PancorJackhammer ->
            35

        HkP90c ->
            30

        LaserPistol ->
            35

        PlasmaRifle ->
            25

        GatlingLaser ->
            40

        TurboPlasmaRifle ->
            35

        GaussRifle ->
            50

        GaussPistol ->
            50

        PulseRifle ->
            30

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

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0

        LockPicks ->
            0

        Minigun ->
            0

        RocketLauncher ->
            40

        LaserRifle ->
            45

        LaserRifleExtCap ->
            45


aimedRange : Kind -> Int
aimedRange kind =
    case kind of
        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Stimpak ->
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

        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            0

        Beer ->
            0

        RedRyderLEBBGun ->
            30

        BBAmmo ->
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

        HuntingRifle ->
            45

        ScopedHuntingRifle ->
            40

        SuperStimpak ->
            0

        TeslaArmor ->
            0

        CombatArmor ->
            0

        CombatArmorMk2 ->
            0

        PowerArmor ->
            0

        SuperSledge ->
            2

        PowerFist ->
            1

        MegaPowerFist ->
            1

        FragGrenade ->
            15

        Bozar ->
            35

        SawedOffShotgun ->
            7

        SniperRifle ->
            50

        AssaultRifle ->
            45

        ExpandedAssaultRifle ->
            45

        PancorJackhammer ->
            35

        HkP90c ->
            30

        LaserPistol ->
            35

        PlasmaRifle ->
            25

        GatlingLaser ->
            40

        TurboPlasmaRifle ->
            35

        GaussRifle ->
            50

        GaussPistol ->
            50

        PulseRifle ->
            30

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

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0

        LockPicks ->
            0

        Minigun ->
            0

        RocketLauncher ->
            0

        LaserRifle ->
            45

        LaserRifleExtCap ->
            45


burstRange : Kind -> Int
burstRange kind =
    case kind of
        Fruit ->
            0

        HealingPowder ->
            0

        MeatJerky ->
            0

        Stimpak ->
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

        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            0

        MetalArmor ->
            0

        Beer ->
            0

        RedRyderLEBBGun ->
            30

        BBAmmo ->
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

        HuntingRifle ->
            45

        ScopedHuntingRifle ->
            40

        SuperStimpak ->
            0

        TeslaArmor ->
            0

        CombatArmor ->
            0

        CombatArmorMk2 ->
            0

        PowerArmor ->
            0

        SuperSledge ->
            2

        PowerFist ->
            1

        MegaPowerFist ->
            1

        FragGrenade ->
            15

        Bozar ->
            35

        SawedOffShotgun ->
            7

        SniperRifle ->
            50

        AssaultRifle ->
            38

        ExpandedAssaultRifle ->
            38

        PancorJackhammer ->
            35

        HkP90c ->
            25

        LaserPistol ->
            35

        PlasmaRifle ->
            25

        GatlingLaser ->
            40

        TurboPlasmaRifle ->
            35

        GaussRifle ->
            50

        GaussPistol ->
            50

        PulseRifle ->
            30

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

        GECK ->
            0

        SkynetAim ->
            0

        MotionSensor ->
            0

        K9 ->
            0

        LockPicks ->
            0

        Minigun ->
            35

        RocketLauncher ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0


range : ShotType -> Kind -> Int
range shotType kind =
    case shotType of
        NormalShot ->
            unaimedRange kind

        AimedShot _ ->
            aimedRange kind

        BurstShot ->
            burstRange kind


{-| In other words, does the Weapon Long Range perk apply?
-}
isLongRangeWeapon : Kind -> Bool
isLongRangeWeapon kind =
    case kind of
        AssaultRifle ->
            True

        ExpandedAssaultRifle ->
            True

        GatlingLaser ->
            True

        HuntingRifle ->
            True

        LaserRifle ->
            True

        LaserRifleExtCap ->
            True

        Minigun ->
            True

        PlasmaRifle ->
            True

        RedRyderLEBBGun ->
            True

        RocketLauncher ->
            True

        SniperRifle ->
            True

        TurboPlasmaRifle ->
            True

        -- The rest are Falses
        Beer ->
            False

        Fruit ->
            False

        HealingPowder ->
            False

        Stimpak ->
            False

        SuperStimpak ->
            False

        BigBookOfScience ->
            False

        DeansElectronics ->
            False

        FirstAidBook ->
            False

        GunsAndBullets ->
            False

        ScoutHandbook ->
            False

        Robes ->
            False

        LeatherJacket ->
            False

        LeatherArmor ->
            False

        MetalArmor ->
            False

        TeslaArmor ->
            False

        CombatArmor ->
            False

        CombatArmorMk2 ->
            False

        PowerArmor ->
            False

        PowerFist ->
            False

        MegaPowerFist ->
            False

        SuperSledge ->
            False

        GaussPistol ->
            False

        HkP90c ->
            False

        ScopedHuntingRifle ->
            False

        GaussRifle ->
            False

        PancorJackhammer ->
            False

        SawedOffShotgun ->
            False

        Bozar ->
            False

        LaserPistol ->
            False

        PulseRifle ->
            False

        FragGrenade ->
            False

        BBAmmo ->
            False

        SmallEnergyCell ->
            False

        Fmj223 ->
            False

        ShotgunShell ->
            False

        Smg10mm ->
            False

        Jhp10mm ->
            False

        Jhp5mm ->
            False

        MicrofusionCell ->
            False

        Ec2mm ->
            False

        Tool ->
            False

        LockPicks ->
            False

        ElectronicLockpick ->
            False

        AbnormalBrain ->
            False

        ChimpanzeeBrain ->
            False

        HumanBrain ->
            False

        CyberneticBrain ->
            False

        GECK ->
            False

        SkynetAim ->
            False

        MotionSensor ->
            False

        K9 ->
            False

        MeatJerky ->
            False
