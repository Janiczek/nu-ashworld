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
    , ammoArmorClassModifier
    , ammoDamageModifier
    , ammoDamageResistanceModifier
    , armorClass
    , armorDamageResistance
    , armorDamageThreshold
    , baseValue
    , create
    , decoder
    , encode
    , encodeKind
    , findMergeableId
    , getUniqueKey
    , healAmountGenerator
    , healAmountGenerator_
    , isAccurateWeapon
    , isAmmo
    , isArmor
    , isHealing
    , isLongRangeWeapon
    , isUsableAmmoFor
    , isWeapon
    , isWeaponArmorPenetrating
    , kindDecoder
    , name
    , range
    , typeName
    , types
    , usableAmmo
    , usageEffects
    , weaponDamageType
    , weaponStrengthRequirement
    )

import Data.Fight.AttackStyle exposing (AttackStyle(..))
import Data.Fight.DamageType exposing (DamageType(..))
import Data.Map.Location exposing (Size(..))
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
    | CattleProd
    | SuperCattleProd
      -- Shiv
      -- Switchblade
      -- Knife
      -- Combat Knife
    | Wakizashi
    | LittleJesus
    | Ripper
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
    | Pistol223
    | Mauser9mm
      -- 10mm Pistol
    | Pistol14mm
      -- Desert Eagle .44
      -- Desert Eagle (Exp. Mag.)
      -- 44 Magnum Revolver
      -- 44 Magnum (Speed Load)
    | NeedlerPistol
    | GaussPistol
      -- Zip Gun
      ----------
    | Smg10mm
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
    | CombatShotgun
    | HkCaws
    | PancorJackhammer
    | Shotgun
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
    | AlienBlaster
    | LaserPistol
    | MagnetoLaserPistol
      -- Plasma Pistol
      -- Plasma Pistol (Ext. Cap.)
      -- Phazer
    | SolarScorcher
    | PulsePistol
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
    | Flare
      -- Plant spike
    | FragGrenade
      -- Molotov cocktail
      -- Plasma grenade
      -- Pulse grenade
    | HolyHandGrenade
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
    | Ap5mm
      -- Mm762
    | Mm9
    | Ball9mm
    | Ap10mm
    | Ap14mm
    | ExplosiveRocket
    | RocketAp
      -- FlamethrowerFuel
      -- FlamethrowerFuelMk2
    | HnNeedlerCartridge
    | HnApNeedlerCartridge
    | ShotgunShell
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
    [ Beer
    , Fruit
    , HealingPowder
    , Stimpak
    , SuperStimpak
    , BigBookOfScience
    , DeansElectronics
    , FirstAidBook
    , GunsAndBullets
    , ScoutHandbook
    , Robes
    , LeatherJacket
    , LeatherArmor
    , MetalArmor
    , TeslaArmor
    , CombatArmor
    , CombatArmorMk2
    , PowerArmor
    , PowerFist
    , MegaPowerFist
    , CattleProd
    , SuperCattleProd
    , SuperSledge
    , Mauser9mm
    , Pistol14mm
    , GaussPistol
    , Smg10mm
    , HkP90c
    , AssaultRifle
    , ExpandedAssaultRifle
    , HuntingRifle
    , ScopedHuntingRifle
    , RedRyderLEBBGun
    , SniperRifle
    , GaussRifle
    , CombatShotgun
    , HkCaws
    , PancorJackhammer
    , Shotgun
    , SawedOffShotgun
    , Minigun
    , Bozar
    , RocketLauncher
    , AlienBlaster
    , LaserPistol
    , SolarScorcher
    , GatlingLaser
    , LaserRifle
    , LaserRifleExtCap
    , PlasmaRifle
    , TurboPlasmaRifle
    , PulseRifle
    , Flare
    , FragGrenade
    , BBAmmo
    , SmallEnergyCell
    , Fmj223
    , Ap5mm
    , Mm9
    , Ball9mm
    , Ap10mm
    , Ap14mm
    , ExplosiveRocket
    , RocketAp
    , ShotgunShell
    , Jhp10mm
    , Jhp5mm
    , MicrofusionCell
    , Ec2mm
    , Tool
    , LockPicks
    , ElectronicLockpick
    , AbnormalBrain
    , ChimpanzeeBrain
    , HumanBrain
    , CyberneticBrain
    , GECK
    , SkynetAim
    , MotionSensor
    , K9
    , MeatJerky
    , Pistol223
    , Ripper
    , Wakizashi
    , LittleJesus
    , Ripper
    , Pistol223
    , NeedlerPistol
    , MagnetoLaserPistol
    , PulsePistol
    , HolyHandGrenade
    , HnNeedlerCartridge
    , HnApNeedlerCartridge
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

        CattleProd ->
            200

        SuperCattleProd ->
            -- balance?
            200

        Mauser9mm ->
            500

        Pistol14mm ->
            275

        CombatShotgun ->
            275

        HkCaws ->
            950

        Shotgun ->
            160

        AlienBlaster ->
            5000

        SolarScorcher ->
            400

        Flare ->
            35

        Ap5mm ->
            120

        Mm9 ->
            100

        Ball9mm ->
            100

        Ap10mm ->
            100

        Ap14mm ->
            150

        ExplosiveRocket ->
            200

        RocketAp ->
            400

        Pistol223 ->
            3500

        Wakizashi ->
            200

        LittleJesus ->
            200

        Ripper ->
            900

        NeedlerPistol ->
            550

        MagnetoLaserPistol ->
            -- Balance?
            350

        PulsePistol ->
            12500

        HolyHandGrenade ->
            -- Balance?
            1

        HnNeedlerCartridge ->
            250

        HnApNeedlerCartridge ->
            300


{-| This can be both positive and negative, so you need to ADD it in calculations, not SUBTRACT.
-}
ammoDamageResistanceModifier : Kind -> Int
ammoDamageResistanceModifier kind =
    case kind of
        Beer ->
            0

        Fruit ->
            0

        HealingPowder ->
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

        PowerFist ->
            0

        MegaPowerFist ->
            0

        CattleProd ->
            0

        SuperCattleProd ->
            0

        SuperSledge ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        GaussPistol ->
            0

        Smg10mm ->
            0

        HkP90c ->
            0

        AssaultRifle ->
            0

        ExpandedAssaultRifle ->
            0

        HuntingRifle ->
            0

        ScopedHuntingRifle ->
            0

        RedRyderLEBBGun ->
            0

        SniperRifle ->
            0

        GaussRifle ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        PancorJackhammer ->
            0

        Shotgun ->
            0

        SawedOffShotgun ->
            0

        Minigun ->
            0

        Bozar ->
            0

        RocketLauncher ->
            0

        AlienBlaster ->
            0

        LaserPistol ->
            0

        SolarScorcher ->
            0

        GatlingLaser ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0

        PlasmaRifle ->
            0

        TurboPlasmaRifle ->
            0

        PulseRifle ->
            0

        Flare ->
            0

        FragGrenade ->
            0

        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            -20

        ShotgunShell ->
            0

        Jhp10mm ->
            25

        Jhp5mm ->
            35

        MicrofusionCell ->
            0

        Ec2mm ->
            -20

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

        MeatJerky ->
            0

        Ap5mm ->
            -35

        Mm9 ->
            10

        Ball9mm ->
            0

        Ap10mm ->
            -25

        Ap14mm ->
            -50

        ExplosiveRocket ->
            -25

        RocketAp ->
            -50

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


ammoDamageModifier : Kind -> ( Float, Float )
ammoDamageModifier kind =
    case kind of
        BBAmmo ->
            ( 1, 1 )

        SmallEnergyCell ->
            ( 1, 1 )

        Fmj223 ->
            ( 1, 1 )

        Ap5mm ->
            ( 1, 2 )

        Mm9 ->
            ( 1, 2 )

        Ball9mm ->
            ( 1, 1 )

        Ap10mm ->
            ( 1, 2 )

        Ap14mm ->
            ( 1, 2 )

        ExplosiveRocket ->
            ( 1, 1 )

        RocketAp ->
            ( 1, 1 )

        ShotgunShell ->
            ( 1, 1 )

        Jhp10mm ->
            ( 2, 1 )

        Jhp5mm ->
            ( 2, 1 )

        MicrofusionCell ->
            ( 1, 1 )

        Ec2mm ->
            ( 3, 2 )

        --
        Beer ->
            ( 1, 1 )

        Fruit ->
            ( 1, 1 )

        HealingPowder ->
            ( 1, 1 )

        Stimpak ->
            ( 1, 1 )

        SuperStimpak ->
            ( 1, 1 )

        BigBookOfScience ->
            ( 1, 1 )

        DeansElectronics ->
            ( 1, 1 )

        FirstAidBook ->
            ( 1, 1 )

        GunsAndBullets ->
            ( 1, 1 )

        ScoutHandbook ->
            ( 1, 1 )

        Robes ->
            ( 1, 1 )

        LeatherJacket ->
            ( 1, 1 )

        LeatherArmor ->
            ( 1, 1 )

        MetalArmor ->
            ( 1, 1 )

        TeslaArmor ->
            ( 1, 1 )

        CombatArmor ->
            ( 1, 1 )

        CombatArmorMk2 ->
            ( 1, 1 )

        PowerArmor ->
            ( 1, 1 )

        PowerFist ->
            ( 1, 1 )

        MegaPowerFist ->
            ( 1, 1 )

        CattleProd ->
            ( 1, 1 )

        SuperCattleProd ->
            ( 1, 1 )

        SuperSledge ->
            ( 1, 1 )

        Mauser9mm ->
            ( 1, 1 )

        Pistol14mm ->
            ( 1, 1 )

        GaussPistol ->
            ( 1, 1 )

        Smg10mm ->
            ( 1, 1 )

        HkP90c ->
            ( 1, 1 )

        AssaultRifle ->
            ( 1, 1 )

        ExpandedAssaultRifle ->
            ( 1, 1 )

        HuntingRifle ->
            ( 1, 1 )

        ScopedHuntingRifle ->
            ( 1, 1 )

        RedRyderLEBBGun ->
            ( 1, 1 )

        SniperRifle ->
            ( 1, 1 )

        GaussRifle ->
            ( 1, 1 )

        CombatShotgun ->
            ( 1, 1 )

        HkCaws ->
            ( 1, 1 )

        PancorJackhammer ->
            ( 1, 1 )

        Shotgun ->
            ( 1, 1 )

        SawedOffShotgun ->
            ( 1, 1 )

        Minigun ->
            ( 1, 1 )

        Bozar ->
            ( 1, 1 )

        RocketLauncher ->
            ( 1, 1 )

        AlienBlaster ->
            ( 1, 1 )

        LaserPistol ->
            ( 1, 1 )

        SolarScorcher ->
            ( 1, 1 )

        GatlingLaser ->
            ( 1, 1 )

        LaserRifle ->
            ( 1, 1 )

        LaserRifleExtCap ->
            ( 1, 1 )

        PlasmaRifle ->
            ( 1, 1 )

        TurboPlasmaRifle ->
            ( 1, 1 )

        PulseRifle ->
            ( 1, 1 )

        Flare ->
            ( 1, 1 )

        FragGrenade ->
            ( 1, 1 )

        Tool ->
            ( 1, 1 )

        LockPicks ->
            ( 1, 1 )

        ElectronicLockpick ->
            ( 1, 1 )

        AbnormalBrain ->
            ( 1, 1 )

        ChimpanzeeBrain ->
            ( 1, 1 )

        HumanBrain ->
            ( 1, 1 )

        CyberneticBrain ->
            ( 1, 1 )

        GECK ->
            ( 1, 1 )

        SkynetAim ->
            ( 1, 1 )

        MotionSensor ->
            ( 1, 1 )

        K9 ->
            ( 1, 1 )

        MeatJerky ->
            ( 1, 1 )

        Pistol223 ->
            ( 1, 1 )

        Wakizashi ->
            ( 1, 1 )

        LittleJesus ->
            ( 1, 1 )

        Ripper ->
            ( 1, 1 )

        NeedlerPistol ->
            ( 1, 1 )

        MagnetoLaserPistol ->
            ( 1, 1 )

        PulsePistol ->
            ( 1, 1 )

        HolyHandGrenade ->
            ( 1, 1 )

        HnNeedlerCartridge ->
            ( 1, 1 )

        HnApNeedlerCartridge ->
            ( 2, 1 )


{-| This can be negative, you need to ADD it in calculations, not SUBTRACT.
-}
ammoArmorClassModifier : Kind -> Int
ammoArmorClassModifier kind =
    case kind of
        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            -20

        ShotgunShell ->
            -10

        Jhp10mm ->
            0

        Jhp5mm ->
            0

        MicrofusionCell ->
            0

        Ec2mm ->
            -30

        Beer ->
            0

        Fruit ->
            0

        HealingPowder ->
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

        PowerFist ->
            0

        MegaPowerFist ->
            0

        SuperSledge ->
            0

        GaussPistol ->
            0

        Smg10mm ->
            0

        HkP90c ->
            0

        AssaultRifle ->
            0

        ExpandedAssaultRifle ->
            0

        HuntingRifle ->
            0

        ScopedHuntingRifle ->
            0

        RedRyderLEBBGun ->
            0

        SniperRifle ->
            0

        GaussRifle ->
            0

        PancorJackhammer ->
            0

        SawedOffShotgun ->
            0

        Minigun ->
            0

        Bozar ->
            0

        RocketLauncher ->
            0

        LaserPistol ->
            0

        GatlingLaser ->
            0

        LaserRifle ->
            0

        LaserRifleExtCap ->
            0

        PlasmaRifle ->
            0

        TurboPlasmaRifle ->
            0

        PulseRifle ->
            0

        FragGrenade ->
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

        MeatJerky ->
            0

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            -15

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            -10

        HnApNeedlerCartridge ->
            -10


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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistance : DamageType -> Kind -> Int
armorDamageResistance damageType kind =
    case damageType of
        NormalDamage ->
            armorDamageResistanceNormal kind

        Fire ->
            armorDamageResistanceFire kind

        Plasma ->
            armorDamageResistancePlasma kind

        Laser ->
            armorDamageResistanceLaser kind

        Explosion ->
            armorDamageResistanceExplosion kind

        Electrical ->
            armorDamageResistanceElectrical kind

        EMP ->
            armorDamageResistanceEMP kind


armorDamageThreshold : DamageType -> Kind -> Int
armorDamageThreshold damageType kind =
    case damageType of
        NormalDamage ->
            armorDamageThresholdNormal kind

        Fire ->
            armorDamageThresholdFire kind

        Plasma ->
            armorDamageThresholdPlasma kind

        Laser ->
            armorDamageThresholdLaser kind

        Explosion ->
            armorDamageThresholdExplosion kind

        Electrical ->
            armorDamageThresholdElectrical kind

        EMP ->
            armorDamageThresholdEMP kind


armorDamageThresholdNormal : Kind -> Int
armorDamageThresholdNormal kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdExplosion : Kind -> Int
armorDamageThresholdExplosion kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdElectrical : Kind -> Int
armorDamageThresholdElectrical kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdEMP : Kind -> Int
armorDamageThresholdEMP kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdLaser : Kind -> Int
armorDamageThresholdLaser kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdFire : Kind -> Int
armorDamageThresholdFire kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageThresholdPlasma : Kind -> Int
armorDamageThresholdPlasma kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceNormal : Kind -> Int
armorDamageResistanceNormal kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceExplosion : Kind -> Int
armorDamageResistanceExplosion kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceElectrical : Kind -> Int
armorDamageResistanceElectrical kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceEMP : Kind -> Int
armorDamageResistanceEMP kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceLaser : Kind -> Int
armorDamageResistanceLaser kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistanceFire : Kind -> Int
armorDamageResistanceFire kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


armorDamageResistancePlasma : Kind -> Int
armorDamageResistancePlasma kind =
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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            0

        HkCaws ->
            0

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
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
        Beer ->
            JE.string "Beer"

        Fruit ->
            JE.string "Fruit"

        HealingPowder ->
            JE.string "HealingPowder"

        Stimpak ->
            JE.string "Stimpak"

        SuperStimpak ->
            JE.string "SuperStimpak"

        BigBookOfScience ->
            JE.string "BigBookOfScience"

        DeansElectronics ->
            JE.string "DeansElectronics"

        FirstAidBook ->
            JE.string "FirstAidBook"

        GunsAndBullets ->
            JE.string "GunsAndBullets"

        ScoutHandbook ->
            JE.string "ScoutHandbook"

        Robes ->
            JE.string "Robes"

        LeatherJacket ->
            JE.string "LeatherJacket"

        LeatherArmor ->
            JE.string "LeatherArmor"

        MetalArmor ->
            JE.string "MetalArmor"

        TeslaArmor ->
            JE.string "TeslaArmor"

        CombatArmor ->
            JE.string "CombatArmor"

        CombatArmorMk2 ->
            JE.string "CombatArmorMk2"

        PowerArmor ->
            JE.string "PowerArmor"

        PowerFist ->
            JE.string "PowerFist"

        MegaPowerFist ->
            JE.string "MegaPowerFist"

        CattleProd ->
            JE.string "CattleProd"

        SuperCattleProd ->
            JE.string "SuperCattleProd"

        Wakizashi ->
            JE.string "Wakizashi"

        LittleJesus ->
            JE.string "LittleJesus"

        Ripper ->
            JE.string "Ripper"

        SuperSledge ->
            JE.string "SuperSledge"

        Pistol223 ->
            JE.string "Pistol223"

        Mauser9mm ->
            JE.string "Mauser9mm"

        Pistol14mm ->
            JE.string "Pistol14mm"

        NeedlerPistol ->
            JE.string "NeedlerPistol"

        GaussPistol ->
            JE.string "GaussPistol"

        Smg10mm ->
            JE.string "Smg10mm"

        HkP90c ->
            JE.string "HkP90c"

        AssaultRifle ->
            JE.string "AssaultRifle"

        ExpandedAssaultRifle ->
            JE.string "ExpandedAssaultRifle"

        HuntingRifle ->
            JE.string "HuntingRifle"

        ScopedHuntingRifle ->
            JE.string "ScopedHuntingRifle"

        RedRyderLEBBGun ->
            JE.string "RedRyderLEBBGun"

        SniperRifle ->
            JE.string "SniperRifle"

        GaussRifle ->
            JE.string "GaussRifle"

        CombatShotgun ->
            JE.string "CombatShotgun"

        HkCaws ->
            JE.string "HkCaws"

        PancorJackhammer ->
            JE.string "PancorJackhammer"

        Shotgun ->
            JE.string "Shotgun"

        SawedOffShotgun ->
            JE.string "SawedOffShotgun"

        Minigun ->
            JE.string "Minigun"

        Bozar ->
            JE.string "Bozar"

        RocketLauncher ->
            JE.string "RocketLauncher"

        AlienBlaster ->
            JE.string "AlienBlaster"

        LaserPistol ->
            JE.string "LaserPistol"

        MagnetoLaserPistol ->
            JE.string "MagnetoLaserPistol"

        SolarScorcher ->
            JE.string "SolarScorcher"

        PulsePistol ->
            JE.string "PulsePistol"

        GatlingLaser ->
            JE.string "GatlingLaser"

        LaserRifle ->
            JE.string "LaserRifle"

        LaserRifleExtCap ->
            JE.string "LaserRifleExtCap"

        PlasmaRifle ->
            JE.string "PlasmaRifle"

        TurboPlasmaRifle ->
            JE.string "TurboPlasmaRifle"

        PulseRifle ->
            JE.string "PulseRifle"

        Flare ->
            JE.string "Flare"

        FragGrenade ->
            JE.string "FragGrenade"

        HolyHandGrenade ->
            JE.string "HolyHandGrenade"

        BBAmmo ->
            JE.string "BBAmmo"

        SmallEnergyCell ->
            JE.string "SmallEnergyCell"

        Fmj223 ->
            JE.string "Fmj223"

        Ap5mm ->
            JE.string "Ap5mm"

        Mm9 ->
            JE.string "Mm9"

        Ball9mm ->
            JE.string "Ball9mm"

        Ap10mm ->
            JE.string "Ap10mm"

        Ap14mm ->
            JE.string "Ap14mm"

        ExplosiveRocket ->
            JE.string "ExplosiveRocket"

        RocketAp ->
            JE.string "RocketAp"

        HnNeedlerCartridge ->
            JE.string "HnNeedlerCartridge"

        HnApNeedlerCartridge ->
            JE.string "HnApNeedlerCartridge"

        ShotgunShell ->
            JE.string "ShotgunShell"

        Jhp10mm ->
            JE.string "Jhp10mm"

        Jhp5mm ->
            JE.string "Jhp5mm"

        MicrofusionCell ->
            JE.string "MicrofusionCell"

        Ec2mm ->
            JE.string "Ec2mm"

        Tool ->
            JE.string "Tool"

        LockPicks ->
            JE.string "LockPicks"

        ElectronicLockpick ->
            JE.string "ElectronicLockpick"

        AbnormalBrain ->
            JE.string "AbnormalBrain"

        ChimpanzeeBrain ->
            JE.string "ChimpanzeeBrain"

        HumanBrain ->
            JE.string "HumanBrain"

        CyberneticBrain ->
            JE.string "CyberneticBrain"

        GECK ->
            JE.string "GECK"

        SkynetAim ->
            JE.string "SkynetAim"

        MotionSensor ->
            JE.string "MotionSensor"

        K9 ->
            JE.string "K9"

        MeatJerky ->
            JE.string "MeatJerky"


kindDecoder : Decoder Kind
kindDecoder =
    JD.field "tag" JD.string
        |> JD.andThen
            (\ctor ->
                case ctor of
                    "Beer" ->
                        JD.succeed Beer

                    "Fruit" ->
                        JD.succeed Fruit

                    "HealingPowder" ->
                        JD.succeed HealingPowder

                    "Stimpak" ->
                        JD.succeed Stimpak

                    "SuperStimpak" ->
                        JD.succeed SuperStimpak

                    "BigBookOfScience" ->
                        JD.succeed BigBookOfScience

                    "DeansElectronics" ->
                        JD.succeed DeansElectronics

                    "FirstAidBook" ->
                        JD.succeed FirstAidBook

                    "GunsAndBullets" ->
                        JD.succeed GunsAndBullets

                    "ScoutHandbook" ->
                        JD.succeed ScoutHandbook

                    "Robes" ->
                        JD.succeed Robes

                    "LeatherJacket" ->
                        JD.succeed LeatherJacket

                    "LeatherArmor" ->
                        JD.succeed LeatherArmor

                    "MetalArmor" ->
                        JD.succeed MetalArmor

                    "TeslaArmor" ->
                        JD.succeed TeslaArmor

                    "CombatArmor" ->
                        JD.succeed CombatArmor

                    "CombatArmorMk2" ->
                        JD.succeed CombatArmorMk2

                    "PowerArmor" ->
                        JD.succeed PowerArmor

                    "PowerFist" ->
                        JD.succeed PowerFist

                    "MegaPowerFist" ->
                        JD.succeed MegaPowerFist

                    "CattleProd" ->
                        JD.succeed CattleProd

                    "SuperCattleProd" ->
                        JD.succeed SuperCattleProd

                    "Wakizashi" ->
                        JD.succeed Wakizashi

                    "LittleJesus" ->
                        JD.succeed LittleJesus

                    "Ripper" ->
                        JD.succeed Ripper

                    "SuperSledge" ->
                        JD.succeed SuperSledge

                    "Pistol223" ->
                        JD.succeed Pistol223

                    "Mauser9mm" ->
                        JD.succeed Mauser9mm

                    "Pistol14mm" ->
                        JD.succeed Pistol14mm

                    "NeedlerPistol" ->
                        JD.succeed NeedlerPistol

                    "GaussPistol" ->
                        JD.succeed GaussPistol

                    "Smg10mm" ->
                        JD.succeed Smg10mm

                    "HkP90c" ->
                        JD.succeed HkP90c

                    "AssaultRifle" ->
                        JD.succeed AssaultRifle

                    "ExpandedAssaultRifle" ->
                        JD.succeed ExpandedAssaultRifle

                    "HuntingRifle" ->
                        JD.succeed HuntingRifle

                    "ScopedHuntingRifle" ->
                        JD.succeed ScopedHuntingRifle

                    "RedRyderLEBBGun" ->
                        JD.succeed RedRyderLEBBGun

                    "SniperRifle" ->
                        JD.succeed SniperRifle

                    "GaussRifle" ->
                        JD.succeed GaussRifle

                    "CombatShotgun" ->
                        JD.succeed CombatShotgun

                    "HkCaws" ->
                        JD.succeed HkCaws

                    "PancorJackhammer" ->
                        JD.succeed PancorJackhammer

                    "Shotgun" ->
                        JD.succeed Shotgun

                    "SawedOffShotgun" ->
                        JD.succeed SawedOffShotgun

                    "Minigun" ->
                        JD.succeed Minigun

                    "Bozar" ->
                        JD.succeed Bozar

                    "RocketLauncher" ->
                        JD.succeed RocketLauncher

                    "AlienBlaster" ->
                        JD.succeed AlienBlaster

                    "LaserPistol" ->
                        JD.succeed LaserPistol

                    "MagnetoLaserPistol" ->
                        JD.succeed MagnetoLaserPistol

                    "SolarScorcher" ->
                        JD.succeed SolarScorcher

                    "PulsePistol" ->
                        JD.succeed PulsePistol

                    "GatlingLaser" ->
                        JD.succeed GatlingLaser

                    "LaserRifle" ->
                        JD.succeed LaserRifle

                    "LaserRifleExtCap" ->
                        JD.succeed LaserRifleExtCap

                    "PlasmaRifle" ->
                        JD.succeed PlasmaRifle

                    "TurboPlasmaRifle" ->
                        JD.succeed TurboPlasmaRifle

                    "PulseRifle" ->
                        JD.succeed PulseRifle

                    "Flare" ->
                        JD.succeed Flare

                    "FragGrenade" ->
                        JD.succeed FragGrenade

                    "HolyHandGrenade" ->
                        JD.succeed HolyHandGrenade

                    "BBAmmo" ->
                        JD.succeed BBAmmo

                    "SmallEnergyCell" ->
                        JD.succeed SmallEnergyCell

                    "Fmj223" ->
                        JD.succeed Fmj223

                    "Ap5mm" ->
                        JD.succeed Ap5mm

                    "Mm9" ->
                        JD.succeed Mm9

                    "Ball9mm" ->
                        JD.succeed Ball9mm

                    "Ap10mm" ->
                        JD.succeed Ap10mm

                    "Ap14mm" ->
                        JD.succeed Ap14mm

                    "ExplosiveRocket" ->
                        JD.succeed ExplosiveRocket

                    "RocketAp" ->
                        JD.succeed RocketAp

                    "HnNeedlerCartridge" ->
                        JD.succeed HnNeedlerCartridge

                    "HnApNeedlerCartridge" ->
                        JD.succeed HnApNeedlerCartridge

                    "ShotgunShell" ->
                        JD.succeed ShotgunShell

                    "Jhp10mm" ->
                        JD.succeed Jhp10mm

                    "Jhp5mm" ->
                        JD.succeed Jhp5mm

                    "MicrofusionCell" ->
                        JD.succeed MicrofusionCell

                    "Ec2mm" ->
                        JD.succeed Ec2mm

                    "Tool" ->
                        JD.succeed Tool

                    "LockPicks" ->
                        JD.succeed LockPicks

                    "ElectronicLockpick" ->
                        JD.succeed ElectronicLockpick

                    "AbnormalBrain" ->
                        JD.succeed AbnormalBrain

                    "ChimpanzeeBrain" ->
                        JD.succeed ChimpanzeeBrain

                    "HumanBrain" ->
                        JD.succeed HumanBrain

                    "CyberneticBrain" ->
                        JD.succeed CyberneticBrain

                    "GECK" ->
                        JD.succeed GECK

                    "SkynetAim" ->
                        JD.succeed SkynetAim

                    "MotionSensor" ->
                        JD.succeed MotionSensor

                    "K9" ->
                        JD.succeed K9

                    "MeatJerky" ->
                        JD.succeed MeatJerky

                    _ ->
                        JD.fail "Unrecognized constructor"
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
            "YK42B Pulse Rifle"

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

        CattleProd ->
            "Cattle Prod"

        SuperCattleProd ->
            "Super Cattle Prod"

        Mauser9mm ->
            "9mm Mauser"

        Pistol14mm ->
            "14mm Pistol"

        CombatShotgun ->
            "Combat Shotgun"

        HkCaws ->
            "H&K CAWS"

        Shotgun ->
            "Shotgun"

        AlienBlaster ->
            "Alien Blaster"

        SolarScorcher ->
            "Solar Scorcher"

        Flare ->
            "Flare"

        Ap5mm ->
            "5mm AP"

        Mm9 ->
            "9mm"

        Ball9mm ->
            "9mm Ball"

        Ap10mm ->
            "10mm AP"

        Ap14mm ->
            "14mm AP"

        ExplosiveRocket ->
            "Explosive Rocekt"

        RocketAp ->
            "Rocket AP"

        Pistol223 ->
            ".223 Pistol"

        Wakizashi ->
            "Wakizashi"

        LittleJesus ->
            "\"Little Jesus\""

        Ripper ->
            "Ripper"

        NeedlerPistol ->
            "Needler Pistol"

        MagnetoLaserPistol ->
            "Magneto-Laser Pistol"

        PulsePistol ->
            "YK32 Pulse Pistol"

        HolyHandGrenade ->
            "Holy Hand Grenade"

        HnNeedlerCartridge ->
            "HN Needler Cartridge"

        HnApNeedlerCartridge ->
            "HN AP Needler Cartridge"


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

        CattleProd ->
            []

        SuperCattleProd ->
            []

        Mauser9mm ->
            []

        Pistol14mm ->
            []

        CombatShotgun ->
            []

        HkCaws ->
            []

        Shotgun ->
            []

        AlienBlaster ->
            []

        SolarScorcher ->
            []

        Flare ->
            -- Maybe reduce darkness? Probably has no use in this game.
            []

        Ap5mm ->
            []

        Mm9 ->
            []

        Ball9mm ->
            []

        Ap10mm ->
            []

        Ap14mm ->
            []

        ExplosiveRocket ->
            []

        RocketAp ->
            []

        Pistol223 ->
            []

        Wakizashi ->
            []

        LittleJesus ->
            []

        Ripper ->
            []

        NeedlerPistol ->
            []

        MagnetoLaserPistol ->
            []

        PulsePistol ->
            []

        HolyHandGrenade ->
            []

        HnNeedlerCartridge ->
            []

        HnApNeedlerCartridge ->
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


isAmmoType : Type -> Bool
isAmmoType type__ =
    case type__ of
        Ammo ->
            True

        Consumable ->
            False

        Armor ->
            False

        UnarmedWeapon ->
            False

        MeleeWeapon ->
            False

        ThrownWeapon ->
            False

        SmallGun ->
            False

        BigGun ->
            False

        EnergyWeapon ->
            False

        Book ->
            False

        Misc ->
            False


{-| Why the List: some weapons can be used in melee and be thrown, eg. Rock.
Logic.neededSkill needs to take this + the chosen AttackStyle into account.
-}
types : Kind -> List Type
types kind =
    case kind of
        Fruit ->
            [ Consumable ]

        HealingPowder ->
            [ Consumable ]

        Stimpak ->
            [ Consumable ]

        BigBookOfScience ->
            [ Book ]

        DeansElectronics ->
            [ Book ]

        FirstAidBook ->
            [ Book ]

        GunsAndBullets ->
            [ Book ]

        ScoutHandbook ->
            [ Book ]

        Robes ->
            [ Armor ]

        LeatherJacket ->
            [ Armor ]

        LeatherArmor ->
            [ Armor ]

        MetalArmor ->
            [ Armor ]

        Beer ->
            [ Misc ]

        RedRyderLEBBGun ->
            [ SmallGun ]

        BBAmmo ->
            [ Ammo ]

        ElectronicLockpick ->
            [ Misc ]

        AbnormalBrain ->
            [ Misc ]

        ChimpanzeeBrain ->
            [ Misc ]

        HumanBrain ->
            [ Misc ]

        CyberneticBrain ->
            [ Misc ]

        MeatJerky ->
            [ Misc ]

        HuntingRifle ->
            [ SmallGun ]

        ScopedHuntingRifle ->
            [ SmallGun ]

        SuperStimpak ->
            [ Consumable ]

        TeslaArmor ->
            [ Armor ]

        CombatArmor ->
            [ Armor ]

        CombatArmorMk2 ->
            [ Armor ]

        PowerArmor ->
            [ Armor ]

        SuperSledge ->
            [ MeleeWeapon ]

        PowerFist ->
            [ UnarmedWeapon ]

        MegaPowerFist ->
            [ UnarmedWeapon ]

        FragGrenade ->
            [ ThrownWeapon ]

        Bozar ->
            [ BigGun ]

        SawedOffShotgun ->
            [ SmallGun ]

        SniperRifle ->
            [ SmallGun ]

        AssaultRifle ->
            [ SmallGun ]

        ExpandedAssaultRifle ->
            [ SmallGun ]

        PancorJackhammer ->
            [ SmallGun ]

        HkP90c ->
            [ SmallGun ]

        LaserPistol ->
            [ EnergyWeapon ]

        PlasmaRifle ->
            [ EnergyWeapon ]

        GatlingLaser ->
            [ EnergyWeapon ]

        TurboPlasmaRifle ->
            [ EnergyWeapon ]

        GaussRifle ->
            [ SmallGun ]

        GaussPistol ->
            [ SmallGun ]

        PulseRifle ->
            [ EnergyWeapon ]

        SmallEnergyCell ->
            [ Ammo ]

        Fmj223 ->
            [ Ammo ]

        ShotgunShell ->
            [ Ammo ]

        Smg10mm ->
            [ SmallGun ]

        Jhp10mm ->
            [ Ammo ]

        Jhp5mm ->
            [ Ammo ]

        MicrofusionCell ->
            [ Ammo ]

        Ec2mm ->
            [ Ammo ]

        Tool ->
            [ Misc ]

        GECK ->
            [ Misc ]

        SkynetAim ->
            [ Misc ]

        MotionSensor ->
            [ Misc ]

        K9 ->
            [ Misc ]

        LockPicks ->
            [ Misc ]

        Minigun ->
            [ BigGun ]

        RocketLauncher ->
            [ BigGun ]

        LaserRifle ->
            [ EnergyWeapon ]

        LaserRifleExtCap ->
            [ EnergyWeapon ]

        CattleProd ->
            [ MeleeWeapon ]

        SuperCattleProd ->
            [ MeleeWeapon ]

        Mauser9mm ->
            [ SmallGun ]

        Pistol14mm ->
            [ SmallGun ]

        CombatShotgun ->
            [ SmallGun ]

        HkCaws ->
            [ SmallGun ]

        Shotgun ->
            [ SmallGun ]

        AlienBlaster ->
            [ EnergyWeapon ]

        SolarScorcher ->
            [ EnergyWeapon ]

        Flare ->
            [ ThrownWeapon ]

        Ap5mm ->
            [ Ammo ]

        Mm9 ->
            [ Ammo ]

        Ball9mm ->
            [ Ammo ]

        Ap10mm ->
            [ Ammo ]

        Ap14mm ->
            [ Ammo ]

        ExplosiveRocket ->
            [ Ammo ]

        RocketAp ->
            [ Ammo ]

        Pistol223 ->
            [ SmallGun ]

        Wakizashi ->
            [ MeleeWeapon ]

        LittleJesus ->
            [ MeleeWeapon ]

        Ripper ->
            [ MeleeWeapon ]

        NeedlerPistol ->
            [ SmallGun ]

        MagnetoLaserPistol ->
            [ EnergyWeapon ]

        PulsePistol ->
            [ EnergyWeapon ]

        HolyHandGrenade ->
            [ ThrownWeapon ]

        HnNeedlerCartridge ->
            [ Ammo ]

        HnApNeedlerCartridge ->
            [ Ammo ]


isWeapon : Kind -> Bool
isWeapon kind =
    List.any isWeaponType (types kind)


isAmmo : Kind -> Bool
isAmmo kind =
    List.any isAmmoType (types kind)


isArmor : Kind -> Bool
isArmor kind =
    List.member Armor (types kind)


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
            25

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

        CattleProd ->
            1

        SuperCattleProd ->
            1

        Mauser9mm ->
            22

        Pistol14mm ->
            24

        CombatShotgun ->
            22

        HkCaws ->
            30

        Shotgun ->
            14

        AlienBlaster ->
            10

        SolarScorcher ->
            20

        Flare ->
            15

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            30

        Wakizashi ->
            1

        LittleJesus ->
            1

        Ripper ->
            1

        NeedlerPistol ->
            24

        MagnetoLaserPistol ->
            35

        PulsePistol ->
            15

        HolyHandGrenade ->
            20

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


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
            25

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

        CattleProd ->
            1

        SuperCattleProd ->
            1

        Mauser9mm ->
            22

        Pistol14mm ->
            24

        CombatShotgun ->
            22

        HkCaws ->
            30

        Shotgun ->
            14

        AlienBlaster ->
            10

        SolarScorcher ->
            20

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            30

        Wakizashi ->
            1

        LittleJesus ->
            1

        Ripper ->
            1

        NeedlerPistol ->
            24

        MagnetoLaserPistol ->
            35

        PulsePistol ->
            15

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


isAccurateWeapon : Kind -> Bool
isAccurateWeapon kind =
    case kind of
        Mauser9mm ->
            True

        Pistol14mm ->
            True

        AlienBlaster ->
            True

        CattleProd ->
            True

        CombatShotgun ->
            True

        Flare ->
            True

        GaussPistol ->
            True

        GaussRifle ->
            True

        HkCaws ->
            True

        PancorJackhammer ->
            True

        SawedOffShotgun ->
            True

        Shotgun ->
            True

        SolarScorcher ->
            True

        SuperCattleProd ->
            True

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

        Smg10mm ->
            False

        HkP90c ->
            False

        AssaultRifle ->
            False

        ExpandedAssaultRifle ->
            False

        HuntingRifle ->
            False

        ScopedHuntingRifle ->
            False

        RedRyderLEBBGun ->
            False

        SniperRifle ->
            False

        Minigun ->
            False

        Bozar ->
            False

        RocketLauncher ->
            False

        LaserPistol ->
            False

        GatlingLaser ->
            False

        LaserRifle ->
            False

        LaserRifleExtCap ->
            False

        PlasmaRifle ->
            False

        TurboPlasmaRifle ->
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

        Ap5mm ->
            False

        Mm9 ->
            False

        Ball9mm ->
            False

        Ap10mm ->
            False

        Ap14mm ->
            False

        ExplosiveRocket ->
            False

        RocketAp ->
            False

        Pistol223 ->
            False

        Wakizashi ->
            False

        LittleJesus ->
            False

        Ripper ->
            False

        NeedlerPistol ->
            False

        MagnetoLaserPistol ->
            False

        PulsePistol ->
            False

        HolyHandGrenade ->
            False

        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False


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
            20

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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            18

        HkCaws ->
            20

        Shotgun ->
            0

        AlienBlaster ->
            0

        SolarScorcher ->
            0

        Flare ->
            0

        Ap5mm ->
            0

        Mm9 ->
            0

        Ball9mm ->
            0

        Ap10mm ->
            0

        Ap14mm ->
            0

        ExplosiveRocket ->
            0

        RocketAp ->
            0

        Pistol223 ->
            0

        Wakizashi ->
            0

        LittleJesus ->
            0

        Ripper ->
            0

        NeedlerPistol ->
            0

        MagnetoLaserPistol ->
            0

        PulsePistol ->
            0

        HolyHandGrenade ->
            0

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0


range : AttackStyle -> Kind -> Int
range attackStyle kind =
    case attackStyle of
        UnarmedUnaimed ->
            unaimedRange kind

        UnarmedAimed _ ->
            aimedRange kind

        MeleeUnaimed ->
            unaimedRange kind

        MeleeAimed _ ->
            aimedRange kind

        Throw ->
            unaimedRange kind

        ShootSingleUnaimed ->
            unaimedRange kind

        ShootSingleAimed _ ->
            aimedRange kind

        ShootBurst ->
            burstRange kind


{-| In other words, does the Weapon Penetrate perk apply?
-}
isWeaponArmorPenetrating : Kind -> Bool
isWeaponArmorPenetrating kind =
    case kind of
        Pistol223 ->
            True

        Wakizashi ->
            True

        LittleJesus ->
            True

        Ripper ->
            True

        NeedlerPistol ->
            True

        MagnetoLaserPistol ->
            True

        PulsePistol ->
            True

        HolyHandGrenade ->
            True

        PulseRifle ->
            True

        PowerFist ->
            True

        MegaPowerFist ->
            True

        -- The rest are Falses
        AssaultRifle ->
            False

        ExpandedAssaultRifle ->
            False

        GatlingLaser ->
            False

        HuntingRifle ->
            False

        LaserRifle ->
            False

        LaserRifleExtCap ->
            False

        Minigun ->
            False

        PlasmaRifle ->
            False

        RedRyderLEBBGun ->
            False

        RocketLauncher ->
            False

        SniperRifle ->
            False

        TurboPlasmaRifle ->
            False

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

        CattleProd ->
            False

        SuperCattleProd ->
            False

        Mauser9mm ->
            False

        Pistol14mm ->
            False

        CombatShotgun ->
            False

        HkCaws ->
            False

        Shotgun ->
            False

        AlienBlaster ->
            False

        SolarScorcher ->
            False

        Flare ->
            False

        Ap5mm ->
            False

        Mm9 ->
            False

        Ball9mm ->
            False

        Ap10mm ->
            False

        Ap14mm ->
            False

        ExplosiveRocket ->
            False

        RocketAp ->
            False

        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False


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

        CattleProd ->
            False

        SuperCattleProd ->
            False

        Mauser9mm ->
            False

        Pistol14mm ->
            False

        CombatShotgun ->
            False

        HkCaws ->
            False

        Shotgun ->
            False

        AlienBlaster ->
            False

        SolarScorcher ->
            False

        Flare ->
            False

        Ap5mm ->
            False

        Mm9 ->
            False

        Ball9mm ->
            False

        Ap10mm ->
            False

        Ap14mm ->
            False

        ExplosiveRocket ->
            False

        RocketAp ->
            False

        Pistol223 ->
            False

        Wakizashi ->
            False

        LittleJesus ->
            False

        Ripper ->
            False

        NeedlerPistol ->
            False

        MagnetoLaserPistol ->
            False

        PulsePistol ->
            False

        HolyHandGrenade ->
            False

        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False


weaponStrengthRequirement : Kind -> Int
weaponStrengthRequirement kind =
    case kind of
        PowerFist ->
            1

        MegaPowerFist ->
            1

        SuperSledge ->
            5

        GaussPistol ->
            4

        Smg10mm ->
            4

        HkP90c ->
            4

        AssaultRifle ->
            5

        ExpandedAssaultRifle ->
            5

        HuntingRifle ->
            5

        ScopedHuntingRifle ->
            5

        RedRyderLEBBGun ->
            4

        SniperRifle ->
            5

        GaussRifle ->
            6

        PancorJackhammer ->
            5

        SawedOffShotgun ->
            4

        Minigun ->
            7

        Bozar ->
            6

        RocketLauncher ->
            6

        LaserPistol ->
            3

        GatlingLaser ->
            6

        LaserRifle ->
            6

        LaserRifleExtCap ->
            6

        PlasmaRifle ->
            6

        TurboPlasmaRifle ->
            6

        PulseRifle ->
            6

        FragGrenade ->
            3

        Beer ->
            1

        Fruit ->
            1

        HealingPowder ->
            1

        Stimpak ->
            1

        SuperStimpak ->
            1

        BigBookOfScience ->
            1

        DeansElectronics ->
            1

        FirstAidBook ->
            1

        GunsAndBullets ->
            1

        ScoutHandbook ->
            1

        Robes ->
            1

        LeatherJacket ->
            1

        LeatherArmor ->
            1

        MetalArmor ->
            1

        TeslaArmor ->
            1

        CombatArmor ->
            1

        CombatArmorMk2 ->
            1

        PowerArmor ->
            1

        BBAmmo ->
            1

        SmallEnergyCell ->
            1

        Fmj223 ->
            1

        ShotgunShell ->
            1

        Jhp10mm ->
            1

        Jhp5mm ->
            1

        MicrofusionCell ->
            1

        Ec2mm ->
            1

        Tool ->
            1

        LockPicks ->
            1

        ElectronicLockpick ->
            1

        AbnormalBrain ->
            1

        ChimpanzeeBrain ->
            1

        HumanBrain ->
            1

        CyberneticBrain ->
            1

        GECK ->
            1

        SkynetAim ->
            1

        MotionSensor ->
            1

        K9 ->
            1

        MeatJerky ->
            1

        CattleProd ->
            4

        SuperCattleProd ->
            4

        Mauser9mm ->
            3

        Pistol14mm ->
            4

        CombatShotgun ->
            5

        HkCaws ->
            6

        Shotgun ->
            4

        AlienBlaster ->
            2

        SolarScorcher ->
            3

        Flare ->
            1

        Ap5mm ->
            1

        Mm9 ->
            1

        Ball9mm ->
            1

        Ap10mm ->
            1

        Ap14mm ->
            1

        ExplosiveRocket ->
            1

        RocketAp ->
            1

        Pistol223 ->
            5

        Wakizashi ->
            2

        LittleJesus ->
            2

        Ripper ->
            4

        NeedlerPistol ->
            3

        MagnetoLaserPistol ->
            3

        PulsePistol ->
            3

        HolyHandGrenade ->
            2

        HnNeedlerCartridge ->
            1

        HnApNeedlerCartridge ->
            1


weaponDamageType : Kind -> Maybe DamageType
weaponDamageType kind =
    case kind of
        PowerFist ->
            Just NormalDamage

        MegaPowerFist ->
            Just NormalDamage

        SuperSledge ->
            Just NormalDamage

        GaussPistol ->
            Just NormalDamage

        Smg10mm ->
            Just NormalDamage

        HkP90c ->
            Just NormalDamage

        AssaultRifle ->
            Just NormalDamage

        ExpandedAssaultRifle ->
            Just NormalDamage

        HuntingRifle ->
            Just NormalDamage

        ScopedHuntingRifle ->
            Just NormalDamage

        RedRyderLEBBGun ->
            Just NormalDamage

        SniperRifle ->
            Just NormalDamage

        GaussRifle ->
            Just NormalDamage

        PancorJackhammer ->
            Just NormalDamage

        SawedOffShotgun ->
            Just NormalDamage

        Minigun ->
            Just NormalDamage

        Bozar ->
            Just NormalDamage

        RocketLauncher ->
            Just Explosion

        LaserPistol ->
            Just Laser

        GatlingLaser ->
            Just Laser

        LaserRifle ->
            Just Laser

        LaserRifleExtCap ->
            Just Laser

        PlasmaRifle ->
            Just Plasma

        TurboPlasmaRifle ->
            Just Plasma

        PulseRifle ->
            Just Electrical

        FragGrenade ->
            Just Explosion

        Beer ->
            Nothing

        Fruit ->
            Nothing

        HealingPowder ->
            Nothing

        Stimpak ->
            Nothing

        SuperStimpak ->
            Nothing

        BigBookOfScience ->
            Nothing

        DeansElectronics ->
            Nothing

        FirstAidBook ->
            Nothing

        GunsAndBullets ->
            Nothing

        ScoutHandbook ->
            Nothing

        Robes ->
            Nothing

        LeatherJacket ->
            Nothing

        LeatherArmor ->
            Nothing

        MetalArmor ->
            Nothing

        TeslaArmor ->
            Nothing

        CombatArmor ->
            Nothing

        CombatArmorMk2 ->
            Nothing

        PowerArmor ->
            Nothing

        BBAmmo ->
            Nothing

        SmallEnergyCell ->
            Nothing

        Fmj223 ->
            Nothing

        ShotgunShell ->
            Nothing

        Jhp10mm ->
            Nothing

        Jhp5mm ->
            Nothing

        MicrofusionCell ->
            Nothing

        Ec2mm ->
            Nothing

        Tool ->
            Nothing

        LockPicks ->
            Nothing

        ElectronicLockpick ->
            Nothing

        AbnormalBrain ->
            Nothing

        ChimpanzeeBrain ->
            Nothing

        HumanBrain ->
            Nothing

        CyberneticBrain ->
            Nothing

        GECK ->
            Nothing

        SkynetAim ->
            Nothing

        MotionSensor ->
            Nothing

        K9 ->
            Nothing

        MeatJerky ->
            Nothing

        CattleProd ->
            Just Electrical

        SuperCattleProd ->
            Just Electrical

        Mauser9mm ->
            Just NormalDamage

        Pistol14mm ->
            Just NormalDamage

        CombatShotgun ->
            Just NormalDamage

        HkCaws ->
            Just NormalDamage

        Shotgun ->
            Just NormalDamage

        AlienBlaster ->
            Just Electrical

        SolarScorcher ->
            Just Laser

        Flare ->
            Just NormalDamage

        Ap5mm ->
            Nothing

        Mm9 ->
            Nothing

        Ball9mm ->
            Nothing

        Ap10mm ->
            Nothing

        Ap14mm ->
            Nothing

        ExplosiveRocket ->
            Nothing

        RocketAp ->
            Nothing

        Pistol223 ->
            Just NormalDamage

        Wakizashi ->
            Just NormalDamage

        LittleJesus ->
            Just NormalDamage

        Ripper ->
            Just NormalDamage

        NeedlerPistol ->
            Just NormalDamage

        MagnetoLaserPistol ->
            Just Laser

        PulsePistol ->
            Just Electrical

        HolyHandGrenade ->
            Just Explosion

        HnNeedlerCartridge ->
            Nothing

        HnApNeedlerCartridge ->
            Nothing


{-| One gotcha: in case of thrown weapons they themselves are their own ammo.
This makes throwing work more or less the same as ranged weapons.
-}
usableAmmo : Kind -> List Kind
usableAmmo kind =
    case kind of
        Beer ->
            []

        Fruit ->
            []

        HealingPowder ->
            []

        Stimpak ->
            []

        SuperStimpak ->
            []

        BigBookOfScience ->
            []

        DeansElectronics ->
            []

        FirstAidBook ->
            []

        GunsAndBullets ->
            []

        ScoutHandbook ->
            []

        Robes ->
            []

        LeatherJacket ->
            []

        LeatherArmor ->
            []

        MetalArmor ->
            []

        TeslaArmor ->
            []

        CombatArmor ->
            []

        CombatArmorMk2 ->
            []

        PowerArmor ->
            []

        PowerFist ->
            [ SmallEnergyCell ]

        MegaPowerFist ->
            [ SmallEnergyCell ]

        CattleProd ->
            [ SmallEnergyCell ]

        SuperCattleProd ->
            [ SmallEnergyCell ]

        SuperSledge ->
            []

        Mauser9mm ->
            [ Mm9, Ball9mm ]

        Pistol14mm ->
            [ Ap14mm ]

        GaussPistol ->
            [ Ec2mm ]

        Smg10mm ->
            [ Ap10mm, Jhp10mm ]

        HkP90c ->
            [ Ap10mm, Jhp10mm ]

        AssaultRifle ->
            [ Ap5mm, Jhp5mm ]

        ExpandedAssaultRifle ->
            [ Ap5mm, Jhp5mm ]

        HuntingRifle ->
            [ Fmj223 ]

        ScopedHuntingRifle ->
            [ Fmj223 ]

        RedRyderLEBBGun ->
            [ BBAmmo ]

        SniperRifle ->
            [ Fmj223 ]

        GaussRifle ->
            [ Ec2mm ]

        CombatShotgun ->
            [ ShotgunShell ]

        HkCaws ->
            [ ShotgunShell ]

        PancorJackhammer ->
            [ ShotgunShell ]

        Shotgun ->
            [ ShotgunShell ]

        SawedOffShotgun ->
            [ ShotgunShell ]

        Minigun ->
            [ Ap5mm, Jhp5mm ]

        Bozar ->
            [ Fmj223 ]

        RocketLauncher ->
            [ ExplosiveRocket, RocketAp ]

        AlienBlaster ->
            [ SmallEnergyCell ]

        LaserPistol ->
            [ SmallEnergyCell ]

        SolarScorcher ->
            -- TODO if we ever have darkness, this weapon needs to stop working
            []

        GatlingLaser ->
            [ MicrofusionCell ]

        LaserRifle ->
            [ MicrofusionCell ]

        LaserRifleExtCap ->
            [ MicrofusionCell ]

        PlasmaRifle ->
            [ MicrofusionCell ]

        TurboPlasmaRifle ->
            [ MicrofusionCell ]

        PulseRifle ->
            [ MicrofusionCell ]

        Flare ->
            [ Flare ]

        FragGrenade ->
            [ FragGrenade ]

        BBAmmo ->
            []

        SmallEnergyCell ->
            []

        Fmj223 ->
            []

        ShotgunShell ->
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

        LockPicks ->
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

        GECK ->
            []

        SkynetAim ->
            []

        MotionSensor ->
            []

        K9 ->
            []

        MeatJerky ->
            []

        Ap5mm ->
            []

        Mm9 ->
            []

        Ball9mm ->
            []

        Ap10mm ->
            []

        Ap14mm ->
            []

        ExplosiveRocket ->
            []

        RocketAp ->
            []

        Pistol223 ->
            [ Fmj223 ]

        Wakizashi ->
            []

        LittleJesus ->
            []

        Ripper ->
            [ SmallEnergyCell ]

        NeedlerPistol ->
            [ HnNeedlerCartridge, HnApNeedlerCartridge ]

        MagnetoLaserPistol ->
            [ SmallEnergyCell ]

        PulsePistol ->
            [ SmallEnergyCell ]

        HolyHandGrenade ->
            [ HolyHandGrenade ]

        HnNeedlerCartridge ->
            []

        HnApNeedlerCartridge ->
            []


isUsableAmmoFor : Kind -> Kind -> Bool
isUsableAmmoFor weapon ammo =
    List.member ammo (usableAmmo weapon)
