module Data.Enemy.Type exposing
    ( EnemyType(..)
    , actionPoints
    , addedSkillPercentages
    , all
    , codec
    , damageResistance
    , damageThreshold
    , equippedArmor
    , equippedWeapon
    , hp
    , isLivingCreature
    , name
    , naturalArmorClass
    , preferredAmmo
    , sequence
    , special
    , unarmedDamageBonus
    , xpReward
    )

import Codec exposing (Codec)
import Data.Fight.DamageType exposing (DamageType(..))
import Data.Item.Kind as ItemKind
import Data.Skill exposing (Skill(..))
import Data.Special exposing (Special)
import Data.Xp exposing (BaseXp(..))
import SeqDict exposing (SeqDict)


type EnemyType
    = --  -- Mantises: https://fallout.fandom.com/wiki/Mantis_(Fallout)
      --| Mantis
      --  -- Dogs: https://fallout.fandom.com/wiki/Dog_(Fallout)
      --| Dog
      --| WildDog
      --  -- Rats: https://fallout.fandom.com/wiki/Rat_(Fallout)
      --| Rat
      --| MutatedRat
      --  -- Mole Rats: https://fallout.fandom.com/wiki/Mole_rat_(Fallout)
      --| MoleRat
      --| GreaterMoleRat
      --| MutatedMoleRat
      --  -- Pig Rats: https://fallout.fandom.com/wiki/Pig_rat
      --| PigRat
      --| ToughPigRat
      --| MutatedPigRat
      --  -- Deathclaws: https://fallout.fandom.com/wiki/Deathclaw_(Fallout)
      --| Deathclaw1
      --| Deathclaw2
      --| SmallToughDeathclaw
      --| ToughDeathclaw
      -- Geckos: https://fallout.fandom.com/wiki/Gecko_(Fallout_2)
      SilverGecko
    | ToughSilverGecko
    | GoldenGecko
    | ToughGoldenGecko
    | FireGecko -- TODO fire breath
    | ToughFireGecko -- TODO fire breath
      --  -- Centaurs: https://fallout.fandom.com/wiki/Centaur_(Fallout)
      --| Centaur
      --| MeanCentaur
      --  -- Floaters: https://fallout.fandom.com/wiki/Floater_(Fallout)
      --| Floater
      --| NastyFloater
      --  -- TODO Cut enemies:
      --  -- TODO | SporePlant -- has a ranged projectile, let's skip this for now
      --  -- TODO | SuperMutant
      --  -- TODO | Ghoul
      --  -- TODO | Cannibal
      --  -- TODO | Nomad
      --  -- TODO | Outcast
      --  -- TODO | Slave
      --  -- and many others...
      --  -- Wanamingos: https://fallout.fandom.com/wiki/Wanamingo
      --| Wanamingo
      --| ToughWanamingo
      -- Giant Ants: https://fallout.fandom.com/wiki/Giant_ant_(Fallout_2)
      -- Brahmins: https://fallout.fandom.com/wiki/Brahmin_(Fallout)
    | Brahmin
    | AngryBrahmin
    | WeakBrahmin
    | WildBrahmin
    | GiantAnt
    | ToughGiantAnt
      -- Radscorpions: https://fallout.fandom.com/wiki/Radscorpion_(Fallout)
    | BlackRadscorpion
    | LesserBlackRadscorpion
    | LesserRadscorpion
    | Radscorpion


all : List EnemyType
all =
    [ SilverGecko
    , ToughSilverGecko
    , GoldenGecko
    , ToughGoldenGecko
    , FireGecko
    , ToughFireGecko
    , Brahmin
    , AngryBrahmin
    , WeakBrahmin
    , WildBrahmin
    , GiantAnt
    , ToughGiantAnt
    , BlackRadscorpion
    , LesserBlackRadscorpion
    , LesserRadscorpion
    , Radscorpion
    ]


