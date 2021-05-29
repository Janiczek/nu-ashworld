module Logic exposing
    ( AttackStats
    , ItemNotUsableReason(..)
    , actionPoints
    , addedSkillPercentages
    , armorClass
    , bookAddedSkillPercentage
    , bookUseTickCost
    , canUseItem
    , damageResistanceNormal
    , damageThresholdNormal
    , healPerTick
    , hitpoints
    , maxTraits
    , naturalArmorClass
    , newCharSpecial
    , perkRate
    , playerCombatXpGained
    , price
    , sequence
    , skillPointCost
    , skillPointsPerLevel
    , tickHealPercentage
    , totalTags
    , unarmedAttackStats
    , unarmedBaseCriticalChance
    , unarmedChanceToHit
    , xpGained
    )

import AssocList as Dict_
import AssocSet as Set_
import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.Item as Item exposing (Kind(..))
import Data.Perk as Perk exposing (Perk)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp exposing (BaseXp(..))


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
    , equippedArmor : Maybe Item.Kind
    , hasHthEvadePerk : Bool
    , unarmedSkill : Int
    , apFromPreviousTurn : Int
    }
    -> Int
armorClass r =
    let
        fromArmor =
            r.equippedArmor
                |> Maybe.map Item.armorClass
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


distancePenalty : Int -> Int
distancePenalty distanceHexes =
    distanceHexes * 4


darknessPenalty : Bool -> Int -> Int
darknessPenalty isItDark distanceHexes =
    if isItDark then
        if distanceHexes <= 0 then
            0

        else if distanceHexes == 1 then
            10

        else if distanceHexes == 2 then
            25

        else
            -- 3+
            40

    else
        0


unarmedChanceToHit :
    { attackerAddedSkillPercentages : Dict_.Dict Skill Int
    , attackerSpecial : Special
    , distanceHexes : Int
    , shotType : ShotType
    , targetArmorClass : Int
    }
    -> Int
unarmedChanceToHit r =
    let
        -- TODO vary the nighttime
        isItDark =
            False
    in
    -- TODO choose between unarmed and melee. Right now, having no inventory, we choose unarmed
    if r.distanceHexes > 0 then
        0

    else
        let
            skillPercentage : Int
            skillPercentage =
                Skill.get r.attackerSpecial r.attackerAddedSkillPercentages Skill.Unarmed

            shotPenalty : Int
            shotPenalty =
                ShotType.chanceToHitPenalty r.shotType
        in
        (skillPercentage
            - r.targetArmorClass
            - shotPenalty
            {- Those two never matter for unarmed fights right now, but let's
               keep them in case we later tweak the two functions to do something
               when distance = 0:
            -}
            - distancePenalty r.distanceHexes
            - darknessPenalty isItDark r.distanceHexes
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


unarmedAttackStats :
    { special : Special
    , unarmedSkill : Int
    , traits : Set_.Set Trait
    , perks : Dict_.Dict Perk Int
    , level : Int
    , npcExtraBonus : Int
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
            minDamage + bonusMeleeDamage + r.npcExtraBonus
    in
    -- TODO refactor this into the attacks (Punch, StrongPunch, ...)
    -- TODO return a list of possible attacks
    -- TODO track their AP cost too
    { minDamage = minDamage
    , maxDamage = maxDamage
    , criticalChanceBonus = criticalChanceBonus
    }


unarmedBaseCriticalChance :
    { special : Special
    , hasFinesseTrait : Bool
    , moreCriticalPerkRanks : Int
    , hasSlayerPerk : Bool
    }
    -> Int
unarmedBaseCriticalChance r =
    -- TODO sniper perk and non-unarmed combat
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
    { taggedSkills : Set_.Set Skill
    , hasGiftedTrait : Bool
    }
    -> Dict_.Dict Skill Int
addedSkillPercentages { taggedSkills, hasGiftedTrait } =
    let
        taggedSkillBonuses =
            taggedSkills
                |> Set_.toList
                {- Each tag adds 20% at the beginning. This doesn't happen
                   later when adding a tag via the Tag! perk.
                -}
                |> List.map (\skill -> ( skill, 20 ))
                |> Dict_.fromList

        giftedTraitPenalties =
            if hasGiftedTrait then
                Skill.all
                    |> List.map (\skill -> ( skill, -10 ))
                    |> Dict_.fromList

            else
                Dict_.empty
    in
    [ taggedSkillBonuses
    , giftedTraitPenalties
    ]
        |> List.foldl
            (\bonusesDict accSkills ->
                bonusesDict
                    |> Dict_.foldl
                        (\bonusSkill bonus accSkills_ ->
                            accSkills_
                                |> Dict_.update bonusSkill
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
            Dict_.empty


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
    | ItemCannotByUsedDirectly


canUseItem :
    { p
        | hp : Int
        , maxHp : Int
        , special : Special
        , traits : Set_.Set Trait
        , ticks : Int
    }
    -> Item.Kind
    -> Result ItemNotUsableReason ()
canUseItem p kind =
    let
        bookUseTickCost_ : Int
        bookUseTickCost_ =
            bookUseTickCost
                { intelligence = p.special.intelligence }

        checkEffect : Item.Effect -> Result ItemNotUsableReason ()
        checkEffect eff =
            case eff of
                Item.Heal _ ->
                    if p.hp >= p.maxHp then
                        Err YoureAtFullHp

                    else
                        Ok ()

                Item.RemoveAfterUse ->
                    Ok ()

                Item.BookRemoveTicks ->
                    if p.ticks < bookUseTickCost_ then
                        Err <| YouNeedTicks bookUseTickCost_

                    else
                        Ok ()

                Item.BookAddSkillPercent _ ->
                    Ok ()

        effects =
            Item.usageEffects kind
    in
    if List.isEmpty effects then
        Err ItemCannotByUsedDirectly

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


damageThresholdNormal :
    { naturalDamageThresholdNormal : Int
    , equippedArmor : Maybe Item.Kind
    }
    -> Int
damageThresholdNormal r =
    let
        armorDamageThreshold =
            r.equippedArmor
                |> Maybe.map Item.damageThresholdNormal
                |> Maybe.withDefault 0
    in
    r.naturalDamageThresholdNormal + armorDamageThreshold


damageResistanceNormal :
    { naturalDamageResistanceNormal : Int
    , equippedArmor : Maybe Item.Kind
    , toughnessPerkRanks : Int
    }
    -> Int
damageResistanceNormal r =
    let
        fromArmor =
            r.equippedArmor
                |> Maybe.map Item.damageResistanceNormal
                |> Maybe.withDefault 0

        fromToughnessPerk =
            r.toughnessPerkRanks * 10
    in
    r.naturalDamageResistanceNormal + fromArmor + fromToughnessPerk
