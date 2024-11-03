module Data.Vendor.Shop exposing
    ( Shop(..), codec
    , all, isAvailable
    , personName, description, barterSkill, initialSpec
    , location, forLocation, isInLocation
    , ShopSpec, specCodec
    )

{-|

@docs Shop, codec
@docs all, isAvailable
@docs personName, description, barterSkill, initialSpec
@docs location, forLocation, isInLocation

@docs ShopSpec, specCodec

-}

import Codec exposing (Codec)
import Data.Item as Item
import Data.Item.Kind exposing (Kind(..))
import Data.Map.Location as Location exposing (Location)
import Random.FloatExtra as RandomFloat exposing (NormalIntSpec)
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import SeqSet exposing (SeqSet)


type Shop
    = ArroyoHakunin
    | KlamathMaida
    | KlamathVic
    | DenFlick
    | ModocJo
    | VaultCityRandal
    | VaultCityHappyHarry
    | GeckoSurvivalGearPercy
    | ReddingAscorti
    | BrokenHillsGeneralStoreLiz
    | BrokenHillsChemistJacob
    | NewRenoArmsEldridge
    | NewRenoRenescoPharmacy
    | NCRBuster
    | NCRDuppo
    | SanFranciscoFlyingDragon8LaoChou
    | SanFranciscoRed888GunsMaiDaChiang
    | SanFranciscoPunksCal
    | SanFranciscoPunksJenna


type alias ShopSpec =
    { caps : NormalIntSpec
    , stock : SeqDict Item.UniqueKey { maxCount : Int }
    }


all : List Shop
all =
    [ ArroyoHakunin
    , KlamathMaida
    , KlamathVic
    , DenFlick
    , ModocJo
    , VaultCityRandal
    , VaultCityHappyHarry
    , GeckoSurvivalGearPercy
    , ReddingAscorti
    , BrokenHillsGeneralStoreLiz
    , BrokenHillsChemistJacob
    , NewRenoArmsEldridge
    , NewRenoRenescoPharmacy
    , NCRBuster
    , NCRDuppo
    , SanFranciscoFlyingDragon8LaoChou
    , SanFranciscoRed888GunsMaiDaChiang
    , SanFranciscoPunksCal
    , SanFranciscoPunksJenna
    ]


isAvailable : SeqSet Shop -> Shop -> Bool
isAvailable questRewards shop =
    let
        asReward : () -> Bool
        asReward () =
            SeqSet.member shop questRewards
    in
    case shop of
        ArroyoHakunin ->
            True

        KlamathMaida ->
            True

        KlamathVic ->
            asReward ()

        DenFlick ->
            True

        ModocJo ->
            True

        VaultCityRandal ->
            True

        VaultCityHappyHarry ->
            True

        GeckoSurvivalGearPercy ->
            True

        ReddingAscorti ->
            True

        BrokenHillsGeneralStoreLiz ->
            True

        BrokenHillsChemistJacob ->
            True

        NewRenoArmsEldridge ->
            True

        NewRenoRenescoPharmacy ->
            True

        NCRBuster ->
            True

        NCRDuppo ->
            True

        SanFranciscoFlyingDragon8LaoChou ->
            True

        SanFranciscoRed888GunsMaiDaChiang ->
            True

        SanFranciscoPunksCal ->
            asReward ()

        SanFranciscoPunksJenna ->
            asReward ()


personName : Shop -> String
personName shop =
    case shop of
        ArroyoHakunin ->
            "Hakunin"

        KlamathMaida ->
            "Maida"

        KlamathVic ->
            "Vic"

        DenFlick ->
            "Flick"

        ModocJo ->
            "Jo"

        VaultCityRandal ->
            "Randal"

        VaultCityHappyHarry ->
            "Happy Harry"

        GeckoSurvivalGearPercy ->
            "Percy"

        ReddingAscorti ->
            "Ascorti"

        BrokenHillsGeneralStoreLiz ->
            "Liz"

        BrokenHillsChemistJacob ->
            "Jacob the Chemist"

        NewRenoArmsEldridge ->
            "Eldridge"

        NewRenoRenescoPharmacy ->
            "Renesco"

        NCRBuster ->
            "Buster"

        NCRDuppo ->
            "Duppo"

        SanFranciscoFlyingDragon8LaoChou ->
            "Lao Chou"

        SanFranciscoRed888GunsMaiDaChiang ->
            "Mai Da Chiang"

        SanFranciscoPunksCal ->
            "Cal"

        SanFranciscoPunksJenna ->
            "Jenna"