xpReward : EnemyType -> BaseXp
xpReward type_ =
    BaseXp <|
        case type_ of
            Brahmin ->
                80

            AngryBrahmin ->
                150

            WeakBrahmin ->
                40

            WildBrahmin ->
                120

            GiantAnt ->
                25

            ToughGiantAnt ->
                50

            LesserRadscorpion ->
                60

            Radscorpion ->
                110

            BlackRadscorpion ->
                220

            LesserBlackRadscorpion ->
                110

            SilverGecko ->
                55

            ToughSilverGecko ->
                60

            GoldenGecko ->
                135

            ToughGoldenGecko ->
                210

            FireGecko ->
                250

            ToughFireGecko ->
                260


hp : EnemyType -> Int
hp type_ =
    case type_ of
        Brahmin ->
            35

        AngryBrahmin ->
            70

        WeakBrahmin ->
            30

        WildBrahmin ->
            65

        GiantAnt ->
            6

        ToughGiantAnt ->
            12

        LesserRadscorpion ->
            10

        Radscorpion ->
            26

        BlackRadscorpion ->
            50

        LesserBlackRadscorpion ->
            26

        SilverGecko ->
            25

        ToughSilverGecko ->
            45

        GoldenGecko ->
            45

        ToughGoldenGecko ->
            65

        FireGecko ->
            70

        ToughFireGecko ->
            80


name : EnemyType -> String
name type_ =
    case type_ of
        Brahmin ->
            "Brahmin"

        AngryBrahmin ->
            "Angry Brahmin"

        WeakBrahmin ->
            "Weak Brahmin"

        WildBrahmin ->
            "Wild Brahmin"

        GiantAnt ->
            "Giant Ant"

        ToughGiantAnt ->
            "Tough Giant Ant"

        LesserRadscorpion ->
            "Lesser Radscorpion"

        Radscorpion ->
            "Radscorpion"

        LesserBlackRadscorpion ->
            "Lesser Black Radscorpion"

        BlackRadscorpion ->
            "Black Radscorpion"

        SilverGecko ->
            "Silver Gecko"

        ToughSilverGecko ->
            "Tough Silver Gecko"

        GoldenGecko ->
            "Golden Gecko"

        ToughGoldenGecko ->
            "Tough Golden Gecko"

        FireGecko ->
            "Fire Gecko"

        ToughFireGecko ->
            "Tough Fire Gecko"


special : EnemyType -> Special
special type_ =
    case type_ of
        Brahmin ->
            Special 8 3 8 3 2 4 1

        AngryBrahmin ->
            Special 9 5 5 1 3 7 5

        WeakBrahmin ->
            Special 4 3 4 1 1 3 1

        WildBrahmin ->
            Special 8 5 5 1 3 6 5

        GiantAnt ->
            Special 1 2 1 1 1 4 1

        ToughGiantAnt ->
            Special 2 2 2 1 1 3 5

        LesserRadscorpion ->
            Special 5 2 6 1 1 3 2

        Radscorpion ->
            Special 7 2 6 1 1 5 2

        LesserBlackRadscorpion ->
            Special 5 2 6 1 1 5 2

        BlackRadscorpion ->
            Special 8 3 7 1 1 5 3

        SilverGecko ->
            Special 4 3 3 1 1 5 3

        ToughSilverGecko ->
            Special 5 3 3 1 1 6 4

        GoldenGecko ->
            Special 6 3 3 1 1 7 4

        ToughGoldenGecko ->
            Special 7 3 3 1 1 8 5

        FireGecko ->
            Special 7 7 4 1 1 8 6

        ToughFireGecko ->
            Special 8 8 5 1 1 10 8


