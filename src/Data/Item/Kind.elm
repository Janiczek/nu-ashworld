module Data.Item.Kind exposing
    ( Kind(..), codec
    , all, allNonempty, allHealing, allHealingNonempty
    , name, baseValue, types
    , usageEffects
    , isHealing
    , healAmount
    , isAmmo
    , ammoArmorClassModifier, ammoDamageModifier, ammoDamageResistanceModifier
    , carBatteryChargePromileAmount
    , isArmor
    , armorClass, armorDamageResistance, armorDamageThreshold
    , isWeapon, isLongRangeWeapon, isWeaponArmorPenetrating, isAccurateWeapon
    , range, weaponStrengthRequirement
    , weaponDamageType, weaponDamage, shotsPerBurst, isTwoHandedWeapon
    , usableAmmoForWeapon, isUsableAmmoForWeapon
    )

{-|

@docs Kind, codec
@docs all, allNonempty, allHealing, allHealingNonempty

@docs name, baseValue, types
@docs usageEffects


## Consumables

@docs isHealing
@docs healAmount


## Ammo

@docs isAmmo
@docs ammoArmorClassModifier, ammoDamageModifier, ammoDamageResistanceModifier
@docs carBatteryChargePromileAmount


## Armor

@docs isArmor
@docs armorClass, armorDamageResistance, armorDamageThreshold


## Weapons

@docs isWeapon, isLongRangeWeapon, isWeaponArmorPenetrating, isAccurateWeapon
@docs range, weaponStrengthRequirement
@docs weaponDamageType, weaponDamage, shotsPerBurst, isTwoHandedWeapon
@docs usableAmmoForWeapon, isUsableAmmoForWeapon

TODO weight : Kind -> Int

-}

import Codec exposing (Codec)
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle)
import Data.Fight.DamageType as DamageType exposing (DamageType)
import Data.Item.Effect as Effect exposing (Effect)
import Data.Item.Type as Type exposing (Type)
import Data.Skill as Skill


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
    | Knife
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
      -- AlienBlaster
    | LaserPistol
    | MagnetoLaserPistol
      -- Plasma Pistol
      -- Plasma Pistol (Ext. Cap.)
      -- Phazer
      -- SolarScorcher
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
      -- HolyHandGrenade
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
    | SuperToolKit
    | FuelCellRegulator
    | FuelCellController
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
    | TankerFob
    | SilverGeckoPelt
    | GoldenGeckoPelt
    | FireGeckoPelt


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

    -- AlienBlaster
    , LaserPistol

    -- SolarScorcher
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
    , SuperToolKit
    , FuelCellRegulator
    , FuelCellController
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
    , TankerFob
    , Pistol223
    , Ripper
    , Knife
    , Wakizashi
    , LittleJesus
    , Ripper
    , Pistol223
    , NeedlerPistol
    , MagnetoLaserPistol
    , PulsePistol

    -- HolyHandGrenade
    , HnNeedlerCartridge
    , HnApNeedlerCartridge
    , SilverGeckoPelt
    , GoldenGeckoPelt
    , FireGeckoPelt
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
    List.any Effect.isHealing (usageEffects kind)


