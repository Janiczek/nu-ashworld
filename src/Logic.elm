module Logic exposing
    ( AttackStats
    , ItemNotUsableReason(..)
    , UsedAmmo(..)
    , actionPoints
    , addedSkillPercentages
    , armorClass
    , attackApCost
    , attackStats
    , attackStyleAndApCost
    , baseCriticalChance
    , bestCombatSkill
    , bookAddedSkillPercentage
    , bookUseTickCost
    , canUseItem
    , carBatteryPromileCostPerTile
    , chanceToHit
    , damageResistance
    , damageThreshold
    , healAmountGenerator
    , healAmountGenerator_
    , healApCost
    , healOverTimePerTick
    , hitpoints
    , knockOutTurns
    , mainWorldName
    , maxPossibleMove
    , maxTraits
    , naturalArmorClass
    , newCharAvailableSpecialPoints
    , newCharMaxTaggedSkills
    , newCharSpecial
    , passesPlayerRequirement
    , perkRate
    , playerCombatCapsGained
    , playerCombatXpGained
    , price
    , questTicksPerHour
    , regainConciousnessApCost
    , sequence
    , skillPointCost
    , skillPointsPerLevel
    , standUpApCost
    , tickHealPercentage
    , totalTags
    , unaimedAttackStyle
    , unarmedApCost
    , unarmedRange
    , usedAmmo
    , weaponDamageType
    , weaponRange
    , xpGained
    )

import Data.Enemy.Type as EnemyType
import Data.Fight.AimedShot as AimedShot exposing (AimedShot(..))
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Fight.DamageType as DamageType exposing (DamageType)
import Data.Fight.OpponentType exposing (OpponentType(..))
import Data.Item as Item exposing (Item)
import Data.Item.Effect as ItemEffect
import Data.Item.Kind as ItemKind
import Data.Item.Type as ItemType
import Data.Perk as Perk exposing (Perk(..))
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp exposing (BaseXp(..))
import Dict exposing (Dict)
import Dict.Extra as Dict
import List.Extra
import Random exposing (Generator)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


carBatteryPromileCostPerTile : Int
carBatteryPromileCostPerTile =
    5


unarmedApCost : Int
unarmedApCost =
    3


attackApCost :
    { isAimedShot : Bool
    , hasBonusHthAttacksPerk : Bool
    , hasBonusRateOfFirePerk : Bool
    , attackStyle : AttackStyle
    , baseApCost : Int
    }
    -> Int
attackApCost r =
    let
        withBonusHth : Int
        withBonusHth =
            if r.hasBonusHthAttacksPerk then
                -1

            else
                0

        withBonusRateOfFire : Int
        withBonusRateOfFire =
            if r.hasBonusRateOfFirePerk then
                -1

            else
                0

        perkBonus : Int
        perkBonus =
            case r.attackStyle of
                UnarmedUnaimed ->
                    withBonusHth

                UnarmedAimed _ ->
                    withBonusHth

                MeleeUnaimed ->
                    withBonusHth

                MeleeAimed _ ->
                    withBonusHth

                Throw ->
                    0

                ShootSingleUnaimed ->
                    withBonusRateOfFire

                ShootSingleAimed _ ->
                    withBonusRateOfFire

                ShootBurst ->
                    withBonusRateOfFire

        apCostPenalty : Int
        apCostPenalty =
            if r.isAimedShot then
                aimedShotApCostPenalty

            else
                0
    in
    r.baseApCost
        + apCostPenalty
        + perkBonus


healApCost : Int
healApCost =
    2


standUpApCost : { hasQuickRecoveryPerk : Bool } -> Int
standUpApCost r =
    if r.hasQuickRecoveryPerk then
        1

    else
        4


knockOutTurns : Int
knockOutTurns =
    2


regainConciousnessApCost : { maxAp : Int } -> Int
regainConciousnessApCost r =
    r.maxAp // 2


hitpoints :
    { level : Int
    , special : Special
    , lifegiverPerkRanks : Int
    }
    -> Int