addedSkillPercentages : EnemyType -> SeqDict Skill Int
addedSkillPercentages type_ =
    case type_ of
        Brahmin ->
            SeqDict.fromList
                [ ( Unarmed, 19 )
                ]

        AngryBrahmin ->
            SeqDict.fromList
                [ ( Unarmed, 63 )
                , ( MeleeWeapons, 73 )
                ]

        WeakBrahmin ->
            SeqDict.empty

        WildBrahmin ->
            SeqDict.fromList
                [ ( Unarmed, 52 )
                , ( MeleeWeapons, 2 )
                ]

        GiantAnt ->
            SeqDict.fromList
                [ ( Unarmed, 25 )
                , ( MeleeWeapons, 35 )
                ]

        ToughGiantAnt ->
            SeqDict.fromList
                [ ( Unarmed, 40 )
                , ( MeleeWeapons, 50 )
                ]

        LesserRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 29 )
                ]

        Radscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 21 )
                ]

        LesserBlackRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 25 )
                ]

        BlackRadscorpion ->
            SeqDict.fromList
                [ ( Unarmed, 54 )
                ]

        SilverGecko ->
            SeqDict.fromList
                [ ( Unarmed, 17 )
                ]

        ToughSilverGecko ->
            SeqDict.fromList
                [ ( Unarmed, 23 )
                ]

        GoldenGecko ->
            SeqDict.fromList
                [ ( Unarmed, 34 )
                ]

        ToughGoldenGecko ->
            SeqDict.fromList
                [ ( Unarmed, 40 )
                ]

        FireGecko ->
            SeqDict.fromList
                [ ( SmallGuns, 43 )
                , ( EnergyWeapons, 64 )
                , ( Unarmed, 60 )
                , ( MeleeWeapons, 50 )
                ]

        ToughFireGecko ->
            SeqDict.fromList
                [ ( SmallGuns, 55 )
                , ( EnergyWeapons, 80 )
                , ( Unarmed, 64 )
                , ( MeleeWeapons, 54 )
                ]


equippedArmor : EnemyType -> Maybe ItemKind.Kind
equippedArmor type_ =
    case type_ of
        Brahmin ->
            Nothing

        AngryBrahmin ->
            Nothing

        WeakBrahmin ->
            Nothing

        WildBrahmin ->
            Nothing

        GiantAnt ->
            Nothing

        ToughGiantAnt ->
            Nothing

        LesserRadscorpion ->
            Nothing

        Radscorpion ->
            Nothing

        LesserBlackRadscorpion ->
            Nothing

        BlackRadscorpion ->
            Nothing

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
            Nothing


equippedWeapon : EnemyType -> Maybe ItemKind.Kind
equippedWeapon type_ =
    case type_ of
        Brahmin ->
            Nothing

        AngryBrahmin ->
            Nothing

        WeakBrahmin ->
            Nothing

        WildBrahmin ->
            Nothing

        GiantAnt ->
            Nothing

        ToughGiantAnt ->
            Nothing

        LesserRadscorpion ->
            Nothing

        Radscorpion ->
            Nothing

        LesserBlackRadscorpion ->
            Nothing

        BlackRadscorpion ->
            Nothing

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
            Nothing


preferredAmmo : EnemyType -> Maybe ItemKind.Kind
preferredAmmo type_ =
    case type_ of
        Brahmin ->
            Nothing

        AngryBrahmin ->
            Nothing

        WeakBrahmin ->
            Nothing

        WildBrahmin ->
            Nothing

        GiantAnt ->
            Nothing

        ToughGiantAnt ->
            Nothing

        LesserRadscorpion ->
            Nothing

        Radscorpion ->
            Nothing

        LesserBlackRadscorpion ->
            Nothing

        BlackRadscorpion ->
            Nothing

        SilverGecko ->
            Nothing

        ToughSilverGecko ->
            Nothing

        GoldenGecko ->
            Nothing

        ToughGoldenGecko ->
            Nothing

        FireGecko ->
            Nothing

        ToughFireGecko ->
            Nothing


naturalArmorClass : EnemyType -> Int
naturalArmorClass type_ =
    case type_ of
        Brahmin ->
            4

        AngryBrahmin ->
            22

        WeakBrahmin ->
            1

        WildBrahmin ->
            21

        GiantAnt ->
            4

        ToughGiantAnt ->
            3

        LesserRadscorpion ->
            3

        Radscorpion ->
            5

        BlackRadscorpion ->
            5

        LesserBlackRadscorpion ->
            5

        SilverGecko ->
            13

        ToughSilverGecko ->
            14

        GoldenGecko ->
            22

        ToughGoldenGecko ->
            23

        FireGecko ->
            28

        ToughFireGecko ->
            30