codec : Codec Kind
codec =
    Codec.custom
        (\silverGeckoPeltEncoder goldenGeckoPeltEncoder fireGeckoPeltEncoder beerEncoder fruitEncoder healingPowderEncoder stimpakEncoder superStimpakEncoder bigBookOfScienceEncoder deansElectronicsEncoder firstAidBookEncoder gunsAndBulletsEncoder scoutHandbookEncoder robesEncoder leatherJacketEncoder leatherArmorEncoder metalArmorEncoder teslaArmorEncoder combatArmorEncoder combatArmorMk2Encoder powerArmorEncoder powerFistEncoder megaPowerFistEncoder cattleProdEncoder superCattleProdEncoder knifeEncoder wakizashiEncoder littleJesusEncoder ripperEncoder superSledgeEncoder pistol223Encoder mauser9mmEncoder pistol14mmEncoder needlerPistolEncoder gaussPistolEncoder smg10mmEncoder hkP90cEncoder assaultRifleEncoder expandedAssaultRifleEncoder huntingRifleEncoder scopedHuntingRifleEncoder redRyderLEBBGunEncoder sniperRifleEncoder gaussRifleEncoder combatShotgunEncoder hkCawsEncoder pancorJackhammerEncoder shotgunEncoder sawedOffShotgunEncoder minigunEncoder bozarEncoder rocketLauncherEncoder laserPistolEncoder magnetoLaserPistolEncoder pulsePistolEncoder gatlingLaserEncoder laserRifleEncoder laserRifleExtCapEncoder plasmaRifleEncoder turboPlasmaRifleEncoder pulseRifleEncoder flareEncoder fragGrenadeEncoder bBAmmoEncoder smallEnergyCellEncoder fmj223Encoder ap5mmEncoder mm9Encoder ball9mmEncoder ap10mmEncoder ap14mmEncoder explosiveRocketEncoder rocketApEncoder hnNeedlerCartridgeEncoder hnApNeedlerCartridgeEncoder shotgunShellEncoder jhp10mmEncoder jhp5mmEncoder microfusionCellEncoder ec2mmEncoder toolEncoder superToolKitEncoder fuelCellRegulatorEncoder fuelCellControllerEncoder lockPicksEncoder electronicLockpickEncoder abnormalBrainEncoder chimpanzeeBrainEncoder humanBrainEncoder cyberneticBrainEncoder gECKEncoder skynetAimEncoder motionSensorEncoder k9Encoder meatJerkyEncoder tankerFobEncoder value ->
            case value of
                Beer ->
                    beerEncoder

                Fruit ->
                    fruitEncoder

                HealingPowder ->
                    healingPowderEncoder

                Stimpak ->
                    stimpakEncoder

                SuperStimpak ->
                    superStimpakEncoder

                BigBookOfScience ->
                    bigBookOfScienceEncoder

                DeansElectronics ->
                    deansElectronicsEncoder

                FirstAidBook ->
                    firstAidBookEncoder

                GunsAndBullets ->
                    gunsAndBulletsEncoder

                ScoutHandbook ->
                    scoutHandbookEncoder

                Robes ->
                    robesEncoder

                LeatherJacket ->
                    leatherJacketEncoder

                LeatherArmor ->
                    leatherArmorEncoder

                MetalArmor ->
                    metalArmorEncoder

                TeslaArmor ->
                    teslaArmorEncoder

                CombatArmor ->
                    combatArmorEncoder

                CombatArmorMk2 ->
                    combatArmorMk2Encoder

                PowerArmor ->
                    powerArmorEncoder

                PowerFist ->
                    powerFistEncoder

                MegaPowerFist ->
                    megaPowerFistEncoder

                CattleProd ->
                    cattleProdEncoder

                SuperCattleProd ->
                    superCattleProdEncoder

                Knife ->
                    knifeEncoder

                Wakizashi ->
                    wakizashiEncoder

                LittleJesus ->
                    littleJesusEncoder

                Ripper ->
                    ripperEncoder

                SuperSledge ->
                    superSledgeEncoder

                Pistol223 ->
                    pistol223Encoder

                Mauser9mm ->
                    mauser9mmEncoder

                Pistol14mm ->
                    pistol14mmEncoder

                NeedlerPistol ->
                    needlerPistolEncoder

                GaussPistol ->
                    gaussPistolEncoder

                Smg10mm ->
                    smg10mmEncoder

                HkP90c ->
                    hkP90cEncoder

                AssaultRifle ->
                    assaultRifleEncoder

                ExpandedAssaultRifle ->
                    expandedAssaultRifleEncoder

                HuntingRifle ->
                    huntingRifleEncoder

                ScopedHuntingRifle ->
                    scopedHuntingRifleEncoder

                RedRyderLEBBGun ->
                    redRyderLEBBGunEncoder

                SniperRifle ->
                    sniperRifleEncoder

                GaussRifle ->
                    gaussRifleEncoder

                CombatShotgun ->
                    combatShotgunEncoder

                HkCaws ->
                    hkCawsEncoder

                PancorJackhammer ->
                    pancorJackhammerEncoder

                Shotgun ->
                    shotgunEncoder

                SawedOffShotgun ->
                    sawedOffShotgunEncoder

                Minigun ->
                    minigunEncoder

                Bozar ->
                    bozarEncoder

                RocketLauncher ->
                    rocketLauncherEncoder

                LaserPistol ->
                    laserPistolEncoder

                MagnetoLaserPistol ->
                    magnetoLaserPistolEncoder

                PulsePistol ->
                    pulsePistolEncoder

                GatlingLaser ->
                    gatlingLaserEncoder

                LaserRifle ->
                    laserRifleEncoder

                LaserRifleExtCap ->
                    laserRifleExtCapEncoder

                PlasmaRifle ->
                    plasmaRifleEncoder

                TurboPlasmaRifle ->
                    turboPlasmaRifleEncoder

                PulseRifle ->
                    pulseRifleEncoder

                Flare ->
                    flareEncoder

                FragGrenade ->
                    fragGrenadeEncoder

                BBAmmo ->
                    bBAmmoEncoder

                SmallEnergyCell ->
                    smallEnergyCellEncoder

                Fmj223 ->
                    fmj223Encoder

                Ap5mm ->
                    ap5mmEncoder

                Mm9 ->
                    mm9Encoder

                Ball9mm ->
                    ball9mmEncoder

                Ap10mm ->
                    ap10mmEncoder

                Ap14mm ->
                    ap14mmEncoder

                ExplosiveRocket ->
                    explosiveRocketEncoder

                RocketAp ->
                    rocketApEncoder

                HnNeedlerCartridge ->
                    hnNeedlerCartridgeEncoder

                HnApNeedlerCartridge ->
                    hnApNeedlerCartridgeEncoder

                ShotgunShell ->
                    shotgunShellEncoder

                Jhp10mm ->
                    jhp10mmEncoder

                Jhp5mm ->
                    jhp5mmEncoder

                MicrofusionCell ->
                    microfusionCellEncoder

                Ec2mm ->
                    ec2mmEncoder

                Tool ->
                    toolEncoder

                SuperToolKit ->
                    superToolKitEncoder

                FuelCellRegulator ->
                    fuelCellRegulatorEncoder

                FuelCellController ->
                    fuelCellControllerEncoder

                LockPicks ->
                    lockPicksEncoder

                ElectronicLockpick ->
                    electronicLockpickEncoder

                AbnormalBrain ->
                    abnormalBrainEncoder

                ChimpanzeeBrain ->
                    chimpanzeeBrainEncoder

                HumanBrain ->
                    humanBrainEncoder

                CyberneticBrain ->
                    cyberneticBrainEncoder

                GECK ->
                    gECKEncoder

                SkynetAim ->
                    skynetAimEncoder

                MotionSensor ->
                    motionSensorEncoder

                K9 ->
                    k9Encoder

                MeatJerky ->
                    meatJerkyEncoder

                TankerFob ->
                    tankerFobEncoder

                SilverGeckoPelt ->
                    silverGeckoPeltEncoder

                GoldenGeckoPelt ->
                    goldenGeckoPeltEncoder

                FireGeckoPelt ->
                    fireGeckoPeltEncoder
        )
        |> Codec.variant0 "Beer" Beer
        |> Codec.variant0 "Fruit" Fruit
        |> Codec.variant0 "HealingPowder" HealingPowder
        |> Codec.variant0 "Stimpak" Stimpak
        |> Codec.variant0 "SuperStimpak" SuperStimpak
        |> Codec.variant0 "BigBookOfScience" BigBookOfScience
        |> Codec.variant0 "DeansElectronics" DeansElectronics
        |> Codec.variant0 "FirstAidBook" FirstAidBook
        |> Codec.variant0 "GunsAndBullets" GunsAndBullets
        |> Codec.variant0 "ScoutHandbook" ScoutHandbook
        |> Codec.variant0 "Robes" Robes
        |> Codec.variant0 "LeatherJacket" LeatherJacket
        |> Codec.variant0 "LeatherArmor" LeatherArmor
        |> Codec.variant0 "MetalArmor" MetalArmor
        |> Codec.variant0 "TeslaArmor" TeslaArmor
        |> Codec.variant0 "CombatArmor" CombatArmor
        |> Codec.variant0 "CombatArmorMk2" CombatArmorMk2
        |> Codec.variant0 "PowerArmor" PowerArmor
        |> Codec.variant0 "PowerFist" PowerFist
        |> Codec.variant0 "MegaPowerFist" MegaPowerFist
        |> Codec.variant0 "CattleProd" CattleProd
        |> Codec.variant0 "SuperCattleProd" SuperCattleProd
        |> Codec.variant0 "Knife" Knife
        |> Codec.variant0 "Wakizashi" Wakizashi
        |> Codec.variant0 "LittleJesus" LittleJesus
        |> Codec.variant0 "Ripper" Ripper
        |> Codec.variant0 "SuperSledge" SuperSledge
        |> Codec.variant0 "Pistol223" Pistol223
        |> Codec.variant0 "Mauser9mm" Mauser9mm
        |> Codec.variant0 "Pistol14mm" Pistol14mm
        |> Codec.variant0 "NeedlerPistol" NeedlerPistol
        |> Codec.variant0 "GaussPistol" GaussPistol
        |> Codec.variant0 "Smg10mm" Smg10mm
        |> Codec.variant0 "HkP90c" HkP90c
        |> Codec.variant0 "AssaultRifle" AssaultRifle
        |> Codec.variant0 "ExpandedAssaultRifle" ExpandedAssaultRifle
        |> Codec.variant0 "HuntingRifle" HuntingRifle
        |> Codec.variant0 "ScopedHuntingRifle" ScopedHuntingRifle
        |> Codec.variant0 "RedRyderLEBBGun" RedRyderLEBBGun
        |> Codec.variant0 "SniperRifle" SniperRifle
        |> Codec.variant0 "GaussRifle" GaussRifle
        |> Codec.variant0 "CombatShotgun" CombatShotgun
        |> Codec.variant0 "HkCaws" HkCaws
        |> Codec.variant0 "PancorJackhammer" PancorJackhammer
        |> Codec.variant0 "Shotgun" Shotgun
        |> Codec.variant0 "SawedOffShotgun" SawedOffShotgun
        |> Codec.variant0 "Minigun" Minigun
        |> Codec.variant0 "Bozar" Bozar
        |> Codec.variant0 "RocketLauncher" RocketLauncher
        |> Codec.variant0 "LaserPistol" LaserPistol
        |> Codec.variant0 "MagnetoLaserPistol" MagnetoLaserPistol
        |> Codec.variant0 "PulsePistol" PulsePistol
        |> Codec.variant0 "GatlingLaser" GatlingLaser
        |> Codec.variant0 "LaserRifle" LaserRifle
        |> Codec.variant0 "LaserRifleExtCap" LaserRifleExtCap
        |> Codec.variant0 "PlasmaRifle" PlasmaRifle
        |> Codec.variant0 "TurboPlasmaRifle" TurboPlasmaRifle
        |> Codec.variant0 "PulseRifle" PulseRifle
        |> Codec.variant0 "Flare" Flare
        |> Codec.variant0 "FragGrenade" FragGrenade
        |> Codec.variant0 "BBAmmo" BBAmmo
        |> Codec.variant0 "SmallEnergyCell" SmallEnergyCell
        |> Codec.variant0 "Fmj223" Fmj223
        |> Codec.variant0 "Ap5mm" Ap5mm
        |> Codec.variant0 "Mm9" Mm9
        |> Codec.variant0 "Ball9mm" Ball9mm
        |> Codec.variant0 "Ap10mm" Ap10mm
        |> Codec.variant0 "Ap14mm" Ap14mm
        |> Codec.variant0 "ExplosiveRocket" ExplosiveRocket
        |> Codec.variant0 "RocketAp" RocketAp
        |> Codec.variant0 "HnNeedlerCartridge" HnNeedlerCartridge
        |> Codec.variant0 "HnApNeedlerCartridge" HnApNeedlerCartridge
        |> Codec.variant0 "ShotgunShell" ShotgunShell
        |> Codec.variant0 "Jhp10mm" Jhp10mm
        |> Codec.variant0 "Jhp5mm" Jhp5mm
        |> Codec.variant0 "MicrofusionCell" MicrofusionCell
        |> Codec.variant0 "Ec2mm" Ec2mm
        |> Codec.variant0 "Tool" Tool
        |> Codec.variant0 "SuperToolKit" SuperToolKit
        |> Codec.variant0 "FuelCellRegulator" FuelCellRegulator
        |> Codec.variant0 "FuelCellController" FuelCellController
        |> Codec.variant0 "LockPicks" LockPicks
        |> Codec.variant0 "ElectronicLockpick" ElectronicLockpick
        |> Codec.variant0 "AbnormalBrain" AbnormalBrain
        |> Codec.variant0 "ChimpanzeeBrain" ChimpanzeeBrain
        |> Codec.variant0 "HumanBrain" HumanBrain
        |> Codec.variant0 "CyberneticBrain" CyberneticBrain
        |> Codec.variant0 "GECK" GECK
        |> Codec.variant0 "SkynetAim" SkynetAim
        |> Codec.variant0 "MotionSensor" MotionSensor
        |> Codec.variant0 "K9" K9
        |> Codec.variant0 "MeatJerky" MeatJerky
        |> Codec.variant0 "TankerFob" TankerFob
        |> Codec.variant0 "SilverGeckoPelt" SilverGeckoPelt
        |> Codec.variant0 "GoldenGeckoPelt" GoldenGeckoPelt
        |> Codec.variant0 "FireGeckoPelt" FireGeckoPelt
        |> Codec.buildCustom