hitpoints r =
    let
        { strength, endurance } =
            r.special
    in
    15
        + (2 * endurance)
        + strength
        + (r.level * (2 + endurance // 2))
        + (r.level * r.lifegiverPerkRanks * 4)


tickHealPercentage :
    { special : Special
    , addedSkillPercentages : SeqDict Skill Int
    , fasterHealingPerkRanks : Int
    }
    -> Int
tickHealPercentage r =
    let
        pctFloor =
            50

        pctFromEndurance =
            r.special.endurance * 2

        pctFromFasterHealingPerk =
            10 * r.fasterHealingPerkRanks

        doctor =
            Skill.get r.special r.addedSkillPercentages Skill.Doctor

        -- pctMinimum = 52
        -- pctRest = 48
        -- Doctor 0% -> 0
        -- Doctor 100% -> 48
        -- Doctor 1% -> 48/100
        pctFromDoctor =
            doctor * 48 // 100
    in
    (pctFloor
        + pctFromEndurance
        + pctFromFasterHealingPerk
        + pctFromDoctor
    )
        |> min 100


healOverTimePerTick :
    { special : Special
    , addedSkillPercentages : SeqDict Skill Int
    , fasterHealingPerkRanks : Int
    }
    -> Int
healOverTimePerTick r =
    let
        base =
            4

        firstAid =
            Skill.get r.special r.addedSkillPercentages Skill.FirstAid

        fromFirstAid =
            -- 1 HP every 20% of First Aid
            firstAid // 20

        fasterHealingBonusPct =
            r.fasterHealingPerkRanks * 10
    in
    (base + fromFirstAid)
        |> toFloat
        |> (\hp -> hp * (1 + toFloat fasterHealingBonusPct / 100))
        |> round


naturalArmorClass :
    { special : Special
    , hasKamikazeTrait : Bool
    , hasDodgerPerk : Bool
    }
    -> Int
naturalArmorClass r =
    let
        natural =
            if r.hasKamikazeTrait then
                0

            else
                r.special.agility

        fromDodger =
            if r.hasDodgerPerk then
                5

            else
                0
    in
    natural + fromDodger


armorClass :
    { naturalArmorClass : Int
    , equippedArmor : Maybe ItemKind.Kind
    , equippedWeapon : Maybe ItemKind.Kind
    , hasHthEvadePerk : Bool
    , unarmedSkill : Int
    , apFromPreviousTurn : Int
    }
    -> Int
armorClass r =
    let
        hthEvadeBonusesApply : Bool
        hthEvadeBonusesApply =
            r.hasHthEvadePerk && r.equippedWeapon == Nothing

        fromArmor =
            r.equippedArmor
                |> Maybe.map ItemKind.armorClass
                |> Maybe.withDefault 0

        unusedApMultiplier =
            if hthEvadeBonusesApply then
                2

            else
                1

        fromUnusedAp =
            r.apFromPreviousTurn * unusedApMultiplier

        fromUnarmedSkill =
            if hthEvadeBonusesApply then
                r.unarmedSkill // 12

            else
                0
    in
    r.naturalArmorClass
        + fromArmor
        + fromUnusedAp
        + fromUnarmedSkill


aimedShotApCostPenalty : Int
aimedShotApCostPenalty =
    1


aimedShotCriticalChanceBonus : AimedShot -> Int
aimedShotCriticalChanceBonus aimedShot =
    aimedShotChanceToHitPenalty aimedShot


aimedShotChanceToHitPenalty : AimedShot -> Int
aimedShotChanceToHitPenalty aimedShot =
    case aimedShot of
        Head ->
            40

        Torso ->
            0

        Eyes ->
            60

        Groin ->
            30

        LeftArm ->
            30

        RightArm ->
            30

        LeftLeg ->
            20

        RightLeg ->
            20


actionPoints :
    { special : Special
    , hasBruiserTrait : Bool
    , actionBoyPerkRanks : Int
    }
    -> Int
actionPoints r =
    let
        bruiserPenalty =
            if r.hasBruiserTrait then
                2

            else
                0

        actionBoyBonus =
            r.actionBoyPerkRanks
    in
    (5 + r.special.agility // 2)
        - bruiserPenalty
        + actionBoyBonus


distancePenalty :
    { distanceHexes : Int
    , equippedWeapon : Maybe ItemKind.Kind
    , perception : Int
    , hasSharpshooterPerk : Bool
    }
    -> Int
distancePenalty r =
    let
        default () =
            (r.distanceHexes - 1) * 4
    in
    case r.equippedWeapon of
        Nothing ->
            default ()

        Just equippedWeapon ->
            if ItemKind.isLongRangeWeapon equippedWeapon then
                let
                    sharpshooterBonus =
                        if r.hasSharpshooterPerk then
                            2

                        else
                            0

                    effectivePerception =
                        r.perception + sharpshooterBonus
                in
                if effectivePerception >= 5 && r.distanceHexes < ((effectivePerception - 4) * 2) then
                    effectivePerception * 8

                else
                    (effectivePerception - 2) * 16 - r.distanceHexes * 4

            else
                default ()


lightingPenalty :
    { isItDark : Bool
    , hasNightVisionPerk : Bool
    , distanceHexes : Int
    }
    -> Int
lightingPenalty r =
    if r.isItDark then
        let
            base : Int
            base =
                if r.distanceHexes <= 1 then
                    0

                else if r.distanceHexes == 2 then
                    10

                else if r.distanceHexes == 3 then
                    25

                else
                    -- 4+
                    40

            nightVisionBonus : Int
            nightVisionBonus =
                if r.hasNightVisionPerk then
                    20

                else
                    0
        in
        max 0 (base - nightVisionBonus)

    else
        0


chanceToHit :
    { attackerAddedSkillPercentages : SeqDict Skill Int
    , attackerPerks : SeqDict Perk Int
    , attackerTraits : SeqSet Trait
    , attackerSpecial : Special
    , crippledArms : Int
    , distanceHexes : Int
    , equippedWeapon : Maybe ItemKind.Kind
    , usedAmmo : UsedAmmo
    , targetArmorClass : Int
    , attackStyle : AttackStyle
    }
    -> Int
chanceToHit r =
    case r.attackStyle of
        UnarmedUnaimed ->
            meleeChanceToHit r

        UnarmedAimed _ ->
            meleeChanceToHit r

        MeleeUnaimed ->
            meleeChanceToHit r

        MeleeAimed _ ->
            meleeChanceToHit r

        Throw ->
            rangedChanceToHit r

        ShootSingleUnaimed ->
            rangedChanceToHit r

        ShootSingleAimed _ ->
            rangedChanceToHit r

        ShootBurst ->
            rangedChanceToHit r


neededSkill : AttackStyle -> List ItemType.Type -> Maybe Skill
neededSkill attackStyle itemTypes =
    case attackStyle of
        UnarmedUnaimed ->
            -- This is a special one: when not equipping any weapon (-> itemTypes = []), we still want to allow an unarmed attack.
            Just Skill.Unarmed

        UnarmedAimed _ ->
            -- This is a special one: when not equipping any weapon (-> itemTypes = []), we still want to allow an unarmed attack.
            Just Skill.Unarmed

        MeleeUnaimed ->
            if List.member ItemType.MeleeWeapon itemTypes then
                Just Skill.MeleeWeapons

            else
                Nothing

        MeleeAimed _ ->
            if List.member ItemType.MeleeWeapon itemTypes then
                Just Skill.MeleeWeapons

            else
                Nothing

        Throw ->
            if List.member ItemType.ThrownWeapon itemTypes then
                Just Skill.Throwing

            else
                Nothing

        ShootSingleUnaimed ->
            if List.member ItemType.SmallGun itemTypes then
                Just Skill.SmallGuns

            else if List.member ItemType.BigGun itemTypes then
                Just Skill.BigGuns

            else if List.member ItemType.EnergyWeapon itemTypes then
                Just Skill.EnergyWeapons

            else
                Nothing

        ShootSingleAimed _ ->
            if List.member ItemType.SmallGun itemTypes then
                Just Skill.SmallGuns

            else if List.member ItemType.BigGun itemTypes then
                Just Skill.BigGuns

            else if List.member ItemType.EnergyWeapon itemTypes then
                Just Skill.EnergyWeapons

            else
                Nothing

        ShootBurst ->
            if List.member ItemType.SmallGun itemTypes then
                Just Skill.SmallGuns

            else if List.member ItemType.BigGun itemTypes then
                Just Skill.BigGuns

            else if List.member ItemType.EnergyWeapon itemTypes then
                Just Skill.EnergyWeapons

            else
                Nothing


rangedChanceToHit :
    { r
        | attackerAddedSkillPercentages : SeqDict Skill Int
        , attackerSpecial : Special
        , attackerPerks : SeqDict Perk Int
        , attackerTraits : SeqSet Trait
        , crippledArms : Int
        , targetArmorClass : Int
        , distanceHexes : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , usedAmmo : UsedAmmo
        , attackStyle : AttackStyle
    }
    -> Int
rangedChanceToHit r =
    if SeqSet.member Trait.FastShot r.attackerTraits && AttackStyle.isAimed r.attackStyle then
        -- FastShot doesn't work with aimed attacks
        0

    else if r.crippledArms >= 2 then
        -- Cannot use non-unarmed attacks with both arms crippled
        0

    else
        case r.equippedWeapon of
            Nothing ->
                -- Can't have ranged attacks without a weapon
                0

            Just equippedWeapon ->
                if r.crippledArms >= 1 && ItemKind.isTwoHandedWeapon equippedWeapon then
                    -- Can't use two-handed weapon if both hands aren't fine
                    0

                else if r.distanceHexes > ItemKind.range r.attackStyle equippedWeapon then
                    -- Wanted to attack at a range the weapon can't do
                    0

                else
                    let
                        neededSkill_ : Maybe Skill
                        neededSkill_ =
                            neededSkill r.attackStyle (ItemKind.types equippedWeapon)

                        continue : Skill -> Maybe ( Item.Id, ItemKind.Kind, Int ) -> Int
                        continue weaponSkill ammo =
                            let
                                weaponSkill_ : Int
                                weaponSkill_ =
                                    Skill.get r.attackerSpecial r.attackerAddedSkillPercentages weaponSkill

                                distancePenalty_ : Int
                                distancePenalty_ =
                                    -- This already contains the Weapon Long Range perk calculations.
                                    distancePenalty
                                        { distanceHexes = r.distanceHexes
                                        , equippedWeapon = r.equippedWeapon
                                        , perception = r.attackerSpecial.perception
                                        , hasSharpshooterPerk = Perk.rank Perk.Sharpshooter r.attackerPerks > 0
                                        }

                                crippledArmPenalty : Int
                                crippledArmPenalty =
                                    if r.crippledArms >= 1 then
                                        40

                                    else
                                        0

                                ammoArmorClassModifier : Int
                                ammoArmorClassModifier =
                                    ammo
                                        |> Maybe.map (\( _, kind, _ ) -> ItemKind.ammoArmorClassModifier kind)
                                        |> Maybe.withDefault 0

                                oneHanderFor : ItemKind.Kind -> Int
                                oneHanderFor weapon =
                                    if ItemKind.isTwoHandedWeapon weapon then
                                        -40

                                    else
                                        20

                                oneHanderBonus : Int
                                oneHanderBonus =
                                    if SeqSet.member Trait.OneHander r.attackerTraits then
                                        case ( r.attackStyle, r.equippedWeapon ) of
                                            ( Throw, Nothing ) ->
                                                0

                                            ( Throw, Just weapon ) ->
                                                oneHanderFor weapon

                                            ( ShootSingleUnaimed, Nothing ) ->
                                                0

                                            ( ShootSingleUnaimed, Just weapon ) ->
                                                oneHanderFor weapon

                                            ( ShootSingleAimed _, Nothing ) ->
                                                0

                                            ( ShootSingleAimed _, Just weapon ) ->
                                                oneHanderFor weapon

                                            ( ShootBurst, Nothing ) ->
                                                0

                                            ( ShootBurst, Just weapon ) ->
                                                oneHanderFor weapon

                                            -- We don't care about these here:
                                            ( UnarmedUnaimed, _ ) ->
                                                0

                                            ( UnarmedAimed _, _ ) ->
                                                0

                                            ( MeleeUnaimed, _ ) ->
                                                0

                                            ( MeleeAimed _, _ ) ->
                                                0

                                    else
                                        0

                                lightingPenalty_ : Int
                                lightingPenalty_ =
                                    lightingPenalty
                                        { isItDark = False
                                        , hasNightVisionPerk = Perk.rank Perk.NightVision r.attackerPerks > 0
                                        , distanceHexes = r.distanceHexes
                                        }

                                shotPenalty : Int
                                shotPenalty =
                                    case r.attackStyle of
                                        Throw ->
                                            0

                                        ShootSingleUnaimed ->
                                            0

                                        ShootSingleAimed aim ->
                                            aimedShotChanceToHitPenalty aim

                                        ShootBurst ->
                                            burstShotChanceToHitPenalty

                                        -- These can't happen in ranged:
                                        UnarmedUnaimed ->
                                            0

                                        UnarmedAimed _ ->
                                            0

                                        MeleeUnaimed ->
                                            0

                                        MeleeAimed _ ->
                                            0

                                strengthRequirementPenalty : Int
                                strengthRequirementPenalty =
                                    strengthRequirementChanceToHitPenalty
                                        { strength = r.attackerSpecial.strength
                                        , equippedWeapon = equippedWeapon
                                        }

                                weaponAccuratePerk : Int
                                weaponAccuratePerk =
                                    if ItemKind.isAccurateWeapon equippedWeapon then
                                        20

                                    else
                                        0

                                chanceToHitAtLeastOnce : Int
                                chanceToHitAtLeastOnce =
                                    (weaponSkill_
                                        + (8 * r.attackerSpecial.perception)
                                        -- weapon long range perk is already factored into the distancePenalty
                                        + weaponAccuratePerk
                                        + oneHanderBonus
                                        - distancePenalty_
                                        - ((r.targetArmorClass * (100 + ammoArmorClassModifier)) // 100)
                                        - lightingPenalty_
                                        - strengthRequirementPenalty
                                        - shotPenalty
                                        - crippledArmPenalty
                                    )
                                        |> clamp 0 95
                            in
                            if r.attackStyle == ShootBurst then
                                case ammo of
                                    Just _ ->
                                        let
                                            { chanceToHitEach } =
                                                adjustChanceToHitForBurst
                                                    { chanceToHitAtLeastOnce = chanceToHitAtLeastOnce
                                                    , ammoUsedInBurst =
                                                        -- This is used for the recoil of the gun, we don't really care that
                                                        -- the player only has eg. 9 ammo left while Bozar would like to use 15.
                                                        -- From the ideal 15 shots, we'd hit X%, and so it stands to reason
                                                        -- that we'd have the same chance to hit each bullet with fewer bullets used.
                                                        ItemKind.shotsPerBurst equippedWeapon
                                                    }
                                        in
                                        chanceToHitEach

                                    Nothing ->
                                        -- Probably shouldn't happen. Burst with a weapon that doesn't use ammo.
                                        0

                            else
                                chanceToHitAtLeastOnce
                    in
                    case ( neededSkill_, r.usedAmmo ) of
                        ( Nothing, _ ) ->
                            -- Wanted to attack in an `attackStyle` the weapon can't do
                            0

                        ( _, NoUsableAmmo ) ->
                            -- Weapon without ammo. Fallback to the unarmed attack.
                            meleeChanceToHit
                                { r
                                    | equippedWeapon = Nothing
                                    , attackStyle = UnarmedUnaimed
                                    , usedAmmo = NoAmmoNeeded
                                }

                        ( Just weaponSkill, NoAmmoNeeded ) ->
                            continue weaponSkill Nothing

                        ( Just weaponSkill, PreferredAmmo ammo ) ->
                            continue weaponSkill (Just ammo)

                        ( Just weaponSkill, FallbackAmmo ammo ) ->
                            continue weaponSkill (Just ammo)


{-| Burst chance to hit is "chance to hit at least once". But what chanceToHit
and by extension rangedChanceToHit is supposed to return, is "chance to hit this
bullet". So we need to compute the probability of the latter from the former, to
later give to Data.Fight.Generator for its rolls. As a rough guideline, each
bullet will have a lower chance to hit than the total "chance to hit at least
once".

chanceToHitEach = 1 - (1 - chanceToHitAtLeastOnce)^(1/N)

Example:

  - chance to hit at least once = 95%
  - ammo used in this burst = 15 (Bozar)
  - chance to hit each bullet = 1 - (1 - 0.95)^(1/15) = 0.181 = 18%

We can check this in the other direction with any binomial distribution calculator,
eg. <https://homepage.divms.uiowa.edu/~mbognar/applets/bin.html>

X ~ Bin(n,p)
n = 15
p = 0.181
x = 1
P(X >= x) = 0.94997 (because we rounded p to 0.181)

-}
adjustChanceToHitForBurst :
    { chanceToHitAtLeastOnce : Int
    , ammoUsedInBurst : Int
    }
    -> { chanceToHitEach : Int }
adjustChanceToHitForBurst { ammoUsedInBurst, chanceToHitAtLeastOnce } =
    let
        chanceToHitAtLeastOnce_ =
            toFloat chanceToHitAtLeastOnce / 100

        chanceToHitEach_ =
            -- The meat of the calculation
            1 - (1 - chanceToHitAtLeastOnce_) ^ (1.0 / toFloat ammoUsedInBurst)

        chanceToHitEach =
            round (chanceToHitEach_ * 100)
                |> clamp 0 95
    in
    { chanceToHitEach = chanceToHitEach }


weaponRange : Maybe ItemKind.Kind -> AttackStyle -> Int
weaponRange equippedWeapon attackStyle =
    case equippedWeapon of
        Nothing ->
            -- Nothing equipped, means this is an unarmed attack
            1

        Just weapon ->
            ItemKind.range attackStyle weapon


meleeChanceToHit :
    { r
        | attackerAddedSkillPercentages : SeqDict Skill Int
        , attackerSpecial : Special
        , attackerTraits : SeqSet Trait
        , distanceHexes : Int
        , crippledArms : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , usedAmmo : UsedAmmo
        , targetArmorClass : Int
        , attackStyle : AttackStyle
    }
    -> Int
meleeChanceToHit r =
    if SeqSet.member Trait.FastShot r.attackerTraits && AttackStyle.isAimed r.attackStyle then
        -- FastShot doesn't work with aimed attacks
        0

    else if r.distanceHexes > weaponRange r.equippedWeapon r.attackStyle then
        -- Wanted to attack at a range the weapon can't do
        0

    else if r.crippledArms >= 2 && not (AttackStyle.isUnarmed r.attackStyle) then
        -- Can't use non-unarmed attacks with both arms crippled
        0

    else if r.crippledArms >= 1 && Maybe.map ItemKind.isTwoHandedWeapon r.equippedWeapon == Just True then
        -- Can't use two-handed weapon if both hands aren't fine
        0

    else
        let
            neededSkill_ =
                neededSkill r.attackStyle
                    (r.equippedWeapon
                        |> Maybe.map ItemKind.types
                        |> Maybe.withDefault []
                    )

            continue : Skill -> Int
            continue weaponSkill =
                let
                    skillPercentage : Int
                    skillPercentage =
                        Skill.get r.attackerSpecial r.attackerAddedSkillPercentages weaponSkill

                    shotPenalty : Int
                    shotPenalty =
                        case r.attackStyle of
                            UnarmedUnaimed ->
                                0

                            UnarmedAimed aim ->
                                aimedShotChanceToHitPenalty aim

                            MeleeUnaimed ->
                                0

                            MeleeAimed aim ->
                                aimedShotChanceToHitPenalty aim

                            -- These can't happen in unarmed/melee:
                            Throw ->
                                0

                            ShootSingleUnaimed ->
                                0

                            ShootSingleAimed _ ->
                                0

                            ShootBurst ->
                                0

                    oneHanderFor : ItemKind.Kind -> Int
                    oneHanderFor weapon =
                        if ItemKind.isTwoHandedWeapon weapon then
                            -40

                        else
                            20

                    oneHanderBonus : Int
                    oneHanderBonus =
                        if SeqSet.member Trait.OneHander r.attackerTraits then
                            case ( r.attackStyle, r.equippedWeapon ) of
                                ( UnarmedUnaimed, _ ) ->
                                    0

                                ( UnarmedAimed _, _ ) ->
                                    0

                                ( MeleeUnaimed, Nothing ) ->
                                    0

                                ( MeleeUnaimed, Just weapon ) ->
                                    oneHanderFor weapon

                                ( MeleeAimed _, Nothing ) ->
                                    0

                                ( MeleeAimed _, Just weapon ) ->
                                    oneHanderFor weapon

                                -- We don't care about these here:
                                ( Throw, _ ) ->
                                    0

                                ( ShootSingleUnaimed, _ ) ->
                                    0

                                ( ShootSingleAimed _, _ ) ->
                                    0

                                ( ShootBurst, _ ) ->
                                    0

                        else
                            0

                    crippledArmPenalty : Int
                    crippledArmPenalty =
                        if r.crippledArms >= 1 then
                            40

                        else
                            0

                    weaponAccuratePerk : Int
                    weaponAccuratePerk =
                        case r.equippedWeapon of
                            Nothing ->
                                0

                            Just equippedWeapon ->
                                if ItemKind.isAccurateWeapon equippedWeapon then
                                    20

                                else
                                    0
                in
                (skillPercentage
                    + weaponAccuratePerk
                    + oneHanderBonus
                    - r.targetArmorClass
                    - shotPenalty
                    - crippledArmPenalty
                )
                    |> clamp 0 95
        in
        case ( neededSkill_, r.usedAmmo ) of
            ( Nothing, _ ) ->
                -- Wanted to attack in an `attackStyle` the weapon can't do
                0

            ( _, NoUsableAmmo ) ->
                -- eg. Power Fist without power
                -- Go for the fallback unarmed attack
                meleeChanceToHit
                    { r
                        | equippedWeapon = Nothing
                        , attackStyle = UnarmedUnaimed
                        , usedAmmo = NoAmmoNeeded
                    }

            ( Just weaponSkill, NoAmmoNeeded ) ->
                continue weaponSkill

            ( Just weaponSkill, FallbackAmmo _ ) ->
                continue weaponSkill

            ( Just weaponSkill, PreferredAmmo _ ) ->
                continue weaponSkill


sequence :
    { perception : Int
    , hasKamikazeTrait : Bool
    , earlierSequencePerkRank : Int
    }
    -> Int
sequence { perception, hasKamikazeTrait, earlierSequencePerkRank } =
    let
        base =
            2 * perception

        kamikazeBonus =
            if hasKamikazeTrait then
                5

            else
                0

        earlierSequenceBonus =
            earlierSequencePerkRank * 2
    in
    base
        + kamikazeBonus
        + earlierSequenceBonus


xpPerHpMultiplier : Int
xpPerHpMultiplier =
    10


playerCombatXpGained :
    { damageDealt : Int
    , winnerLevel : Int
    , loserLevel : Int
    }
    -> BaseXp
playerCombatXpGained { damageDealt, winnerLevel, loserLevel } =
    let
        raw =
            damageDealt * xpPerHpMultiplier

        multiplier =
            toFloat loserLevel / toFloat winnerLevel
    in
    BaseXp <| round <| toFloat raw * multiplier


playerCombatCapsGained :
    { damageDealt : Int
    , loserCaps : Int
    , loserMaxHp : Int
    }
    -> Int
playerCombatCapsGained { damageDealt, loserCaps, loserMaxHp } =
    let
        multiplier =
            0.5 + 0.5 * toFloat damageDealt / toFloat loserMaxHp
    in
    round <| toFloat loserCaps * multiplier


xpGained :
    { baseXpGained : BaseXp
    , swiftLearnerPerkRanks : Int
    }
    -> Int
xpGained r =
    let
        (BaseXp xp) =
            r.baseXpGained
    in
    round <| toFloat xp * (1 + 0.05 * toFloat r.swiftLearnerPerkRanks)


type alias AttackStats =
    { minDamage : Int
    , maxDamage : Int
    , criticalChanceBonus : Int
    }


attackStats :
    { special : Special
    , addedSkillPercentages : SeqDict Skill Int
    , traits : SeqSet Trait
    , perks : SeqDict Perk Int
    , level : Int
    , equippedWeapon : Maybe ItemKind.Kind
    , preferredAmmo : Maybe ItemKind.Kind
    , crippledArms : Int
    , items : Dict Item.Id Item
    , unarmedDamageBonus : Int
    , attackStyle : AttackStyle
    }
    -> AttackStats
attackStats r =
    -- TODO test: attack with knife = melee, should be getting HeavyHanded perk bonuses, but not unarmedDamageBonus
    -- TODO test: fallback unarmed attack should be getting HeavyHanded perk bonuses and the rest as if there was no equippedWeapon
    let
        default () =
            case r.equippedWeapon of
                Nothing ->
                    meleeAttackStats r

                Just equippedWeapon ->
                    case r.attackStyle of
                        UnarmedUnaimed ->
                            meleeAttackStats r

                        UnarmedAimed _ ->
                            meleeAttackStats r

                        MeleeUnaimed ->
                            meleeAttackStats r

                        MeleeAimed _ ->
                            meleeAttackStats r

                        Throw ->
                            rangedAttackStats equippedWeapon r

                        ShootSingleUnaimed ->
                            rangedAttackStats equippedWeapon r

                        ShootSingleAimed _ ->
                            rangedAttackStats equippedWeapon r

                        ShootBurst ->
                            rangedAttackStats equippedWeapon r
    in
    case usedAmmo r of
        PreferredAmmo _ ->
            default ()

        FallbackAmmo _ ->
            default ()

        NoUsableAmmo ->
            meleeAttackStats { r | equippedWeapon = Nothing }

        NoAmmoNeeded ->
            default ()


rangedAttackStats :
    ItemKind.Kind
    ->
        { r
            | special : Special
            , addedSkillPercentages : SeqDict Skill Int
            , traits : SeqSet Trait
            , perks : SeqDict Perk Int
            , level : Int
            , items : Dict Item.Id Item
        }
    -> AttackStats
rangedAttackStats equippedWeapon r =
    let
        weapon : { min : Int, max : Int }
        weapon =
            ItemKind.weaponDamage equippedWeapon

        bonusRangedDamagePerkRank : Int
        bonusRangedDamagePerkRank =
            Perk.rank Perk.BonusRangedDamage r.perks

        rangedDamagePerkBonus : Int
        rangedDamagePerkBonus =
            2 * bonusRangedDamagePerkRank
    in
    -- TODO Pyromaniac - +5 damage if weapon damage type is Fire
    { minDamage = weapon.min + rangedDamagePerkBonus
    , maxDamage = weapon.max + rangedDamagePerkBonus
    , criticalChanceBonus = 0
    }


meleeAttackStats :
    { r
        | special : Special
        , addedSkillPercentages : SeqDict Skill Int
        , traits : SeqSet Trait
        , perks : SeqDict Perk Int
        , level : Int
        , crippledArms : Int
        , unarmedDamageBonus : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , attackStyle : AttackStyle

        -- We don't care about ammo here in AttackStats, that's all gonna happen
        -- in the final damage calculation in Data.Fight.Generator
    }
    -> AttackStats
meleeAttackStats r =
    let
        { strength, agility } =
            r.special

        heavyHandedTraitBonus : Int
        heavyHandedTraitBonus =
            if Trait.isSelected Trait.HeavyHanded r.traits then
                4

            else
                0

        hthDamagePerkBonus : Int
        hthDamagePerkBonus =
            2 * Perk.rank Perk.BonusHthDamage r.perks

        bonusMeleeDamage : Int
        bonusMeleeDamage =
            max 1 (strength - 5) + heavyHandedTraitBonus + hthDamagePerkBonus

        unarmedSkill : Int
        unarmedSkill =
            Skill.get r.special r.addedSkillPercentages Skill.Unarmed

        isUnarmedAttack : Bool
        isUnarmedAttack =
            AttackStyle.isUnarmed r.attackStyle

        {- "Named" unarmed attacks.
           https://fallout.fandom.com/wiki/Unarmed_(Fallout)#Fallout_2_and_Fallout_Tactics_2

           We're using the primary punches, that way we don't need to worry about different AP costs.
           That also means these are never armor piercing.

        -}
        { unarmedAttackBonus, criticalChanceBonus } =
            if r.crippledArms >= 1 then
                { unarmedAttackBonus = -4
                , criticalChanceBonus = 0
                }

            else if unarmedSkill < 55 || agility < 6 || r.equippedWeapon /= Nothing || not isUnarmedAttack then
                { unarmedAttackBonus = 0
                , criticalChanceBonus = 0
                }

            else if unarmedSkill < 75 || strength < 5 || r.level < 6 then
                { unarmedAttackBonus = 3
                , criticalChanceBonus = 0
                }

            else if unarmedSkill < 100 || agility < 7 || r.level < 9 then
                { unarmedAttackBonus = 5
                , criticalChanceBonus = 5
                }

            else
                { unarmedAttackBonus = 7
                , criticalChanceBonus = 15
                }

        ( minDamage, maxDamage ) =
            case r.equippedWeapon of
                Nothing ->
                    ( max 0 <| 1 + unarmedAttackBonus
                    , max 0 <| 1 + unarmedAttackBonus + bonusMeleeDamage + r.unarmedDamageBonus
                    )

                Just equippedWeapon ->
                    let
                        weaponDmg =
                            ItemKind.weaponDamage equippedWeapon
                    in
                    ( weaponDmg.min, weaponDmg.max + bonusMeleeDamage )
    in
    { minDamage = minDamage
    , maxDamage = maxDamage
    , criticalChanceBonus = criticalChanceBonus
    }


baseCriticalChance :
    { special : Special
    , traits : SeqSet Trait
    , perks : SeqDict Perk Int
    , attackStyle : AttackStyle
    , chanceToHit : Int
    , hitOrMissRoll : Int
    }
    -> Int
baseCriticalChance r =
    let
        fromChanceToHit : Int
        fromChanceToHit =
            max 0 ((r.chanceToHit - r.hitOrMissRoll) // 10)

        fromSpecial : Int
        fromSpecial =
            r.special.luck

        fromFinesse : Int
        fromFinesse =
            if SeqSet.member Trait.Finesse r.traits then
                10

            else
                0

        fromMoreCriticals : Int
        fromMoreCriticals =
            5 * Perk.rank Perk.MoreCriticals r.perks

        fromSlayer : Int
        fromSlayer =
            if Perk.rank Perk.Slayer r.perks > 0 then
                100

            else
                0

        fromSniper : Int
        fromSniper =
            if Perk.rank Perk.Sniper r.perks > 0 then
                -- instead of fromSpecial 1% per Luck point, we get 10% per Luck point.
                r.special.luck * 9

            else
                0

        fromAimedShot : AimedShot -> Int
        fromAimedShot aim =
            aimedShotCriticalChanceBonus aim

        unaimed : Int -> Int
        unaimed fromEndgamePerk =
            (fromChanceToHit
                + fromSpecial
                + fromFinesse
                + fromMoreCriticals
                + fromEndgamePerk
            )
                |> min 95

        aimed : AimedShot -> Int -> Int
        aimed aim fromEndgamePerk =
            (fromChanceToHit
                + fromSpecial
                + fromFinesse
                + fromMoreCriticals
                + fromAimedShot aim
                + fromEndgamePerk
            )
                |> min 95
    in
    case r.attackStyle of
        -- Slayer's 100% wins over the rest
        UnarmedUnaimed ->
            max fromSlayer (unaimed 0)

        UnarmedAimed aim ->
            max fromSlayer (aimed aim 0)

        MeleeUnaimed ->
            max fromSlayer (unaimed 0)

        MeleeAimed aim ->
            max fromSlayer (aimed aim 0)

        -- Sniper is capped to 95%
        Throw ->
            unaimed fromSniper

        ShootSingleUnaimed ->
            unaimed fromSniper

        ShootSingleAimed aim ->
            aimed aim fromSniper

        ShootBurst ->
            unaimed fromSniper


price :
    { baseValue : Int
    , playerBarterSkill : Int
    , traderBarterSkill : Int
    , hasMasterTraderPerk : Bool
    , discountPct : Int
    }
    -> Int
price r =
    --  https://www.nma-fallout.com/threads/fallout-and-fallout-2-barter-formula.217810/#post-4329046
    let
        masterTraderDiscount : Int
        masterTraderDiscount =
            if r.hasMasterTraderPerk then
                25

            else
                0

        barterPercent : Int
        barterPercent =
            max 1 (100 - masterTraderDiscount - r.discountPct)

        barterRatio : Float
        barterRatio =
            (toFloat r.traderBarterSkill + 160) / (toFloat r.playerBarterSkill + 160) * 2
    in
    round (toFloat r.baseValue * barterRatio * (toFloat barterPercent * 0.01))


{-| Cost of increasing a skill 1% (or 2% if tagged)
-}
skillPointCost : Int -> Int
skillPointCost skillPercentage =
    if skillPercentage <= 100 then
        1

    else if skillPercentage <= 125 then
        2

    else if skillPercentage <= 150 then
        3

    else if skillPercentage <= 175 then
        4

    else if skillPercentage <= 200 then
        5

    else
        -- if skillPercentage <= 300 then
        6


totalTags : { hasTagPerk : Bool } -> Int
totalTags { hasTagPerk } =
    if hasTagPerk then
        4

    else
        3


skillPointsPerLevel :
    { hasGiftedTrait : Bool
    , hasSkilledTrait : Bool
    , educatedPerkRanks : Int
    , intelligence : Int
    }
    -> Int
skillPointsPerLevel r =
    let
        giftedPenalty : Int
        giftedPenalty =
            if r.hasGiftedTrait then
                5

            else
                0

        skilledBonus : Int
        skilledBonus =
            if r.hasSkilledTrait then
                5

            else
                0

        educatedBonus : Int
        educatedBonus =
            r.educatedPerkRanks * 2
    in
    (5 + 2 * r.intelligence)
        - giftedPenalty
        + skilledBonus
        + educatedBonus


addedSkillPercentages :
    { taggedSkills : SeqSet Skill
    , hasGiftedTrait : Bool
    }
    -> SeqDict Skill Int
addedSkillPercentages { taggedSkills, hasGiftedTrait } =
    let
        taggedSkillBonuses =
            taggedSkills
                |> SeqSet.toList
                {- Each tag adds 20% at the beginning. This doesn't happen
                   later when adding a tag via the Tag! perk.
                -}
                |> List.map (\skill -> ( skill, 20 ))
                |> SeqDict.fromList

        giftedTraitPenalties =
            if hasGiftedTrait then
                Skill.all
                    |> List.map (\skill -> ( skill, -10 ))
                    |> SeqDict.fromList

            else
                SeqDict.empty
    in
    [ taggedSkillBonuses
    , giftedTraitPenalties
    ]
        |> List.foldl
            (\bonusesDict accSkills ->
                bonusesDict
                    |> SeqDict.foldl
                        (\bonusSkill bonus accSkills_ ->
                            accSkills_
                                |> SeqDict.update bonusSkill
                                    (\maybeSkillPercentage ->
                                        case maybeSkillPercentage of
                                            Nothing ->
                                                Just bonus

                                            Just skillPercentage ->
                                                Just <| skillPercentage + bonus
                                    )
                        )
                        accSkills
            )
            SeqDict.empty


newCharSpecial :
    { -- doesn't contain bonunses from traits, perks, armor, drugs, etc.
      baseSpecial : Special
    , hasBruiserTrait : Bool
    , hasGiftedTrait : Bool
    , hasSmallFrameTrait : Bool
    }
    -> Special
newCharSpecial r =
    let
        strengthBonus =
            if r.hasBruiserTrait then
                2

            else
                0

        allBonus =
            if r.hasGiftedTrait then
                1

            else
                0

        agilityBonus =
            if r.hasSmallFrameTrait then
                1

            else
                0
    in
    r.baseSpecial
        |> Special.mapWithoutClamp ((+) (strengthBonus + allBonus)) Special.Strength
        |> Special.mapWithoutClamp ((+) allBonus) Special.Perception
        |> Special.mapWithoutClamp ((+) allBonus) Special.Endurance
        |> Special.mapWithoutClamp ((+) allBonus) Special.Charisma
        |> Special.mapWithoutClamp ((+) allBonus) Special.Intelligence
        |> Special.mapWithoutClamp ((+) (agilityBonus + allBonus)) Special.Agility
        |> Special.mapWithoutClamp ((+) allBonus) Special.Luck


newCharAvailableSpecialPoints : Int
newCharAvailableSpecialPoints =
    5


newCharMaxTaggedSkills : Int
newCharMaxTaggedSkills =
    3


maxTraits : Int
maxTraits =
    2


perkRate : { hasSkilledTrait : Bool } -> Int
perkRate { hasSkilledTrait } =
    if hasSkilledTrait then
        4

    else
        3


{-| Reading a book at 7 INT costs 1+(10-7) = 4 ticks
-}
bookUseTickCost : { intelligence : Int } -> Int
bookUseTickCost { intelligence } =
    1 + (10 - intelligence)


{-| Bounds the level you can upgrade your skill to with books to 91%
-}
bookAddedSkillPercentage :
    { currentPercentage : Int
    , hasComprehensionPerk : Bool
    }
    -> Int
bookAddedSkillPercentage { currentPercentage, hasComprehensionPerk } =
    let
        comprehensionBonus =
            if hasComprehensionPerk then
                1.5

            else
                1
    in
    ((100 - toFloat currentPercentage) / 10 * comprehensionBonus)
        |> round


type ItemNotUsableReason
    = YouNeedTicks Int
    | YoureAtFullHp
    | ItemCannotBeUsedDirectly


canUseItem :
    { p
        | hp : Int
        , maxHp : Int
        , special : Special
        , traits : SeqSet Trait
        , ticks : Int
    }
    -> ItemKind.Kind
    -> Result ItemNotUsableReason ()
canUseItem p kind =
    let
        bookUseTickCost_ : Int
        bookUseTickCost_ =
            bookUseTickCost
                { intelligence = p.special.intelligence }

        checkEffect : ItemEffect.Effect -> Result ItemNotUsableReason ()
        checkEffect eff =
            case eff of
                ItemEffect.Heal _ ->
                    if p.hp >= p.maxHp then
                        Err YoureAtFullHp

                    else
                        Ok ()

                ItemEffect.RemoveAfterUse ->
                    Ok ()

                ItemEffect.BookRemoveTicks ->
                    if p.ticks < bookUseTickCost_ then
                        Err <| YouNeedTicks bookUseTickCost_

                    else
                        Ok ()

                ItemEffect.BookAddSkillPercent _ ->
                    Ok ()

        effects =
            ItemKind.usageEffects kind
    in
    if List.isEmpty effects then
        Err ItemCannotBeUsedDirectly

    else
        List.foldl
            (\eff acc ->
                case acc of
                    Err _ ->
                        acc

                    Ok () ->
                        checkEffect eff
            )
            (Ok ())
            effects


naturalDamageThreshold :
    { r
        | damageType : DamageType
        , opponentType : OpponentType
    }
    -> Int
naturalDamageThreshold r =
    case r.opponentType of
        Npc enemy ->
            EnemyType.damageThreshold r.damageType enemy

        Player _ ->
            0


damageThreshold :
    { damageType : DamageType
    , opponentType : OpponentType
    , equippedArmor : Maybe ItemKind.Kind
    }
    -> Int
damageThreshold r =
    let
        armorDamageThreshold =
            r.equippedArmor
                |> Maybe.map (ItemKind.armorDamageThreshold r.damageType)
                |> Maybe.withDefault 0
    in
    naturalDamageThreshold r
        + armorDamageThreshold


naturalDamageResistance :
    { r
        | damageType : DamageType
        , opponentType : OpponentType
    }
    -> Int
naturalDamageResistance r =
    case r.opponentType of
        Npc enemy ->
            EnemyType.damageResistance r.damageType enemy

        Player _ ->
            0


damageResistance :
    { damageType : DamageType
    , opponentType : OpponentType
    , equippedArmor : Maybe ItemKind.Kind
    , toughnessPerkRanks : Int
    }
    -> Int
damageResistance r =
    let
        fromArmor =
            r.equippedArmor
                |> Maybe.map (ItemKind.armorDamageResistance r.damageType)
                |> Maybe.withDefault 0

        fromToughnessPerk =
            r.toughnessPerkRanks * 10
    in
    naturalDamageResistance r
        + fromArmor
        + fromToughnessPerk


mainWorldName : String
mainWorldName =
    "main"


questTicksPerHour : Int
questTicksPerHour =
    2


burstShotChanceToHitPenalty : Int
burstShotChanceToHitPenalty =
    -- TODO we should think more of a penalty, to simulate the cone
    20


unarmedRange : Int
unarmedRange =
    1


unarmedAttackStyleAndApCost : Int -> List ( AttackStyle, Int )
unarmedAttackStyleAndApCost unaimedApCost =
    unaimedAimedAttackStyleAndApCost UnarmedUnaimed UnarmedAimed unaimedApCost


meleeAttackStyleAndApCost : Int -> List ( AttackStyle, Int )
meleeAttackStyleAndApCost unaimedApCost =
    unaimedAimedAttackStyleAndApCost MeleeUnaimed MeleeAimed unaimedApCost


shootAttackStyleAndApCost : Int -> List ( AttackStyle, Int )
shootAttackStyleAndApCost unaimedApCost =
    unaimedAimedAttackStyleAndApCost ShootSingleUnaimed ShootSingleAimed unaimedApCost


unaimedAimedAttackStyleAndApCost : AttackStyle -> (AimedShot -> AttackStyle) -> Int -> List ( AttackStyle, Int )
unaimedAimedAttackStyleAndApCost unaimed toAimed unaimedApCost =
    ( unaimed, unaimedApCost )
        :: List.map
            (\aim -> ( toAimed aim, unaimedApCost + aimedShotApCostPenalty ))
            AimedShot.all


attackStyleAndApCost : ItemKind.Kind -> List ( AttackStyle, Int )
attackStyleAndApCost kind =
    case kind of
        ItemKind.Knife ->
            meleeAttackStyleAndApCost 3

        ItemKind.PowerFist ->
            unarmedAttackStyleAndApCost 3

        ItemKind.MegaPowerFist ->
            unarmedAttackStyleAndApCost 3

        ItemKind.SuperSledge ->
            meleeAttackStyleAndApCost 3

        ItemKind.FragGrenade ->
            [ ( Throw, 4 ) ]

        ItemKind.Bozar ->
            [ ( ShootBurst, 6 ) ]

        ItemKind.RedRyderLEBBGun ->
            shootAttackStyleAndApCost 4

        ItemKind.HuntingRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.ScopedHuntingRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.SawedOffShotgun ->
            shootAttackStyleAndApCost 5

        ItemKind.SniperRifle ->
            shootAttackStyleAndApCost 6

        ItemKind.AssaultRifle ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.ExpandedAssaultRifle ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.PancorJackhammer ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.HkP90c ->
            ( ShootBurst, 5 ) :: shootAttackStyleAndApCost 4

        ItemKind.LaserPistol ->
            shootAttackStyleAndApCost 5

        ItemKind.PlasmaRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.GatlingLaser ->
            [ ( ShootBurst, 6 ) ]

        ItemKind.TurboPlasmaRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.GaussRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.GaussPistol ->
            shootAttackStyleAndApCost 4

        ItemKind.PulseRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.Smg10mm ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.Minigun ->
            [ ( ShootBurst, 6 ) ]

        ItemKind.RocketLauncher ->
            -- no aimed!
            [ ( ShootSingleUnaimed, 6 ) ]

        ItemKind.LaserRifle ->
            shootAttackStyleAndApCost 5

        ItemKind.LaserRifleExtCap ->
            shootAttackStyleAndApCost 5

        ItemKind.CattleProd ->
            meleeAttackStyleAndApCost 4

        ItemKind.SuperCattleProd ->
            meleeAttackStyleAndApCost 4

        ItemKind.Mauser9mm ->
            shootAttackStyleAndApCost 4

        ItemKind.Pistol14mm ->
            shootAttackStyleAndApCost 5

        ItemKind.CombatShotgun ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.HkCaws ->
            ( ShootBurst, 6 ) :: shootAttackStyleAndApCost 5

        ItemKind.Shotgun ->
            shootAttackStyleAndApCost 5

        -- ItemKind.AlienBlaster ->
        --     shootAttackStyleAndApCost 4
        -- ItemKind.SolarScorcher ->
        --     shootAttackStyleAndApCost 4
        ItemKind.Flare ->
            [ ( Throw, 1 ) ]

        ItemKind.Wakizashi ->
            meleeAttackStyleAndApCost 3

        ItemKind.LittleJesus ->
            meleeAttackStyleAndApCost 3

        ItemKind.Ripper ->
            meleeAttackStyleAndApCost 4

        ItemKind.Pistol223 ->
            shootAttackStyleAndApCost 5

        ItemKind.NeedlerPistol ->
            shootAttackStyleAndApCost 5

        ItemKind.MagnetoLaserPistol ->
            shootAttackStyleAndApCost 5

        ItemKind.PulsePistol ->
            shootAttackStyleAndApCost 4

        -- ItemKind.HolyHandGrenade ->
        --     [ ( Throw, 4 ) ]
        ItemKind.Fruit ->
            []

        ItemKind.HealingPowder ->
            []

        ItemKind.MeatJerky ->
            []

        ItemKind.Beer ->
            []

        ItemKind.Stimpak ->
            []

        ItemKind.SuperStimpak ->
            []

        ItemKind.BigBookOfScience ->
            []

        ItemKind.DeansElectronics ->
            []

        ItemKind.FirstAidBook ->
            []

        ItemKind.GunsAndBullets ->
            []

        ItemKind.ScoutHandbook ->
            []

        ItemKind.Robes ->
            []

        ItemKind.LeatherJacket ->
            []

        ItemKind.LeatherArmor ->
            []

        ItemKind.MetalArmor ->
            []

        ItemKind.TeslaArmor ->
            []

        ItemKind.CombatArmor ->
            []

        ItemKind.CombatArmorMk2 ->
            []

        ItemKind.PowerArmor ->
            []

        ItemKind.BBAmmo ->
            []

        ItemKind.SmallEnergyCell ->
            []

        ItemKind.Fmj223 ->
            []

        ItemKind.ShotgunShell ->
            []

        ItemKind.Jhp10mm ->
            []

        ItemKind.Jhp5mm ->
            []

        ItemKind.MicrofusionCell ->
            []

        ItemKind.Ec2mm ->
            []

        ItemKind.Tool ->
            []

        ItemKind.SuperToolKit ->
            []

        ItemKind.FuelCellRegulator ->
            []

        ItemKind.FuelCellController ->
            []

        ItemKind.LockPicks ->
            []

        ItemKind.ElectronicLockpick ->
            []

        ItemKind.AbnormalBrain ->
            []

        ItemKind.ChimpanzeeBrain ->
            []

        ItemKind.HumanBrain ->
            []

        ItemKind.CyberneticBrain ->
            []

        ItemKind.GECK ->
            []

        ItemKind.SkynetAim ->
            []

        ItemKind.MotionSensor ->
            []

        ItemKind.K9 ->
            []

        ItemKind.Ap5mm ->
            []

        ItemKind.Mm9 ->
            []

        ItemKind.Ball9mm ->
            []

        ItemKind.Ap10mm ->
            []

        ItemKind.Ap14mm ->
            []

        ItemKind.ExplosiveRocket ->
            []

        ItemKind.RocketAp ->
            []

        ItemKind.HnNeedlerCartridge ->
            []

        ItemKind.HnApNeedlerCartridge ->
            []

        ItemKind.TankerFob ->
            []

        ItemKind.SilverGeckoPelt ->
            []

        ItemKind.GoldenGeckoPelt ->
            []

        ItemKind.FireGeckoPelt ->
            []


unaimedAttackStyle : ItemKind.Kind -> AttackStyle
unaimedAttackStyle kind =
    kind
        |> attackStyleAndApCost
        |> List.Extra.find (\( style, _ ) -> AttackStyle.isUnaimed style)
        |> Maybe.map Tuple.first
        |> Maybe.withDefault AttackStyle.UnarmedUnaimed


strengthRequirementChanceToHitPenalty :
    { strength : Int
    , equippedWeapon : ItemKind.Kind
    }
    -> Int
strengthRequirementChanceToHitPenalty r =
    let
        strengthRequirement =
            ItemKind.weaponStrengthRequirement r.equippedWeapon
    in
    max 0 (strengthRequirement - r.strength) * 20


weaponDamageType : Maybe ItemKind.Kind -> DamageType
weaponDamageType equippedWeapon =
    case equippedWeapon of
        Nothing ->
            -- unarmed!
            DamageType.NormalDamage

        Just weapon ->
            ItemKind.weaponDamageType weapon
                |> Maybe.withDefault DamageType.NormalDamage


healAmountGenerator_ : { min : Int, max : Int } -> Generator Int
healAmountGenerator_ { min, max } =
    Random.int min max


healAmountGenerator : ItemKind.Kind -> Generator Int
healAmountGenerator kind =
    case ItemKind.healAmount kind of
        Just r ->
            healAmountGenerator_ r

        Nothing ->
            Random.constant 0


type UsedAmmo
    = PreferredAmmo ( Item.Id, ItemKind.Kind, Int )
    | FallbackAmmo ( Item.Id, ItemKind.Kind, Int )
    | NoUsableAmmo
    | NoAmmoNeeded


{-| When trying to use a weapon, look at the user's preferences (preferredAmmo)
and their inventory (opponent.items) and choose which ammo will be used.
-}
usedAmmo :
    { r
        | equippedWeapon : Maybe ItemKind.Kind
        , items : Dict Item.Id Item
        , preferredAmmo : Maybe ItemKind.Kind
    }
    -> UsedAmmo
usedAmmo r =
    case r.equippedWeapon of
        Nothing ->
            -- This is going to be unarmed combat without anything equipped (so
            -- no chance of eg. eating cells for Power Fist)
            NoAmmoNeeded

        Just equippedWeapon ->
            let
                usableAmmo : SeqSet ItemKind.Kind
                usableAmmo =
                    ItemKind.usableAmmoForWeapon equippedWeapon
                        |> SeqSet.fromList
            in
            if SeqSet.isEmpty usableAmmo then
                -- Eg. Solar Scorcher, I guess? Or any unarmed/melee weapon that doesn't eat ammo
                NoAmmoNeeded

            else
                let
                    fallback : () -> UsedAmmo
                    fallback () =
                        r.items
                            |> Dict.toList
                            |> List.filterMap
                                (\( id, { kind, count } ) ->
                                    if SeqSet.member kind usableAmmo then
                                        Just ( id, kind, count )

                                    else
                                        Nothing
                                )
                            |> List.head
                            |> Maybe.map FallbackAmmo
                            |> Maybe.withDefault NoUsableAmmo
                in
                case r.preferredAmmo of
                    Just preferredAmmo ->
                        if SeqSet.member preferredAmmo usableAmmo then
                            -- We can use the preferred ammo (if we have it in our inventory!)
                            -- NOTE: we'd like it to be that if you sell/consume all of your preferredAmmo, it stops being equipped.
                            -- That would mean this being Just is a guarantee that it also exists in the inventory.
                            -- But let's check it exists in inventory anyways.
                            case Dict.find (\_ item -> item.kind == preferredAmmo) r.items of
                                Nothing ->
                                    fallback ()

                                Just ( id, item ) ->
                                    PreferredAmmo ( id, item.kind, item.count )

                        else
                            -- We need to fall back to anything else that's usable and that's in our inventory.
                            fallback ()

                    Nothing ->
                        -- We're free to try anything (it's going to be a Fallback ammo)
                        fallback ()


maxPossibleMove :
    { actionPoints : Int
    , crippledLegs : Int
    }
    -> Int
maxPossibleMove r =
    if r.crippledLegs <= 0 then
        r.actionPoints

    else if r.crippledLegs == 1 then
        r.actionPoints // 4

    else
        0


bestCombatSkill : Special -> SeqDict Skill Int -> ( Skill, Int )
bestCombatSkill special addedSkillPercentages_ =
    Skill.combatSkills
        |> List.map (\s -> ( s, Skill.get special addedSkillPercentages_ s ))
        |> List.Extra.maximumBy Tuple.second
        |> -- Really shouldn't happen (empty `Skill.combatSkills`)
           Maybe.withDefault ( Skill.SmallGuns, 0 )


passesPlayerRequirement :
    Quest.PlayerRequirement
    ->
        { player
            | caps : Int
            , special : Special
            , addedSkillPercentages : SeqDict Skill Int
            , items : Dict Item.Id Item
        }
    -> Bool
passesPlayerRequirement req player =
    case req of
        Quest.SkillRequirement r ->
            case r.skill of
                Quest.Combat ->
                    let
                        maxCombatSkill : Int
                        maxCombatSkill =
                            bestCombatSkill player.special player.addedSkillPercentages
                                |> Tuple.second
                    in
                    maxCombatSkill >= r.percentage

                Quest.Specific skill ->
                    Skill.get player.special player.addedSkillPercentages skill >= r.percentage

        Quest.ItemRequirementOneOf itemsNeeded ->
            itemsNeeded
                |> List.any
                    (\item ->
                        player.items
                            |> Dict.any (\_ { kind, count } -> kind == item && count >= 1)
                    )

        Quest.CapsRequirement capsNeeded ->
            player.caps >= capsNeeded
