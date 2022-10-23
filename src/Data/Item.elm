module Data.Item exposing
    ( Effect(..)
    , Id
    , Item
    , Kind(..)
    , Type(..)
    , UniqueKey
    , all
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
    , healAmount
    , isEquippable
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
    | CombatArmorMk2
    | PowerArmor
      --
      -- TODO knives? crowbar? etc
    | Supersledge
    | PowerFist
    | MegaPowerFist
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


isHealing : Kind -> Bool
isHealing kind =
    (healAmount kind /= 0)
        && List.member Heal (usageEffects kind)


type Effect
    = Heal
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

        _ ->
            0


healAmount : Kind -> Int
healAmount kind =
    case kind of
        Fruit ->
            15

        HealingPowder ->
            30

        MeatJerky ->
            40

        Stimpak ->
            80

        _ ->
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

        _ ->
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

        _ ->
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
            [ Heal
            , RemoveAfterUse
            ]

        HealingPowder ->
            -- TODO temporary perception -1?
            [ Heal
            , RemoveAfterUse
            ]

        MeatJerky ->
            [ Heal
            , RemoveAfterUse
            ]

        Stimpak ->
            [ Heal
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


type Type
    = Food
    | Armor
    | SmallGun
    | Book
    | Misc
    | Ammo


isEquippableType : Type -> Bool
isEquippableType type__ =
    case type__ of
        Food ->
            False

        Armor ->
            True

        SmallGun ->
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


isEquippable : Kind -> Bool
isEquippable kind =
    isEquippableType (type_ kind)


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

        SmallGun ->
            "Small Gun"

        Ammo ->
            "Ammo"