usageEffects : Kind -> List Effect
usageEffects kind =
    case kind of
        Fruit ->
            -- TODO radiation +1 after some time (2x)
            [ Effect.Heal { min = 1, max = 4 }
            , Effect.RemoveAfterUse
            ]

        HealingPowder ->
            -- TODO temporary perception -1?
            [ Effect.Heal { min = 8, max = 18 }
            , Effect.RemoveAfterUse
            ]

        Stimpak ->
            [ Effect.Heal { min = 10, max = 20 }
            , Effect.RemoveAfterUse
            ]

        BigBookOfScience ->
            [ Effect.RemoveAfterUse
            , Effect.BookRemoveTicks
            , Effect.BookAddSkillPercent Skill.Science
            ]

        DeansElectronics ->
            [ Effect.RemoveAfterUse
            , Effect.BookRemoveTicks
            , Effect.BookAddSkillPercent Skill.Repair
            ]

        FirstAidBook ->
            [ Effect.RemoveAfterUse
            , Effect.BookRemoveTicks
            , Effect.BookAddSkillPercent Skill.FirstAid
            ]

        GunsAndBullets ->
            [ Effect.RemoveAfterUse
            , Effect.BookRemoveTicks
            , Effect.BookAddSkillPercent Skill.SmallGuns
            ]

        ScoutHandbook ->
            [ Effect.RemoveAfterUse
            , Effect.BookRemoveTicks
            , Effect.BookAddSkillPercent Skill.Outdoorsman
            ]

        SuperStimpak ->
            -- TODO lose HP after some time
            [ Effect.Heal { min = 75, max = 75 }
            , Effect.RemoveAfterUse
            ]

        MeatJerky ->
            -- Different from FO2 that doesn't let you eat this
            [ Effect.Heal { min = 10, max = 15 }
            , Effect.RemoveAfterUse
            ]

        Robes ->
            []

        LeatherJacket ->
            []

        LeatherArmor ->
            []

        SilverGeckoPelt ->
            []

        GoldenGeckoPelt ->
            []

        FireGeckoPelt ->
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

        SuperToolKit ->
            []

        FuelCellRegulator ->
            []

        FuelCellController ->
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

        -- AlienBlaster -> []
        -- SolarScorcher -> []
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

        Knife ->
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

        -- HolyHandGrenade -> []
        HnNeedlerCartridge ->
            []

        HnApNeedlerCartridge ->
            []

        TankerFob ->
            []


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
            5

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

        SuperToolKit ->
            1000

        FuelCellRegulator ->
            5000

        FuelCellController ->
            5000

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

        -- AlienBlaster -> 5000
        -- SolarScorcher -> 400
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

        Knife ->
            40

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

        -- HolyHandGrenade -> 1 -- Balance?
        HnNeedlerCartridge ->
            250

        HnApNeedlerCartridge ->
            300

        TankerFob ->
            5000

        SilverGeckoPelt ->
            150

        GoldenGeckoPelt ->
            750

        FireGeckoPelt ->
            3500


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

        -- AlienBlaster -> 0
        LaserPistol ->
            0

        -- SolarScorcher -> 0
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        -- AlienBlaster -> ( 1, 1 )
        LaserPistol ->
            ( 1, 1 )

        -- SolarScorcher -> ( 1, 1 )
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

        SuperToolKit ->
            ( 1, 1 )

        FuelCellRegulator ->
            ( 1, 1 )

        FuelCellController ->
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

        Knife ->
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

        -- HolyHandGrenade -> ( 1, 1 )
        HnNeedlerCartridge ->
            ( 1, 1 )

        HnApNeedlerCartridge ->
            ( 2, 1 )

        TankerFob ->
            ( 0, 0 )

        SilverGeckoPelt ->
            ( 0, 0 )

        GoldenGeckoPelt ->
            ( 0, 0 )

        FireGeckoPelt ->
            ( 0, 0 )


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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            -10

        HnApNeedlerCartridge ->
            -10

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