sequence : EnemyType -> Int
sequence type_ =
    case type_ of
        Brahmin ->
            6

        AngryBrahmin ->
            10

        WeakBrahmin ->
            6

        WildBrahmin ->
            10

        GiantAnt ->
            9

        ToughGiantAnt ->
            9

        LesserRadscorpion ->
            4

        Radscorpion ->
            4

        BlackRadscorpion ->
            6

        LesserBlackRadscorpion ->
            4

        SilverGecko ->
            6

        ToughSilverGecko ->
            6

        GoldenGecko ->
            6

        ToughGoldenGecko ->
            6

        FireGecko ->
            14

        ToughFireGecko ->
            16


actionPoints : EnemyType -> Int
actionPoints type_ =
    case type_ of
        Brahmin ->
            7

        AngryBrahmin ->
            10

        WeakBrahmin ->
            6

        WildBrahmin ->
            10

        GiantAnt ->
            5

        ToughGiantAnt ->
            6

        LesserRadscorpion ->
            5

        Radscorpion ->
            7

        BlackRadscorpion ->
            5

        LesserBlackRadscorpion ->
            7

        SilverGecko ->
            7

        ToughSilverGecko ->
            7

        GoldenGecko ->
            8

        ToughGoldenGecko ->
            10

        FireGecko ->
            9

        ToughFireGecko ->
            12


unarmedDamageBonus : EnemyType -> Int
unarmedDamageBonus type_ =
    case type_ of
        Brahmin ->
            7

        AngryBrahmin ->
            4

        WeakBrahmin ->
            1

        WildBrahmin ->
            7

        GiantAnt ->
            2

        ToughGiantAnt ->
            4

        LesserRadscorpion ->
            4

        Radscorpion ->
            6

        BlackRadscorpion ->
            12

        LesserBlackRadscorpion ->
            10

        SilverGecko ->
            2

        ToughSilverGecko ->
            3

        GoldenGecko ->
            4

        ToughGoldenGecko ->
            7

        FireGecko ->
            12

        ToughFireGecko ->
            15


damageResistance : DamageType -> EnemyType -> Int
damageResistance damageType type_ =
    case damageType of
        NormalDamage ->
            damageResistanceNormal type_

        Fire ->
            damageResistanceFire type_

        Plasma ->
            damageResistancePlasma type_

        Laser ->
            damageResistanceLaser type_

        Explosion ->
            damageResistanceExplosion type_

        Electrical ->
            damageResistanceElectrical type_

        EMP ->
            damageResistanceEMP type_


damageThreshold : DamageType -> EnemyType -> Int
damageThreshold damageType type_ =
    case damageType of
        NormalDamage ->
            damageThresholdNormal type_

        Fire ->
            damageThresholdFire type_

        Plasma ->
            damageThresholdPlasma type_

        Laser ->
            damageThresholdLaser type_

        Explosion ->
            damageThresholdExplosion type_

        Electrical ->
            damageThresholdElectrical type_

        EMP ->
            damageThresholdEMP type_


damageThresholdNormal : EnemyType -> Int
damageThresholdNormal type_ =
    case type_ of
        Brahmin ->
            0

        AngryBrahmin ->
            2

        WeakBrahmin ->
            0

        WildBrahmin ->
            2

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        BlackRadscorpion ->
            4

        LesserBlackRadscorpion ->
            2

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            2

        ToughGoldenGecko ->
            2

        FireGecko ->
            5

        ToughFireGecko ->
            5


damageResistanceNormal : EnemyType -> Int
damageResistanceNormal type_ =
    case type_ of
        Brahmin ->
            20

        AngryBrahmin ->
            25

        WeakBrahmin ->
            20

        WildBrahmin ->
            25

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        BlackRadscorpion ->
            10

        LesserBlackRadscorpion ->
            0

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            25

        ToughGoldenGecko ->
            25

        FireGecko ->
            40

        ToughFireGecko ->
            40


