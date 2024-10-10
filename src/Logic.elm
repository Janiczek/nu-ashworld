module Logic exposing
    ( AttackStats
    , ItemNotUsableReason(..)
    , actionPoints
    , addedSkillPercentages
    , aimedShotApCostPenalty
    , armorClass
    , attackApCost
    , attackStats
    , attackStyleAndApCost
    , baseCriticalChance
    , bookAddedSkillPercentage
    , bookUseTickCost
    , canBurst
    , canUseItem
    , chanceToHit
    , damageResistance
    , damageThreshold
    , healAmountGenerator
    , healAmountGenerator_
    , healApCost
    , healPerTick
    , hitpoints
    , mainWorldName
    , maxTraits
    , minTicksPerHourNeededForQuest
    , naturalArmorClass
    , newCharAvailableSpecialPoints
    , newCharMaxTaggedSkills
    , newCharSpecial
    , perkRate
    , playerCombatCapsGained
    , playerCombatXpGained
    , price
    , regainConciousnessApCost
    , sequence
    , skillPointCost
    , skillPointsPerLevel
    , tickHealPercentage
    , ticksGivenPerQuestEngagement
    , totalTags
    , unarmedApCost
    , unarmedRange
    , weaponDamageType
    , weaponRange
    , xpGained
    )

import Data.Enemy as Enemy
import Data.Fight.AimedShot as AimedShot exposing (AimedShot(..))
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Fight.DamageType as DamageType exposing (DamageType(..))
import Data.Fight.OpponentType exposing (OpponentType(..))
import Data.Item.Effect as ItemEffect
import Data.Item.Kind as ItemKind
import Data.Item.Type as ItemType
import Data.Perk as Perk exposing (Perk)
import Data.Quest as Quest exposing (Engagement(..))
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp exposing (BaseXp(..))
import Random exposing (Generator)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


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


regainConciousnessApCost : { maxAP : Int } -> Int
regainConciousnessApCost r =
    r.maxAP // 2


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
    { endurance : Int
    , fasterHealingPerkRanks : Int
    }
    -> Int
tickHealPercentage r =
    50
        + (r.endurance * 2)
        + (r.fasterHealingPerkRanks * 10)


healPerTick : Int
healPerTick =
    4


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
    , hasHthEvadePerk : Bool
    , unarmedSkill : Int
    , apFromPreviousTurn : Int
    }
    -> Int
armorClass r =
    let
        fromArmor =
            r.equippedArmor
                |> Maybe.map ItemKind.armorClass
                |> Maybe.withDefault 0

        unusedApMultiplier =
            if r.hasHthEvadePerk then
                2

            else
                1

        fromUnusedAp =
            r.apFromPreviousTurn * unusedApMultiplier

        fromUnarmedSkill =
            if r.hasHthEvadePerk then
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
                if r.perception >= 5 && r.distanceHexes < ((r.perception - 4) * 2) then
                    r.perception * 8

                else
                    (r.perception - 2) * 16 - r.distanceHexes * 4

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
    , distanceHexes : Int
    , equippedWeapon : Maybe ItemKind.Kind
    , preferredAmmo : Maybe ItemKind.Kind
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
        , targetArmorClass : Int
        , distanceHexes : Int
        , equippedWeapon : Maybe ItemKind.Kind
        , preferredAmmo : Maybe ItemKind.Kind
        , attackStyle : AttackStyle
    }
    -> Int
rangedChanceToHit r =
    if SeqSet.member Trait.FastShot r.attackerTraits && AttackStyle.isAimed r.attackStyle then
        -- FastShot doesn't work with aimed attacks
        0

    else
        case r.equippedWeapon of
            Nothing ->
                -- Can't have ranged attacks without a weapon
                0

            Just equippedWeapon ->
                if r.distanceHexes > ItemKind.range r.attackStyle equippedWeapon then
                    -- Wanted to attack at a range the weapon can't do
                    0

                else
                    case neededSkill r.attackStyle (ItemKind.types equippedWeapon) of
                        Nothing ->
                            -- Wanted to attack in an `attackStyle` the weapon can't do
                            0

                        Just weaponSkill ->
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
                                        }

                                ammoArmorClassModifier : Int
                                ammoArmorClassModifier =
                                    r.preferredAmmo
                                        |> Maybe.map ItemKind.ammoArmorClassModifier
                                        |> Maybe.withDefault 0

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
                            in
                            (weaponSkill_
                                + (8 * r.attackerSpecial.perception)
                                -- weapon long range perk is already factored into the distancePenalty
                                + weaponAccuratePerk
                                - distancePenalty_
                                - ((r.targetArmorClass * (100 + ammoArmorClassModifier)) // 100)
                                - lightingPenalty_
                                - strengthRequirementPenalty
                                - shotPenalty
                            )
                                |> clamp 0 95


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
        , equippedWeapon : Maybe ItemKind.Kind
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

    else
        case
            neededSkill r.attackStyle
                (r.equippedWeapon
                    |> Maybe.map ItemKind.types
                    |> Maybe.withDefault []
                )
        of
            Nothing ->
                -- Wanted to attack in an `attackStyle` the weapon can't do
                0

            Just weaponSkill ->
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
                    - r.targetArmorClass
                    - shotPenalty
                )
                    |> clamp 0 95


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
    , unarmedDamageBonus : Int
    }
    -> AttackStats