armorDamageResistance : DamageType -> Kind -> Int
armorDamageResistance damageType kind =
    case damageType of
        DamageType.NormalDamage ->
            armorDamageResistanceNormal kind

        DamageType.Fire ->
            armorDamageResistanceFire kind

        DamageType.Plasma ->
            armorDamageResistancePlasma kind

        DamageType.Laser ->
            armorDamageResistanceLaser kind

        DamageType.Explosion ->
            armorDamageResistanceExplosion kind

        DamageType.Electrical ->
            armorDamageResistanceElectrical kind

        DamageType.EMP ->
            armorDamageResistanceEMP kind


armorDamageThreshold : DamageType -> Kind -> Int
armorDamageThreshold damageType kind =
    case damageType of
        DamageType.NormalDamage ->
            armorDamageThresholdNormal kind

        DamageType.Fire ->
            armorDamageThresholdFire kind

        DamageType.Plasma ->
            armorDamageThresholdPlasma kind

        DamageType.Laser ->
            armorDamageThresholdLaser kind

        DamageType.Explosion ->
            armorDamageThresholdExplosion kind

        DamageType.Electrical ->
            armorDamageThresholdElectrical kind

        DamageType.EMP ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


isUsableAmmoForWeapon : Kind -> Kind -> Bool
isUsableAmmoForWeapon weapon ammo =
    List.member ammo (usableAmmoForWeapon weapon)


{-| One gotcha: in case of thrown weapons they themselves are their own ammo.
This makes throwing work more or less the same as ranged weapons.
-}
usableAmmoForWeapon : Kind -> List Kind
usableAmmoForWeapon kind =
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

        -- AlienBlaster -> [ SmallEnergyCell ]
        LaserPistol ->
            [ SmallEnergyCell ]

        -- SolarScorcher -> [] -- TODO if we ever have darkness, this weapon needs to stop working
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

        SuperToolKit ->
            []

        FuelCellRegulator ->
            []

        FuelCellController ->
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

        Knife ->
            []

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

        -- HolyHandGrenade -> [ HolyHandGrenade ]
        HnNeedlerCartridge ->
            []

        HnApNeedlerCartridge ->
            []

        TankerFob ->
            []

        SilverGeckoPelt ->
            []

        GoldenGeckoPelt ->
            []

        FireGeckoPelt ->
            []