isLivingCreature : EnemyType -> Bool
isLivingCreature type_ =
    case type_ of
        SilverGecko ->
            True

        ToughSilverGecko ->
            True

        GoldenGecko ->
            True

        ToughGoldenGecko ->
            True

        FireGecko ->
            True

        ToughFireGecko ->
            True

        Brahmin ->
            True

        AngryBrahmin ->
            True

        WeakBrahmin ->
            True

        WildBrahmin ->
            True

        GiantAnt ->
            True

        ToughGiantAnt ->
            True

        BlackRadscorpion ->
            True

        LesserBlackRadscorpion ->
            True

        LesserRadscorpion ->
            True

        Radscorpion ->
            True


damageResistanceEMP : EnemyType -> Int
damageResistanceEMP type_ =
    case type_ of
        SilverGecko ->
            500

        ToughSilverGecko ->
            500

        GoldenGecko ->
            500

        ToughGoldenGecko ->
            500

        FireGecko ->
            500

        ToughFireGecko ->
            500

        Brahmin ->
            500

        AngryBrahmin ->
            500

        WeakBrahmin ->
            500

        WildBrahmin ->
            500

        GiantAnt ->
            500

        ToughGiantAnt ->
            500

        BlackRadscorpion ->
            500

        LesserBlackRadscorpion ->
            500

        LesserRadscorpion ->
            500

        Radscorpion ->
            500


damageThresholdEMP : EnemyType -> Int
damageThresholdEMP type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            0

        ToughFireGecko ->
            0

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceElectrical : EnemyType -> Int
damageResistanceElectrical type_ =
    case type_ of
        LesserRadscorpion ->
            15

        Radscorpion ->
            30

        Brahmin ->
            30

        SilverGecko ->
            30

        ToughSilverGecko ->
            30

        GoldenGecko ->
            30

        ToughGoldenGecko ->
            30

        WeakBrahmin ->
            30

        WildBrahmin ->
            30

        FireGecko ->
            50

        ToughFireGecko ->
            50

        LesserBlackRadscorpion ->
            30

        BlackRadscorpion ->
            35

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            30


damageThresholdElectrical : EnemyType -> Int
damageThresholdElectrical type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            0

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            2

        ToughFireGecko ->
            2

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceExplosion : EnemyType -> Int
damageResistanceExplosion type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            20

        Brahmin ->
            10

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            10

        WildBrahmin ->
            20

        FireGecko ->
            40

        ToughFireGecko ->
            40

        LesserBlackRadscorpion ->
            20

        BlackRadscorpion ->
            30

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            20


damageThresholdExplosion : EnemyType -> Int
damageThresholdExplosion type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            6

        ToughFireGecko ->
            6

        LesserBlackRadscorpion ->
            0

        BlackRadscorpion ->
            0

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceFire : EnemyType -> Int
damageResistanceFire type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            10

        Brahmin ->
            20

        SilverGecko ->
            10

        ToughSilverGecko ->
            10

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            20

        WildBrahmin ->
            20

        FireGecko ->
            500

        ToughFireGecko ->
            500

        LesserBlackRadscorpion ->
            10

        BlackRadscorpion ->
            20

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            20


damageThresholdFire : EnemyType -> Int
damageThresholdFire type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            20

        ToughFireGecko ->
            20

        LesserBlackRadscorpion ->
            2

        BlackRadscorpion ->
            3

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistanceLaser : EnemyType -> Int
damageResistanceLaser type_ =
    case type_ of
        LesserRadscorpion ->
            30

        Radscorpion ->
            50

        Brahmin ->
            20

        SilverGecko ->
            20

        ToughSilverGecko ->
            20

        GoldenGecko ->
            20

        ToughGoldenGecko ->
            20

        WeakBrahmin ->
            20

        WildBrahmin ->
            20

        FireGecko ->
            60

        ToughFireGecko ->
            60

        LesserBlackRadscorpion ->
            50

        BlackRadscorpion ->
            60

        GiantAnt ->
            0

        ToughGiantAnt ->
            10

        AngryBrahmin ->
            20


damageThresholdLaser : EnemyType -> Int
damageThresholdLaser type_ =
    case type_ of
        LesserRadscorpion ->
            2

        Radscorpion ->
            4

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            8

        ToughFireGecko ->
            8

        LesserBlackRadscorpion ->
            4

        BlackRadscorpion ->
            5

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