attackStats r =
    case r.equippedWeapon of
        Nothing ->
            unarmedAttackStats
                { special = r.special
                , unarmedSkill = Skill.get r.special r.addedSkillPercentages Skill.Unarmed
                , traits = r.traits
                , perks = r.perks
                , level = r.level
                , unarmedDamageBonus = r.unarmedDamageBonus
                }

        Just weapon ->
            armedAttackStats
                { bonusRangedDamagePerkRank = Perk.rank Perk.BonusRangedDamage r.perks
                , equippedWeapon = weapon
                }


armedAttackStats :
    { bonusRangedDamagePerkRank : Int
    , equippedWeapon : ItemKind.Kind
    }
    -> AttackStats
armedAttackStats r =
    let
        weapon : { min : Int, max : Int }
        weapon =
            ItemKind.weaponDamage r.equippedWeapon

        rangedDamagePerkBonus : Int
        rangedDamagePerkBonus =
            2 * r.bonusRangedDamagePerkRank
    in
    -- TODO Pyromaniac - +5 damage if weapon damage type is Fire
    { minDamage = weapon.min + rangedDamagePerkBonus
    , maxDamage = weapon.max + rangedDamagePerkBonus
    , criticalChanceBonus = 0
    }


unarmedAttackStats :
    { special : Special
    , unarmedSkill : Int
    , traits : SeqSet Trait
    , perks : SeqDict Perk Int
    , level : Int
    , unarmedDamageBonus : Int
    }
    -> AttackStats
unarmedAttackStats r =
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

        { unarmedAttackBonus, criticalChanceBonus } =
            if r.unarmedSkill < 55 || agility < 6 then
                { unarmedAttackBonus = 0
                , criticalChanceBonus = 0
                }

            else if r.unarmedSkill < 75 || strength < 5 || r.level < 6 then
                { unarmedAttackBonus = 3
                , criticalChanceBonus = 0
                }

            else if r.unarmedSkill < 100 || agility < 7 || r.level < 9 then
                { unarmedAttackBonus = 5
                , criticalChanceBonus = 5
                }

            else
                { unarmedAttackBonus = 7
                , criticalChanceBonus = 15
                }

        minDamage : Int
        minDamage =
            1 + unarmedAttackBonus

        maxDamage : Int
        maxDamage =
            minDamage + bonusMeleeDamage + r.unarmedDamageBonus
    in
    -- TODO refactor this into the attacks (Punch, StrongPunch, ...)
    -- TODO return a list of possible attacks
    -- TODO track their AP cost too
    { minDamage = minDamage
    , maxDamage = maxDamage
    , criticalChanceBonus = criticalChanceBonus
    }


baseCriticalChance :
    { special : Special
    , hasFinesseTrait : Bool
    , moreCriticalPerkRanks : Int
    , hasSlayerPerk : Bool
    }
    -> Int
baseCriticalChance r =
    -- TODO sniper perk and non-unarmed combat
    unarmedBaseCriticalChance r


unarmedBaseCriticalChance :
    { special : Special
    , hasFinesseTrait : Bool
    , moreCriticalPerkRanks : Int
    , hasSlayerPerk : Bool
    }
    -> Int
unarmedBaseCriticalChance r =
    let
        fromSpecial =
            r.special.luck

        fromFinesse =
            if r.hasFinesseTrait then
                10

            else
                0

        fromMoreCriticals =
            r.moreCriticalPerkRanks * 5

        fromSlayer =
            if r.hasSlayerPerk then
                100

            else
                0
    in
    (fromSpecial
        + fromFinesse
        + fromMoreCriticals
        + fromSlayer
    )
        |> min 100


price :
    { baseValue : Int
    , playerBarterSkill : Int
    , traderBarterSkill : Int
    , hasMasterTraderPerk : Bool
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
            max 1 (100 - masterTraderDiscount)

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
            Enemy.damageThreshold r.damageType enemy

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
            Enemy.damageResistance r.damageType enemy

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


minTicksPerHourNeededForQuest : Int
minTicksPerHourNeededForQuest =
    Quest.allEngagement
        |> List.map ticksGivenPerQuestEngagement
        |> List.filter (\tph -> tph /= 0)
        |> List.minimum
        |> Maybe.withDefault 1


ticksGivenPerQuestEngagement : Quest.Engagement -> Int
ticksGivenPerQuestEngagement engagement =
    case engagement of
        NotProgressing ->
            0

        ProgressingSlowly ->
            1

        Progressing ->
            2


burstShotChanceToHitPenalty : Int
burstShotChanceToHitPenalty =
    -- TODO we should think more of a penalty, to simulate the cone
    -- TODO also, every bullet needs to have its own chance to hit
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

        ItemKind.AlienBlaster ->
            shootAttackStyleAndApCost 4

        ItemKind.SolarScorcher ->
            shootAttackStyleAndApCost 4

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

        ItemKind.HolyHandGrenade ->
            [ ( Throw, 4 ) ]

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


canBurst : ItemKind.Kind -> Bool
canBurst kind =
    attackStyleAndApCost kind
        |> List.any (\( style, _ ) -> style == ShootBurst)


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