weaponDamageType : Kind -> Maybe DamageType
weaponDamageType kind =
    case kind of
        PowerFist ->
            Just DamageType.NormalDamage

        MegaPowerFist ->
            Just DamageType.NormalDamage

        SuperSledge ->
            Just DamageType.NormalDamage

        GaussPistol ->
            Just DamageType.NormalDamage

        Smg10mm ->
            Just DamageType.NormalDamage

        HkP90c ->
            Just DamageType.NormalDamage

        AssaultRifle ->
            Just DamageType.NormalDamage

        ExpandedAssaultRifle ->
            Just DamageType.NormalDamage

        HuntingRifle ->
            Just DamageType.NormalDamage

        ScopedHuntingRifle ->
            Just DamageType.NormalDamage

        RedRyderLEBBGun ->
            Just DamageType.NormalDamage

        SniperRifle ->
            Just DamageType.NormalDamage

        GaussRifle ->
            Just DamageType.NormalDamage

        PancorJackhammer ->
            Just DamageType.NormalDamage

        SawedOffShotgun ->
            Just DamageType.NormalDamage

        Minigun ->
            Just DamageType.NormalDamage

        Bozar ->
            Just DamageType.NormalDamage

        RocketLauncher ->
            Just DamageType.Explosion

        LaserPistol ->
            Just DamageType.Laser

        GatlingLaser ->
            Just DamageType.Laser

        LaserRifle ->
            Just DamageType.Laser

        LaserRifleExtCap ->
            Just DamageType.Laser

        PlasmaRifle ->
            Just DamageType.Plasma

        TurboPlasmaRifle ->
            Just DamageType.Plasma

        PulseRifle ->
            Just DamageType.Electrical

        FragGrenade ->
            Just DamageType.Explosion

        CattleProd ->
            Just DamageType.Electrical

        SuperCattleProd ->
            Just DamageType.Electrical

        Mauser9mm ->
            Just DamageType.NormalDamage

        Pistol14mm ->
            Just DamageType.NormalDamage

        CombatShotgun ->
            Just DamageType.NormalDamage

        HkCaws ->
            Just DamageType.NormalDamage

        Shotgun ->
            Just DamageType.NormalDamage

        -- AlienBlaster -> Just DamageType.Electrical
        -- SolarScorcher -> Just DamageType.Laser
        Flare ->
            Just DamageType.NormalDamage

        Pistol223 ->
            Just DamageType.NormalDamage

        Knife ->
            Just DamageType.NormalDamage

        Wakizashi ->
            Just DamageType.NormalDamage

        LittleJesus ->
            Just DamageType.NormalDamage

        Ripper ->
            Just DamageType.NormalDamage

        NeedlerPistol ->
            Just DamageType.NormalDamage

        MagnetoLaserPistol ->
            Just DamageType.Laser

        PulsePistol ->
            Just DamageType.Electrical

        -- HolyHandGrenade -> Just DamageType.Explosion
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

        SuperToolKit ->
            Nothing

        FuelCellRegulator ->
            Nothing

        FuelCellController ->
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

        HnNeedlerCartridge ->
            Nothing

        HnApNeedlerCartridge ->
            Nothing

        TankerFob ->
            Nothing

        SilverGeckoPelt ->
            Nothing

        GoldenGeckoPelt ->
            Nothing

        FireGeckoPelt ->
            Nothing


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

        SuperToolKit ->
            1

        FuelCellRegulator ->
            1

        FuelCellController ->
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

        -- AlienBlaster -> 2
        -- SolarScorcher -> 3
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

        Knife ->
            2

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

        -- HolyHandGrenade -> 2
        HnNeedlerCartridge ->
            1

        HnApNeedlerCartridge ->
            1

        TankerFob ->
            1

        SilverGeckoPelt ->
            1

        GoldenGeckoPelt ->
            1

        FireGeckoPelt ->
            1


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

        SuperToolKit ->
            False

        FuelCellRegulator ->
            False

        FuelCellController ->
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

        -- AlienBlaster -> False
        -- SolarScorcher -> False
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

        Knife ->
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

        -- HolyHandGrenade -> False
        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False

        TankerFob ->
            False

        SilverGeckoPelt ->
            False

        GoldenGeckoPelt ->
            False

        FireGeckoPelt ->
            False


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

        -- HolyHandGrenade -> True
        PulseRifle ->
            True

        PowerFist ->
            True

        MegaPowerFist ->
            True

        -- The rest are Falses
        AssaultRifle ->
            False

        Knife ->
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

        SuperToolKit ->
            False

        FuelCellRegulator ->
            False

        FuelCellController ->
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

        -- AlienBlaster -> False
        -- SolarScorcher -> False
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

        TankerFob ->
            False

        SilverGeckoPelt ->
            False

        GoldenGeckoPelt ->
            False

        FireGeckoPelt ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 0
        -- SolarScorcher -> 0
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

        Knife ->
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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


range : AttackStyle -> Kind -> Int
range attackStyle kind =
    case attackStyle of
        AttackStyle.UnarmedUnaimed ->
            unaimedRange kind

        AttackStyle.UnarmedAimed _ ->
            aimedRange kind

        AttackStyle.MeleeUnaimed ->
            unaimedRange kind

        AttackStyle.MeleeAimed _ ->
            aimedRange kind

        AttackStyle.Throw ->
            unaimedRange kind

        AttackStyle.ShootSingleUnaimed ->
            unaimedRange kind

        AttackStyle.ShootSingleAimed _ ->
            aimedRange kind

        AttackStyle.ShootBurst ->
            burstRange kind


isAccurateWeapon : Kind -> Bool
isAccurateWeapon kind =
    case kind of
        Mauser9mm ->
            True

        Pistol14mm ->
            True

        -- AlienBlaster -> True
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

        -- SolarScorcher -> True
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

        SuperToolKit ->
            False

        FuelCellRegulator ->
            False

        FuelCellController ->
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

        Knife ->
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

        -- HolyHandGrenade -> False
        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False

        TankerFob ->
            False

        SilverGeckoPelt ->
            False

        GoldenGeckoPelt ->
            False

        FireGeckoPelt ->
            False


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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 10
        -- SolarScorcher -> 20
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

        Knife ->
            1

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

        -- HolyHandGrenade -> 0
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        -- AlienBlaster -> 10
        -- SolarScorcher -> 20
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

        Knife ->
            1

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

        -- HolyHandGrenade -> 20
        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