description : Shop -> String
description shop =
    case shop of
        ArroyoHakunin ->
            "Before you stands Hakunin, the Arroyo village shaman. He appraises you with his crazy eyes from somewhere in the world only he inhabits..."

        KlamathMaida ->
            "You see Maida Buckner, Mrs. Buckner's daughter: a plain looking, sturdily built young woman with a scowl on her face."

        KlamathVic ->
            "You see Vic, a wasteland trader and mechanic who works among the tribes of northern New California. He specializes in pre-War technologies."

        DenFlick ->
            "You see Flick, a thin, greasy looking man with a nasty facial twitch."

        ModocJo ->
            "In the middle of the trading post stands Jo: the sheriff/mayor of Modoc. An average person, of average height, of average complexion. Nothing out of the ordinary."

        VaultCityRandal ->
            "You see Randal, the Vault City Chief Amenities Officer. He's a middle-aged man with thinning black hair."

        VaultCityHappyHarry ->
            "You see a short, jovial man and the owner of this store, Happy Harry."

        GeckoSurvivalGearPercy ->
            "You see a shorter and rather stout ghoul, Percy. He's nattily attired-uh, for a ghoul, that is."

        ReddingAscorti ->
            "You see Ascorti, a well-dressed man with a greasy look to him who happens to be the mayor of Redding."

        BrokenHillsGeneralStoreLiz ->
            "You see Liz, the manager of the Broken Hills General Store. She's a middle-aged woman whose scowl has eroded her face. She looks like one of those people who takes a perverse pleasure in a hard life."

        BrokenHillsChemistJacob ->
            "You see a bedraggled man in a stained lab coat. His hands are discolored from chemicals. It's Jacob the Chemist."

        NewRenoArmsEldridge ->
            "You see Eldridge, a heavily armed man covered with grease. He is gazing at his weapon collection on the walls and smiling dreamily."

        NewRenoRenescoPharmacy ->
            "You see the old man Renesco, in his pharmacy. He wears a pair of huge, garish glasses. He sighs irritatedly as you watch."

        NCRBuster ->
            "You're looking at Buster, the gun guy. His clothes are ragged and he's got gun-bluing all over his hands, arms, and face. Still, he seems pretty cheerful."

        NCRDuppo ->
            "You see a red-faced, friendly looking man. It's Duppo. He runs the Stockmen's Association. He's a stocky fellow and with constantly flushed face and shock of thin blond hair. He walks with a slight limp."

        SanFranciscoFlyingDragon8LaoChou ->
            "You see a man in functional, comfortable clothing. He's Lao Chou, the shopkeeper."

        SanFranciscoRed888GunsMaiDaChiang ->
            "You see an enthusiastic Shi named Mai Da Chiang, the owner of Red 888 Guns. He looks like he's running on permanent overdrive."

        SanFranciscoPunksCal ->
            "You see Cal, the constantly bored but friendly looking gun merchant."

        SanFranciscoPunksJenna ->
            "You see Jenna, the merchant on the PMV Valdez."


location : Shop -> Location
location shop =
    case shop of
        ArroyoHakunin ->
            Location.Arroyo

        KlamathMaida ->
            Location.Klamath

        KlamathVic ->
            Location.Klamath

        DenFlick ->
            Location.Den

        ModocJo ->
            Location.Modoc

        VaultCityRandal ->
            Location.VaultCity

        VaultCityHappyHarry ->
            Location.VaultCity

        GeckoSurvivalGearPercy ->
            Location.Gecko

        ReddingAscorti ->
            Location.Redding

        BrokenHillsGeneralStoreLiz ->
            Location.BrokenHills

        BrokenHillsChemistJacob ->
            Location.BrokenHills

        NewRenoArmsEldridge ->
            Location.NewReno

        NewRenoRenescoPharmacy ->
            Location.NewReno

        NCRBuster ->
            Location.NewCaliforniaRepublic

        NCRDuppo ->
            Location.NewCaliforniaRepublic

        SanFranciscoFlyingDragon8LaoChou ->
            Location.SanFrancisco

        SanFranciscoRed888GunsMaiDaChiang ->
            Location.SanFrancisco

        SanFranciscoPunksCal ->
            Location.SanFrancisco

        SanFranciscoPunksJenna ->
            Location.SanFrancisco