damageResistancePlasma : EnemyType -> Int
damageResistancePlasma type_ =
    case type_ of
        LesserRadscorpion ->
            10

        Radscorpion ->
            10

        Brahmin ->
            10

        SilverGecko ->
            10

        ToughSilverGecko ->
            10

        GoldenGecko ->
            10

        ToughGoldenGecko ->
            10

        WeakBrahmin ->
            10

        WildBrahmin ->
            10

        FireGecko ->
            50

        ToughFireGecko ->
            50

        LesserBlackRadscorpion ->
            10

        BlackRadscorpion ->
            20

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            10


damageThresholdPlasma : EnemyType -> Int
damageThresholdPlasma type_ =
    case type_ of
        LesserRadscorpion ->
            0

        Radscorpion ->
            2

        Brahmin ->
            0

        SilverGecko ->
            0

        ToughSilverGecko ->
            0

        GoldenGecko ->
            0

        ToughGoldenGecko ->
            0

        WeakBrahmin ->
            0

        WildBrahmin ->
            0

        FireGecko ->
            4

        ToughFireGecko ->
            4

        LesserBlackRadscorpion ->
            2

        BlackRadscorpion ->
            3

        GiantAnt ->
            0

        ToughGiantAnt ->
            0

        AngryBrahmin ->
            0


codec : Codec EnemyType
codec =
    Codec.custom
        (\silverGeckoEncoder toughSilverGeckoEncoder goldenGeckoEncoder toughGoldenGeckoEncoder fireGeckoEncoder toughFireGeckoEncoder brahminEncoder angryBrahminEncoder weakBrahminEncoder wildBrahminEncoder giantAntEncoder toughGiantAntEncoder blackRadscorpionEncoder lesserBlackRadscorpionEncoder lesserRadscorpionEncoder radscorpionEncoder value ->
            case value of
                SilverGecko ->
                    silverGeckoEncoder

                ToughSilverGecko ->
                    toughSilverGeckoEncoder

                GoldenGecko ->
                    goldenGeckoEncoder

                ToughGoldenGecko ->
                    toughGoldenGeckoEncoder

                FireGecko ->
                    fireGeckoEncoder

                ToughFireGecko ->
                    toughFireGeckoEncoder

                Brahmin ->
                    brahminEncoder

                AngryBrahmin ->
                    angryBrahminEncoder

                WeakBrahmin ->
                    weakBrahminEncoder

                WildBrahmin ->
                    wildBrahminEncoder

                GiantAnt ->
                    giantAntEncoder

                ToughGiantAnt ->
                    toughGiantAntEncoder

                BlackRadscorpion ->
                    blackRadscorpionEncoder

                LesserBlackRadscorpion ->
                    lesserBlackRadscorpionEncoder

                LesserRadscorpion ->
                    lesserRadscorpionEncoder

                Radscorpion ->
                    radscorpionEncoder
        )
        |> Codec.variant0 "SilverGecko" SilverGecko
        |> Codec.variant0 "ToughSilverGecko" ToughSilverGecko
        |> Codec.variant0 "GoldenGecko" GoldenGecko
        |> Codec.variant0 "ToughGoldenGecko" ToughGoldenGecko
        |> Codec.variant0 "FireGecko" FireGecko
        |> Codec.variant0 "ToughFireGecko" ToughFireGecko
        |> Codec.variant0 "Brahmin" Brahmin
        |> Codec.variant0 "AngryBrahmin" AngryBrahmin
        |> Codec.variant0 "WeakBrahmin" WeakBrahmin
        |> Codec.variant0 "WildBrahmin" WildBrahmin
        |> Codec.variant0 "GiantAnt" GiantAnt
        |> Codec.variant0 "ToughGiantAnt" ToughGiantAnt
        |> Codec.variant0 "BlackRadscorpion" BlackRadscorpion
        |> Codec.variant0 "LesserBlackRadscorpion" LesserBlackRadscorpion
        |> Codec.variant0 "LesserRadscorpion" LesserRadscorpion
        |> Codec.variant0 "Radscorpion" Radscorpion
        |> Codec.buildCustom