isWeapon : Kind -> Bool
isWeapon kind =
    List.any Type.isWeapon (types kind)


isAmmo : Kind -> Bool
isAmmo kind =
    List.any Type.isAmmo (types kind)


isArmor : Kind -> Bool
isArmor kind =
    List.member Type.Armor (types kind)


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

        SuperToolKit ->
            "Super Tool Kit"

        FuelCellRegulator ->
            "Fuel Cell Regulator"

        FuelCellController ->
            "Fuel Cell Controller"

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

        -- AlienBlaster -> "Alien Blaster"
        -- SolarScorcher -> "Solar Scorcher"
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

        Knife ->
            "Knife"

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

        -- HolyHandGrenade -> "Holy Hand Grenade"
        HnNeedlerCartridge ->
            "HN Needler Cartridge"

        HnApNeedlerCartridge ->
            "HN AP Needler Cartridge"

        TankerFob ->
            "Tanker FOB"

        SilverGeckoPelt ->
            "Silver Gecko Pelt"

        GoldenGeckoPelt ->
            "Golden Gecko Pelt"

        FireGeckoPelt ->
            "Fire Gecko Pelt"


{-| Why the List: some weapons can be used in melee and be thrown, eg. Rock.
Logic.neededSkill needs to take this + the chosen AttackStyle into account.
-}
types : Kind -> List Type
types kind =
    case kind of
        Fruit ->
            [ Type.Consumable ]

        HealingPowder ->
            [ Type.Consumable ]

        Stimpak ->
            [ Type.Consumable ]

        BigBookOfScience ->
            [ Type.Book ]

        DeansElectronics ->
            [ Type.Book ]

        FirstAidBook ->
            [ Type.Book ]

        GunsAndBullets ->
            [ Type.Book ]

        ScoutHandbook ->
            [ Type.Book ]

        Robes ->
            [ Type.Armor ]

        LeatherJacket ->
            [ Type.Armor ]

        LeatherArmor ->
            [ Type.Armor ]

        MetalArmor ->
            [ Type.Armor ]

        Beer ->
            [ Type.Misc ]

        RedRyderLEBBGun ->
            [ Type.SmallGun ]

        BBAmmo ->
            [ Type.Ammo ]

        ElectronicLockpick ->
            [ Type.Misc ]

        AbnormalBrain ->
            [ Type.Misc ]

        ChimpanzeeBrain ->
            [ Type.Misc ]

        HumanBrain ->
            [ Type.Misc ]

        CyberneticBrain ->
            [ Type.Misc ]

        MeatJerky ->
            [ Type.Misc ]

        HuntingRifle ->
            [ Type.SmallGun ]

        ScopedHuntingRifle ->
            [ Type.SmallGun ]

        SuperStimpak ->
            [ Type.Consumable ]

        TeslaArmor ->
            [ Type.Armor ]

        CombatArmor ->
            [ Type.Armor ]

        CombatArmorMk2 ->
            [ Type.Armor ]

        PowerArmor ->
            [ Type.Armor ]

        SuperSledge ->
            [ Type.MeleeWeapon ]

        PowerFist ->
            [ Type.UnarmedWeapon ]

        MegaPowerFist ->
            [ Type.UnarmedWeapon ]

        FragGrenade ->
            [ Type.ThrownWeapon ]

        Bozar ->
            [ Type.BigGun ]

        SawedOffShotgun ->
            [ Type.SmallGun ]

        SniperRifle ->
            [ Type.SmallGun ]

        AssaultRifle ->
            [ Type.SmallGun ]

        ExpandedAssaultRifle ->
            [ Type.SmallGun ]

        PancorJackhammer ->
            [ Type.SmallGun ]

        HkP90c ->
            [ Type.SmallGun ]

        LaserPistol ->
            [ Type.EnergyWeapon ]

        PlasmaRifle ->
            [ Type.EnergyWeapon ]

        GatlingLaser ->
            [ Type.EnergyWeapon ]

        TurboPlasmaRifle ->
            [ Type.EnergyWeapon ]

        GaussRifle ->
            [ Type.SmallGun ]

        GaussPistol ->
            [ Type.SmallGun ]

        PulseRifle ->
            [ Type.EnergyWeapon ]

        SmallEnergyCell ->
            [ Type.Ammo ]

        Fmj223 ->
            [ Type.Ammo ]

        ShotgunShell ->
            [ Type.Ammo ]

        Smg10mm ->
            [ Type.SmallGun ]

        Jhp10mm ->
            [ Type.Ammo ]

        Jhp5mm ->
            [ Type.Ammo ]

        MicrofusionCell ->
            [ Type.Ammo ]

        Ec2mm ->
            [ Type.Ammo ]

        Tool ->
            [ Type.Misc ]

        SuperToolKit ->
            [ Type.Misc ]

        FuelCellRegulator ->
            [ Type.Misc ]

        FuelCellController ->
            [ Type.Misc ]

        GECK ->
            [ Type.Misc ]

        SkynetAim ->
            [ Type.Misc ]

        MotionSensor ->
            [ Type.Misc ]

        K9 ->
            [ Type.Misc ]

        LockPicks ->
            [ Type.Misc ]

        Minigun ->
            [ Type.BigGun ]

        RocketLauncher ->
            [ Type.BigGun ]

        LaserRifle ->
            [ Type.EnergyWeapon ]

        LaserRifleExtCap ->
            [ Type.EnergyWeapon ]

        CattleProd ->
            [ Type.MeleeWeapon ]

        SuperCattleProd ->
            [ Type.MeleeWeapon ]

        Mauser9mm ->
            [ Type.SmallGun ]

        Pistol14mm ->
            [ Type.SmallGun ]

        CombatShotgun ->
            [ Type.SmallGun ]

        HkCaws ->
            [ Type.SmallGun ]

        Shotgun ->
            [ Type.SmallGun ]

        -- AlienBlaster -> [ Type.EnergyWeapon ]
        -- SolarScorcher -> [ Type.EnergyWeapon ]
        Flare ->
            [ Type.ThrownWeapon ]

        Ap5mm ->
            [ Type.Ammo ]

        Mm9 ->
            [ Type.Ammo ]

        Ball9mm ->
            [ Type.Ammo ]

        Ap10mm ->
            [ Type.Ammo ]

        Ap14mm ->
            [ Type.Ammo ]

        ExplosiveRocket ->
            [ Type.Ammo ]

        RocketAp ->
            [ Type.Ammo ]

        Pistol223 ->
            [ Type.SmallGun ]

        Knife ->
            [ Type.MeleeWeapon ]

        Wakizashi ->
            [ Type.MeleeWeapon ]

        LittleJesus ->
            [ Type.MeleeWeapon ]

        Ripper ->
            [ Type.MeleeWeapon ]

        NeedlerPistol ->
            [ Type.SmallGun ]

        MagnetoLaserPistol ->
            [ Type.EnergyWeapon ]

        PulsePistol ->
            [ Type.EnergyWeapon ]

        -- HolyHandGrenade -> [ Type.ThrownWeapon ]
        HnNeedlerCartridge ->
            [ Type.Ammo ]

        HnApNeedlerCartridge ->
            [ Type.Ammo ]

        TankerFob ->
            [ Type.Misc ]

        SilverGeckoPelt ->
            [ Type.Misc ]

        GoldenGeckoPelt ->
            [ Type.Misc ]

        FireGeckoPelt ->
            [ Type.Misc ]