barterSkill : Shop -> Int
barterSkill shop =
    case shop of
        ArroyoHakunin ->
            30

        KlamathMaida ->
            55

        KlamathVic ->
            50

        DenFlick ->
            80

        ModocJo ->
            100

        VaultCityRandal ->
            90

        VaultCityHappyHarry ->
            80

        GeckoSurvivalGearPercy ->
            -- 0 in the game
            70

        ReddingAscorti ->
            90

        BrokenHillsGeneralStoreLiz ->
            120

        BrokenHillsChemistJacob ->
            115

        NewRenoArmsEldridge ->
            115

        NewRenoRenescoPharmacy ->
            110

        NCRBuster ->
            120

        NCRDuppo ->
            120

        SanFranciscoFlyingDragon8LaoChou ->
            150

        SanFranciscoRed888GunsMaiDaChiang ->
            140

        SanFranciscoPunksCal ->
            85

        SanFranciscoPunksJenna ->
            85


{-| This can later be extended by global rewards.
-}
initialSpec : Shop -> ShopSpec
initialSpec shop =
    let
        item count kind =
            ( { kind = kind }, { maxCount = count } )
    in
    case shop of
        ArroyoHakunin ->
            { caps = { average = 50, maxDeviation = 20 }
            , stock =
                SeqDict.fromList
                    [ item 3 HealingPowder
                    , item 1 Robes
                    , item 2 Fruit
                    , item 1 Knife
                    ]
            }

        KlamathMaida ->
            { caps = { average = 150, maxDeviation = 80 }
            , stock =
                SeqDict.fromList
                    [ item 3 HealingPowder
                    , item 2 Stimpak
                    , item 1 BigBookOfScience
                    , item 1 DeansElectronics
                    , item 2 Robes
                    ]
            }

        KlamathVic ->
            { caps = { average = 600, maxDeviation = 200 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 PlasmaPistol
                      -- item 1 MetalArmorMk2
                      -- item 1 SuperToolKit
                      item 1 LaserPistol
                    , item 2 Pistol14mm
                    , item 1 CombatShotgun
                    , item 1 HkP90c
                    , item 30 MicrofusionCell
                    , item 40 SmallEnergyCell
                    , item 50 Ap14mm
                    , item 50 ShotgunShell
                    , item 40 Mm9
                    , item 2 CombatArmor
                    , item 5 SuperStimpak
                    , item 10 Stimpak
                    , item 1 ElectronicLockpick
                    , item 1 GunsAndBullets
                    , item 1 BigBookOfScience
                    ]
            }

        DenFlick ->
            { caps = { average = 280, maxDeviation = 120 }
            , stock =
                SeqDict.fromList
                    [ item 1 HealingPowder
                    , item 3 Stimpak
                    , item 1 ScoutHandbook
                    , item 1 GunsAndBullets
                    , item 1 LeatherJacket
                    ]
            }

        ModocJo ->
            { caps = { average = 200, maxDeviation = 100 }
            , stock =
                SeqDict.fromList
                    [ -- item 2 Dynamite
                      -- item 2 Rope
                      item 20 Jhp10mm

                    -- the rest is given by a quest
                    ]
            }

        VaultCityRandal ->
            { caps = { average = 400, maxDeviation = 200 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 Rope
                      -- item 5 RadX
                      -- item 3 RadAway
                      -- item 1 FnFal
                      -- item 2 Pistol10mm
                      -- item 1 Club
                      item 2 Flare
                    , item 2 BigBookOfScience
                    , item 1 DeansElectronics
                    , item 1 FirstAidBook
                    , item 8 Stimpak
                    , item 2 MetalArmor
                    , item 10 Ap14mm
                    , item 30 ShotgunShell
                    , item 30 Jhp10mm
                    , item 1 CombatShotgun
                    , item 2 Smg10mm
                    , item 2 Shotgun
                    , item 1 Pistol14mm
                    , item 3 Knife
                    , item 2 FragGrenade
                    ]
            }

        VaultCityHappyHarry ->
            { caps = { average = 270, maxDeviation = 120 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 MagnumRevolver44
                      -- item 1 DesertEagle
                      -- item 2 Pistol10mm
                      -- item 2 Crowbar
                      -- item 1 Dynamite
                      -- item 30 FmjMagnum44
                      -- item 30 JhpMagnum44
                      -- item 1 Rope
                      -- item 1 Shovel
                      -- item 1 Booze
                      item 1 Smg10mm
                    , item 1 HuntingRifle
                    , item 2 Shotgun
                    , item 2 FragGrenade
                    , item 3 Knife
                    , item 20 Fmj223
                    , item 30 ShotgunShell
                    , item 30 Ap10mm
                    , item 50 Jhp10mm
                    , item 1 MetalArmor
                    , item 1 LeatherArmor
                    , item 2 LeatherJacket
                    , item 2 Flare
                    , item 1 Beer
                    ]
            }

        GeckoSurvivalGearPercy ->
            { caps = { average = 750, maxDeviation = 250 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 FnFal
                      -- item 1 Pistol10mm
                      -- item 2 Mm762
                      -- item 40 Magnum44Fmj
                      -- item 40 Magnum44Jhp
                      -- item 1 RadX
                      -- item 1 RadAway
                      -- item 1 Rope
                      item 1 Pistol14mm
                    , item 2 Knife
                    , item 30 Fmj223
                    , item 50 ShotgunShell
                    , item 60 Ap14mm
                    , item 10 Jhp10mm
                    , item 10 Ap10mm
                    , item 6 Stimpak
                    ]
            }

        ReddingAscorti ->
            { caps = { average = 350, maxDeviation = 150 }
            , stock =
                SeqDict.fromList
                    [ -- item 5 Jet
                      -- item 1 PlasticExplosive
                      -- item 2 Dynamite
                      -- item 1 Pistol10mm
                      -- item 2 Shovel
                      -- item 2 Rope
                      -- item 1 SuperToolKit
                      -- item 3 BoxOfNoodles
                      -- item 1 Booze
                      item 3 Stimpak
                    , item 2 SuperStimpak
                    , item 10 FragGrenade
                    , item 3 Knife
                    , item 1 Shotgun
                    , item 30 ShotgunShell
                    , item 50 Jhp10mm
                    , item 5 MeatJerky
                    , item 10 Fruit
                    , item 2 Beer
                    ]
            }

        BrokenHillsGeneralStoreLiz ->
            { caps = { average = 200, maxDeviation = 100 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 CombatKnife
                      -- item 5 Rope
                      -- item 3 WaterFlask
                      item 2 Knife
                    , item 10 Fmj223
                    , item 50 Jhp10mm
                    , item 50 Ap10mm
                    , item 2 MetalArmor
                    , item 2 LeatherArmor
                    , item 6 Stimpak
                    , item 1 ScoutHandbook
                    , item 1 BigBookOfScience
                    , item 1 DeansElectronics
                    , item 1 FirstAidBook
                    , item 10 Flare
                    ]
            }

        BrokenHillsChemistJacob ->
            { caps = { average = 725, maxDeviation = 575 }
            , stock =
                SeqDict.fromList
                    [ -- item 3 MolotovCocktail
                      -- item 6 Psycho
                      -- item 3 Buffout
                      -- item 4 Jet
                      -- item 4 RadX
                      -- item 6 RadAway
                      item 3 SuperStimpak
                    , item 5 Stimpak
                    , item 2 HealingPowder
                    ]
            }

        NewRenoArmsEldridge ->
            { caps = { average = 600, maxDeviation = 200 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 GreaseGun
                      -- item 2 FnFal
                      -- item 2 TommyGun
                      -- item 2 DesertEagle
                      -- item 1 MagnumRevolver44
                      -- item 2 Pistol10mm
                      -- item 2 PipeRifle
                      -- item 3 MolotovCocktail
                      -- item 1 PlasticExplosive
                      -- item 1 Dynamite
                      -- item 50 Caliber45
                      -- item 30 JhpMagnum44
                      -- item 30 FmjMagnum44
                      -- item 1 MetalArmorMk2
                      -- item 2 LeatherArmorMk2
                      item 2 Pistol14mm
                    , item 2 Smg10mm
                    , item 2 HuntingRifle
                    , item 2 Shotgun
                    , item 3 FragGrenade
                    , item 50 Fmj223
                    , item 30 Ap14mm
                    , item 50 ShotgunShell
                    , item 50 Jhp10mm
                    , item 30 Ap10mm
                    , item 1 MetalArmor
                    , item 2 LeatherArmor
                    , item 3 LeatherJacket
                    , item 1 GunsAndBullets

                    -- Rest is given by quest
                    ]
            }

        NewRenoRenescoPharmacy ->
            { caps = { average = 375, maxDeviation = 125 }
            , stock =
                SeqDict.fromList
                    [ -- item 10 FlamethrowerFuel
                      -- item 1 Mentats
                      -- item 1 Psycho
                      -- item 2 Buffout
                      -- item 10 Jet
                      -- item 5 RadX
                      -- item 5 RadAway
                      -- item 5 Antidote
                      -- item 1 JimmyHat
                      -- item 1 Rope
                      item 1 SuperStimpak
                    , item 10 Stimpak
                    , item 1 FirstAidBook
                    , item 5 Flare
                    ]
            }

        NCRBuster ->
            { caps = { average = 425, maxDeviation = 425 }
            , stock =
                SeqDict.fromList
                    [ -- item 1 AvengerMinigun
                      -- item 2 HkG11
                      -- item 1 LightSupportWeapon
                      -- item 1 RedRyderBBGun
                      -- item 4 DesertEagle
                      -- item 4 Pistol10mm
                      -- item 1 Switchblade
                      -- item 5 Club
                      -- item 5 Spear
                      -- item 5 Rock
                      -- item 5 Crowbar
                      -- item 5 BrassKnuckles
                      -- item 15 ThrowingKnife
                      -- item 5 CombatKnife
                      -- item 2 SpikedKnuckles
                      -- item 1 SharpenedSpear
                      -- item 1 Dynamite
                      -- item 50 EcMm2
                      -- item 40 CaselessMm47
                      -- item 80 Mm762
                      -- item 100 JhpMagnum44
                      -- item 1 LeatherArmorMk2
                      -- item 4 ExpandedLockpickSet
                      -- item 1 Lockpick
                      -- item 5 Rope
                      -- item 1 TragicTheGarnering
                      item 1 PancorJackhammer
                    , item 3 Pistol223
                    , item 3 Smg10mm
                    , item 3 HuntingRifle
                    , item 1 RedRyderLEBBGun
                    , item 1 Shotgun
                    , item 1 Ripper
                    , item 1 CattleProd
                    , item 5 Knife
                    , item 50 Jhp5mm
                    , item 30 Ap5mm
                    , item 40 MicrofusionCell
                    , item 50 SmallEnergyCell
                    , item 500 BBAmmo
                    , item 100 Fmj223
                    , item 100 ShotgunShell
                    , item 50 HnApNeedlerCartridge
                    , item 150 Jhp10mm
                    , item 100 Ap10mm
                    , item 1 MetalArmor
                    , item 5 MetalArmor
                    , item 3 LeatherArmor
                    , item 3 LeatherJacket
                    , item 1 GunsAndBullets
                    ]
            }

        NCRDuppo ->
            { caps = { average = 400, maxDeviation = 200 }
            , stock =
                SeqDict.fromList
                    [ -- item 3 FnFal
                      -- item 3 DesertEagle
                      -- item 1 MagnumRevolver44
                      -- item 4 SpikedKnuckles
                      -- item 1 BoxingGloves
                      -- item 4 CombatKnife
                      -- item 10 ThrowingKnife
                      -- item 3 Crowbar
                      -- item 100 Mm762
                      -- item 50 JhpMagnum44
                      -- item 3 MetalArmorMk2
                      -- item 2 GeigerCounter
                      -- item 1 TragicTheGarnering
                      -- item 4 Rope
                      item 1 HkCaws
                    , item 1 CombatShotgun
                    , item 2 HkP90c
                    , item 2 PowerFist
                    , item 1 AssaultRifle
                    , item 3 HuntingRifle
                    , item 3 Shotgun
                    , item 7 FragGrenade
                    , item 200 BBAmmo
                    , item 50 Mm9
                    , item 30 MicrofusionCell
                    , item 100 Jhp5mm
                    , item 100 Ap5mm
                    , item 150 Fmj223
                    , item 200 ShotgunShell
                    , item 100 Ap14mm
                    , item 300 Ap10mm
                    , item 1 CombatArmor
                    , item 4 SuperStimpak
                    , item 7 Stimpak
                    , item 7 Flare
                    ]
            }

        SanFranciscoFlyingDragon8LaoChou ->
            { caps = { average = 3500, maxDeviation = 1500 }
            , stock =
                SeqDict.fromList
                    [ -- item 3 SpikedKnuckles
                      -- item 1 Crowbar
                      -- item 2 Shiv
                      -- item 2 Wrench
                      -- item 6 Dynamite
                      -- item 4 PlasticExplosive
                      -- item 40 ApRocket
                      -- item 50 Caliber45
                      -- item 40 Mm762
                      -- item 40 FlamethrowerFuel
                      -- item 30 FlamethrowerFuelMk2
                      -- item 2 MetalArmorMk2
                      -- item 8 Mentats
                      -- item 8 Buffout
                      -- item 8 Psycho
                      -- item 2 FirstAidKit
                      -- item 4 Antidote
                      -- item 7 RadAway
                      -- item 7 RadX
                      -- item 3 JetAntidote
                      -- item 3 DoctorsBag
                      -- item 2 FieldMedicFirstAidKit
                      -- item 5 Shovel
                      -- item 7 SuperToolKit
                      -- item 20 JimmyHat
                      -- item 5 BrocFlower
                      -- item 7 XanderRoot
                      -- item 5 TechnicalManual
                      -- item 3 ChemistryJournal
                      -- item 2 GeigerCounter
                      -- item 3 MultiTool
                      -- item 4 Lockpick
                      -- item 5 Rope
                      -- item 6 ExpandedLockpickSet
                      -- item 1 ElectronicLockpickMk2
                      -- item 7 BoxOfNoodles
                      item 2 RocketLauncher
                    , item 3 LaserPistol
                    , item 1 Pistol223
                    , item 2 HkP90c
                    , item 2 Minigun
                    , item 1 LaserRifle
                    , item 1 MagnetoLaserPistol
                    , item 40 MicrofusionCell
                    , item 30 Ap14mm
                    , item 50 Jhp10mm
                    , item 50 Ap10mm
                    , item 100 Fmj223
                    , item 50 Mm9
                    , item 50 HnNeedlerCartridge
                    , item 30 HnApNeedlerCartridge
                    , item 3 TeslaArmor
                    , item 4 LeatherJacket
                    , item 2 PowerArmor
                    , item 7 Stimpak
                    , item 7 SuperStimpak
                    , item 7 HealingPowder
                    , item 2 BigBookOfScience
                    , item 3 DeansElectronics
                    , item 4 FirstAidBook
                    , item 4 ScoutHandbook
                    , item 2 GunsAndBullets
                    , item 8 Fruit
                    , item 5 MeatJerky
                    , item 4 MotionSensor
                    , item 5 ElectronicLockpick
                    ]
            }

        SanFranciscoRed888GunsMaiDaChiang ->
            { caps = { average = 1500, maxDeviation = 500 }
            , stock =
                SeqDict.fromList
                    [ -- item 2 Flamer
                      -- item 2 PlasmaGrenade
                      -- item 7 ThrowingKnife
                      -- item 10 MolotovCocktail
                      -- item 7 SpikedKnuckles
                      -- item 3 CombatKnife
                      -- item 3 MagnumRevolver44
                      -- item 1 LightSupportWeapon
                      -- item 3 FnFal
                      -- item 4 HkG11
                      -- item 1 AvengerMinigun
                      -- item 1 HkG11e
                      -- item 1 VindicatorMinigun
                      -- item 70 Mm762
                      -- item 50 FlamethrowerFuelMk2
                      -- item 60 ApRocket
                      -- item 50 FlamethrowerFuel
                      -- item 50 JhpMagnum44
                      -- item 50 FmjMagnum44
                      -- item 70 Caliber45
                      -- item 40 CaselessMm47
                      -- item 40 EcMm2
                      -- item 2 CombatLeatherJacket
                      -- item 2 LeatherArmorMk2
                      -- item 3 MetalArmorMk2
                      item 3 Minigun
                    , item 3 RocketLauncher
                    , item 4 LaserPistol
                    , item 7 FragGrenade
                    , item 1 GatlingLaser
                    , item 2 SuperSledge
                    , item 4 Ripper
                    , item 3 LaserRifle
                    , item 2 PowerFist
                    , item 2 Pistol223
                    , item 5 HkCaws
                    , item 2 HkP90c
                    , item 2 PancorJackhammer
                    , item 1 GaussRifle
                    , item 1 GaussPistol
                    , item 2 MegaPowerFist
                    , item 3 ExplosiveRocket
                    , item 100 Jhp10mm
                    , item 100 Ap10mm
                    , item 50 Mm9
                    , item 70 MicrofusionCell
                    , item 90 SmallEnergyCell
                    , item 100 Jhp5mm
                    , item 100 Ap5mm
                    , item 100 Fmj223
                    , item 50 Ap14mm
                    , item 100 HnNeedlerCartridge
                    , item 100 HnApNeedlerCartridge
                    , item 70 ShotgunShell
                    , item 2 CombatArmor
                    , item 4 TeslaArmor
                    , item 4 MetalArmor
                    , item 4 LeatherJacket
                    , item 3 PowerArmor
                    , item 1 CombatArmorMk2
                    ]
            }

        SanFranciscoPunksCal ->
            { caps = { average = 368, maxDeviation = 68 }
            , stock =
                SeqDict.fromList
                    [ -- item 3 SpikedKnuckles
                      -- item 1 Crowbar
                      -- item 2 Shiv
                      -- item 2 Wrench
                      -- item 8 Mentats
                      -- item 8 Buffout
                      -- item 8 Psycho
                      -- item 3 JetAntidote
                      -- item 2 FirstAidKit
                      -- item 7 RadAway
                      item 1 MegaPowerFist
                    , item 7 SuperStimpak
                    , item 7 Stimpak
                    , item 8 Fruit
                    , item 5 MeatJerky
                    ]
            }

        SanFranciscoPunksJenna ->
            { caps = { average = 736, maxDeviation = 136 }
            , stock =
                SeqDict.fromList
                    [ -- item 4 PlasticExplosive
                      -- item 6 Dynamite
                      -- item 8 Mentats
                      -- item 2 FirstAidKit
                      -- item 20 RadAway
                      -- item 2 ElectronicLockpickMk2
                      -- item 6 ExpandedLockpickSet
                      -- item 4 Lockpick
                      -- item 7 SuperToolKit
                      -- item 3 MultiTool
                      -- item 2 GeigerCounter
                      -- item 5 TechnicalManual
                      -- item 3 ChemistryJournal
                      -- item 80 JimmyHat
                      -- item 5 Rope
                      -- item 5 Shovel
                      -- item 10 TvDinner
                      -- item 7 BoxOfNoodles
                      item 7 SuperStimpak
                    , item 20 Stimpak
                    , item 4 ScoutHandbook
                    , item 2 BigBookOfScience
                    , item 3 DeansElectronics
                    , item 4 FirstAidBook
                    , item 2 GunsAndBullets
                    , item 5 ElectronicLockpick
                    , item 4 MotionSensor
                    , item 8 Fruit
                    , item 5 MeatJerky
                    ]
            }