healAmount : Kind -> Maybe { min : Int, max : Int }
healAmount kind =
    kind
        |> usageEffects
        |> List.filterMap Effect.getHealing
        |> List.head


weaponDamage : Kind -> { min : Int, max : Int }
weaponDamage kind =
    let
        mk min max =
            { min = min, max = max }
    in
    case kind of
        PowerFist ->
            mk 12 24

        MegaPowerFist ->
            mk 20 40

        SuperSledge ->
            mk 18 36

        GaussPistol ->
            mk 22 32

        Smg10mm ->
            mk 5 12

        HkP90c ->
            mk 12 16

        AssaultRifle ->
            mk 8 16

        ExpandedAssaultRifle ->
            mk 8 16

        HuntingRifle ->
            mk 8 20

        ScopedHuntingRifle ->
            mk 8 20

        RedRyderLEBBGun ->
            mk 25 25

        SniperRifle ->
            mk 14 34

        GaussRifle ->
            mk 32 43

        PancorJackhammer ->
            mk 18 29

        SawedOffShotgun ->
            mk 12 24

        Minigun ->
            mk 7 11

        Bozar ->
            mk 25 35

        RocketLauncher ->
            mk 35 100

        LaserPistol ->
            mk 10 22

        GatlingLaser ->
            mk 20 40

        LaserRifle ->
            mk 25 50

        LaserRifleExtCap ->
            mk 25 50

        PlasmaRifle ->
            mk 30 65

        TurboPlasmaRifle ->
            mk 35 70

        PulseRifle ->
            mk 54 78

        FragGrenade ->
            mk 20 35

        CattleProd ->
            mk 12 20

        SuperCattleProd ->
            mk 20 32

        Mauser9mm ->
            mk 5 10

        Pistol14mm ->
            mk 12 22

        CombatShotgun ->
            mk 15 25

        HkCaws ->
            mk 15 25

        Shotgun ->
            mk 12 22

        -- AlienBlaster -> mk 30 90
        -- SolarScorcher -> mk 20 60
        Flare ->
            mk 1 1

        Pistol223 ->
            mk 20 30

        Knife ->
            mk 1 6

        Wakizashi ->
            mk 4 12

        LittleJesus ->
            mk 5 14

        Ripper ->
            mk 15 32

        NeedlerPistol ->
            mk 12 24

        MagnetoLaserPistol ->
            mk 10 22

        PulsePistol ->
            mk 32 46

        -- HolyHandGrenade -> mk 300 500
        Beer ->
            mk 0 0

        Fruit ->
            mk 0 0

        HealingPowder ->
            mk 0 0

        Stimpak ->
            mk 0 0

        SuperStimpak ->
            mk 0 0

        BigBookOfScience ->
            mk 0 0

        DeansElectronics ->
            mk 0 0

        FirstAidBook ->
            mk 0 0

        GunsAndBullets ->
            mk 0 0

        ScoutHandbook ->
            mk 0 0

        Robes ->
            mk 0 0

        LeatherJacket ->
            mk 0 0

        LeatherArmor ->
            mk 0 0

        MetalArmor ->
            mk 0 0

        TeslaArmor ->
            mk 0 0

        CombatArmor ->
            mk 0 0

        CombatArmorMk2 ->
            mk 0 0

        PowerArmor ->
            mk 0 0

        BBAmmo ->
            mk 0 0

        SmallEnergyCell ->
            mk 0 0

        Fmj223 ->
            mk 0 0

        ShotgunShell ->
            mk 0 0

        Jhp10mm ->
            mk 0 0

        Jhp5mm ->
            mk 0 0

        MicrofusionCell ->
            mk 0 0

        Ec2mm ->
            mk 0 0

        Tool ->
            mk 0 0

        SuperToolKit ->
            mk 0 0

        FuelCellRegulator ->
            mk 0 0

        FuelCellController ->
            mk 0 0

        LockPicks ->
            mk 0 0

        ElectronicLockpick ->
            mk 0 0

        AbnormalBrain ->
            mk 0 0

        ChimpanzeeBrain ->
            mk 0 0

        HumanBrain ->
            mk 0 0

        CyberneticBrain ->
            mk 0 0

        GECK ->
            mk 0 0

        SkynetAim ->
            mk 0 0

        MotionSensor ->
            mk 0 0

        K9 ->
            mk 0 0

        MeatJerky ->
            mk 0 0

        Ap5mm ->
            mk 0 0

        Mm9 ->
            mk 0 0

        Ball9mm ->
            mk 0 0

        Ap10mm ->
            mk 0 0

        Ap14mm ->
            mk 0 0

        ExplosiveRocket ->
            mk 0 0

        RocketAp ->
            mk 0 0

        HnNeedlerCartridge ->
            mk 0 0

        HnApNeedlerCartridge ->
            mk 0 0

        TankerFob ->
            mk 0 0

        SilverGeckoPelt ->
            mk 0 0

        GoldenGeckoPelt ->
            mk 0 0

        FireGeckoPelt ->
            mk 0 0


shotsPerBurst : Kind -> Int
shotsPerBurst kind =
    case kind of
        PowerFist ->
            0

        MegaPowerFist ->
            0

        SuperSledge ->
            0

        GaussPistol ->
            0

        Smg10mm ->
            10

        HkP90c ->
            12

        AssaultRifle ->
            8

        ExpandedAssaultRifle ->
            8

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
            5

        SawedOffShotgun ->
            0

        Minigun ->
            40

        Bozar ->
            15

        RocketLauncher ->
            0

        LaserPistol ->
            0

        GatlingLaser ->
            10

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

        CattleProd ->
            0

        SuperCattleProd ->
            0

        Mauser9mm ->
            0

        Pistol14mm ->
            0

        CombatShotgun ->
            3

        HkCaws ->
            5

        Shotgun ->
            0

        Flare ->
            0

        Pistol223 ->
            0

        Knife ->
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

        BBAmmo ->
            0

        SmallEnergyCell ->
            0

        Fmj223 ->
            0

        ShotgunShell ->
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

        SuperToolKit ->
            0

        FuelCellRegulator ->
            0

        FuelCellController ->
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

        HnNeedlerCartridge ->
            0

        HnApNeedlerCartridge ->
            0

        TankerFob ->
            0

        SilverGeckoPelt ->
            0

        GoldenGeckoPelt ->
            0

        FireGeckoPelt ->
            0


isTwoHandedWeapon : Kind -> Bool
isTwoHandedWeapon kind =
    case kind of
        SuperSledge ->
            True

        AssaultRifle ->
            True

        ExpandedAssaultRifle ->
            True

        HuntingRifle ->
            True

        ScopedHuntingRifle ->
            True

        RedRyderLEBBGun ->
            True

        SniperRifle ->
            True

        GaussRifle ->
            True

        CombatShotgun ->
            True

        HkCaws ->
            True

        PancorJackhammer ->
            True

        Shotgun ->
            True

        Minigun ->
            True

        Bozar ->
            True

        RocketLauncher ->
            True

        GatlingLaser ->
            True

        LaserRifle ->
            True

        LaserRifleExtCap ->
            True

        PlasmaRifle ->
            True

        TurboPlasmaRifle ->
            True

        PulseRifle ->
            True

        -- Rest are False
        PowerFist ->
            False

        MegaPowerFist ->
            False

        GaussPistol ->
            False

        Smg10mm ->
            False

        HkP90c ->
            False

        SawedOffShotgun ->
            False

        LaserPistol ->
            False

        FragGrenade ->
            False

        CattleProd ->
            False

        SuperCattleProd ->
            False

        Mauser9mm ->
            False

        Pistol14mm ->
            False

        Flare ->
            False

        Pistol223 ->
            False

        Knife ->
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

        SuperToolKit ->
            False

        FuelCellRegulator ->
            False

        FuelCellController ->
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

        HnNeedlerCartridge ->
            False

        HnApNeedlerCartridge ->
            False

        TankerFob ->
            False

        SilverGeckoPelt ->
            False

        GoldenGeckoPelt ->
            False

        FireGeckoPelt ->
            False


carBatteryChargePromileAmount : Kind -> Maybe Int
carBatteryChargePromileAmount kind =
    case kind of
        MicrofusionCell ->
            Just 500

        SmallEnergyCell ->
            Just 200

        SuperSledge ->
            Nothing

        AssaultRifle ->
            Nothing

        ExpandedAssaultRifle ->
            Nothing

        HuntingRifle ->
            Nothing

        ScopedHuntingRifle ->
            Nothing

        RedRyderLEBBGun ->
            Nothing

        SniperRifle ->
            Nothing

        GaussRifle ->
            Nothing

        CombatShotgun ->
            Nothing

        HkCaws ->
            Nothing

        PancorJackhammer ->
            Nothing

        Shotgun ->
            Nothing

        Minigun ->
            Nothing

        Bozar ->
            Nothing

        RocketLauncher ->
            Nothing

        GatlingLaser ->
            Nothing

        LaserRifle ->
            Nothing

        LaserRifleExtCap ->
            Nothing

        PlasmaRifle ->
            Nothing

        TurboPlasmaRifle ->
            Nothing

        PulseRifle ->
            Nothing

        PowerFist ->
            Nothing

        MegaPowerFist ->
            Nothing

        GaussPistol ->
            Nothing

        Smg10mm ->
            Nothing

        HkP90c ->
            Nothing

        SawedOffShotgun ->
            Nothing

        LaserPistol ->
            Nothing

        FragGrenade ->
            Nothing

        CattleProd ->
            Nothing

        SuperCattleProd ->
            Nothing

        Mauser9mm ->
            Nothing

        Pistol14mm ->
            Nothing

        Flare ->
            Nothing

        Pistol223 ->
            Nothing

        Knife ->
            Nothing

        Wakizashi ->
            Nothing

        LittleJesus ->
            Nothing

        Ripper ->
            Nothing

        NeedlerPistol ->
            Nothing

        MagnetoLaserPistol ->
            Nothing

        PulsePistol ->
            Nothing

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

        Fmj223 ->
            Nothing

        ShotgunShell ->
            Nothing

        Jhp10mm ->
            Nothing

        Jhp5mm ->
            Nothing

        Ec2mm ->
            Nothing

        Tool ->
            Nothing

        SuperToolKit ->
            Nothing

        FuelCellRegulator ->
            Nothing

        FuelCellController ->
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

        HnNeedlerCartridge ->
            Nothing

        HnApNeedlerCartridge ->
            Nothing

        TankerFob ->
            Nothing

        SilverGeckoPelt ->
            Nothing

        GoldenGeckoPelt ->
            Nothing

        FireGeckoPelt ->
            Nothing