codec : Codec Shop
codec =
    Codec.custom
        (\arroyoHakuninEncoder klamathMaidaEncoder klamathVicEncoder denFlickEncoder modocJoEncoder vaultCityRandalEncoder vaultCityHappyHarryEncoder geckoSurvivalGearPercyEncoder reddingAscortiEncoder brokenHillsGeneralStoreLizEncoder brokenHillsChemistJacobEncoder newRenoArmsEldridgeEncoder newRenoRenescoPharmacyEncoder nCRBusterEncoder nCRDuppoEncoder sanFranciscoFlyingDragon8LaoChouEncoder sanFranciscoRed888GunsMaiDaChiangEncoder sanFranciscoPunksCalEncoder sanFranciscoPunksJennaEncoder value ->
            case value of
                ArroyoHakunin ->
                    arroyoHakuninEncoder

                KlamathMaida ->
                    klamathMaidaEncoder

                KlamathVic ->
                    klamathVicEncoder

                DenFlick ->
                    denFlickEncoder

                ModocJo ->
                    modocJoEncoder

                VaultCityRandal ->
                    vaultCityRandalEncoder

                VaultCityHappyHarry ->
                    vaultCityHappyHarryEncoder

                GeckoSurvivalGearPercy ->
                    geckoSurvivalGearPercyEncoder

                ReddingAscorti ->
                    reddingAscortiEncoder

                BrokenHillsGeneralStoreLiz ->
                    brokenHillsGeneralStoreLizEncoder

                BrokenHillsChemistJacob ->
                    brokenHillsChemistJacobEncoder

                NewRenoArmsEldridge ->
                    newRenoArmsEldridgeEncoder

                NewRenoRenescoPharmacy ->
                    newRenoRenescoPharmacyEncoder

                NCRBuster ->
                    nCRBusterEncoder

                NCRDuppo ->
                    nCRDuppoEncoder

                SanFranciscoFlyingDragon8LaoChou ->
                    sanFranciscoFlyingDragon8LaoChouEncoder

                SanFranciscoRed888GunsMaiDaChiang ->
                    sanFranciscoRed888GunsMaiDaChiangEncoder

                SanFranciscoPunksCal ->
                    sanFranciscoPunksCalEncoder

                SanFranciscoPunksJenna ->
                    sanFranciscoPunksJennaEncoder
        )
        |> Codec.variant0 "ArroyoHakunin" ArroyoHakunin
        |> Codec.variant0 "KlamathMaida" KlamathMaida
        |> Codec.variant0 "KlamathVic" KlamathVic
        |> Codec.variant0 "DenFlick" DenFlick
        |> Codec.variant0 "ModocJo" ModocJo
        |> Codec.variant0 "VaultCityRandal" VaultCityRandal
        |> Codec.variant0 "VaultCityHappyHarry" VaultCityHappyHarry
        |> Codec.variant0 "GeckoSurvivalGearPercy" GeckoSurvivalGearPercy
        |> Codec.variant0 "ReddingAscorti" ReddingAscorti
        |> Codec.variant0 "BrokenHillsGeneralStoreLiz" BrokenHillsGeneralStoreLiz
        |> Codec.variant0 "BrokenHillsChemistJacob" BrokenHillsChemistJacob
        |> Codec.variant0 "NewRenoArmsEldridge" NewRenoArmsEldridge
        |> Codec.variant0 "NewRenoRenescoPharmacy" NewRenoRenescoPharmacy
        |> Codec.variant0 "NCRBuster" NCRBuster
        |> Codec.variant0 "NCRDuppo" NCRDuppo
        |> Codec.variant0 "SanFranciscoFlyingDragon8LaoChou" SanFranciscoFlyingDragon8LaoChou
        |> Codec.variant0 "SanFranciscoRed888GunsMaiDaChiang" SanFranciscoRed888GunsMaiDaChiang
        |> Codec.variant0 "SanFranciscoPunksCal" SanFranciscoPunksCal
        |> Codec.variant0 "SanFranciscoPunksJenna" SanFranciscoPunksJenna
        |> Codec.buildCustom


specCodec : Codec ShopSpec
specCodec =
    Codec.object ShopSpec
        |> Codec.field "caps" .caps RandomFloat.normalIntSpecCodec
        |> Codec.field
            "stock"
            .stock
            (SeqDict.codec
                Item.uniqueKeyCodec
                (Codec.object (\maxCount -> { maxCount = maxCount })
                    |> Codec.field "maxCount" .maxCount Codec.int
                    |> Codec.buildObject
                )
            )
        |> Codec.buildObject


locationsWithShops : SeqDict Location (List Shop)
locationsWithShops =
    all
        |> List.map (\shop -> ( shop, location shop ))
        |> List.foldl
            (\( shop, location_ ) acc ->
                acc
                    |> SeqDict.update location_ (Maybe.withDefault [] >> (::) shop >> Just)
            )
            SeqDict.empty


forLocation : Location -> List Shop
forLocation loc =
    SeqDict.get loc locationsWithShops
        |> Maybe.withDefault []


isInLocation : Location -> Shop -> Bool
isInLocation loc shop =
    forLocation loc
        |> List.member shop
