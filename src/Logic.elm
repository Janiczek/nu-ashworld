module Logic exposing
    ( AttackStats
    , ItemNotUsableReason(..)
    , actionPoints
    , addedSkillPercentages
    , armorClass
    , bookAddedSkillPercentage
    , bookUseTickCost
    , canUseItem
    , healingRate
    , hitpoints
    , maxTraits
    , perkRate
    , price
    , sequence
    , skillPointCost
    , skillPointsPerLevel
    , special
    , totalTags
    , unarmedAttackStats
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
import Maybe.Extra as Maybe


hitpoints :
    { level : Int
    , finalSpecial : Special
    }
    -> Int
hitpoints r =
    let
        { strength, endurance } =
            r.finalSpecial
    in
    15
        + (2 * endurance)
        + strength
        + (r.level * (2 + endurance // 2))


healingRate : Special -> Int
healingRate { endurance } =
    tickHealingRateMultiplier
        * max 1 (endurance // 3)


tickHealingRateMultiplier : Int
tickHealingRateMultiplier =
    2


armorClass :
    { finalSpecial : Special
    , hasKamikazeTrait : Bool
    }
    -> Int
armorClass r =
    let
        initial =
            if r.hasKamikazeTrait then
                0

            else
                r.finalSpecial.agility
    in
    -- TODO take armor into account once we have it
    initial


actionPoints :
    { finalSpecial : Special
    , hasBruiserTrait : Bool
    }
    -> Int
actionPoints r =
    let
        bruiserPenalty =
            if r.hasBruiserTrait then
                2

            else
                0
    in
    (5 + r.finalSpecial.agility // 2)
        - bruiserPenalty


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
    , attackerFinalSpecial : Special
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
                Skill.get r.attackerFinalSpecial r.attackerAddedSkillPercentages Skill.Unarmed

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


xpGained : { damageDealt : Int } -> Int
xpGained { damageDealt } =
    damageDealt * xpPerHpMultiplier


type alias AttackStats =
    { minDamage : Int
    , maxDamage : Int
    , criticalChanceBonus : Int
    }


unarmedAttackStats :
    { finalSpecial : Special
    , unarmedSkill : Int
    , traits : Set_.Set Trait
    , perks : Dict_.Dict Perk Int
    , level : Int
    , extraBonus : Int -- for NPCs
    }
    -> AttackStats
unarmedAttackStats r =
    let
        { strength, agility } =
            r.finalSpecial

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
            minDamage + bonusMeleeDamage + r.extraBonus
    in
    -- TODO refactor this into the attacks (Punch, StrongPunch, ...)
    -- TODO return a list of possible attacks
    -- TODO track their AP cost too
    { minDamage = minDamage
    , maxDamage = maxDamage
    , criticalChanceBonus = criticalChanceBonus
    }


price :
    { itemKind : Item.Kind
    , itemCount : Int
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

        itemTotalPrice : Int
        itemTotalPrice =
            Item.basePrice r.itemKind * r.itemCount
    in
    round (toFloat itemTotalPrice * barterRatio * (toFloat barterPercent * 0.01))


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


special :
    { -- doesn't contain bonunses from traits, perks, armor, drugs, etc.
      baseSpecial : Special
    , hasBruiserTrait : Bool
    , hasGiftedTrait : Bool
    , hasSmallFrameTrait : Bool
    , isNewChar : Bool
    }
    -> Special
special r =
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

        map =
            if r.isNewChar then
                Special.mapWithoutClamp

            else
                Special.map
    in
    r.baseSpecial
        |> map ((+) (strengthBonus + allBonus)) Special.Strength
        |> map ((+) allBonus) Special.Perception
        |> map ((+) allBonus) Special.Endurance
        |> map ((+) allBonus) Special.Charisma
        |> map ((+) allBonus) Special.Intelligence
        |> map ((+) (agilityBonus + allBonus)) Special.Agility
        |> map ((+) allBonus) Special.Luck


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
    | ItemHasNoUse


canUseItem :
    { p
        | hp : Int
        , maxHp : Int
        , baseSpecial : Special
        , traits : Set_.Set Trait
        , ticks : Int
    }
    -> Item.Kind
    -> Result ItemNotUsableReason ()
canUseItem p kind =
    let
        finalSpecial : Special
        finalSpecial =
            special
                { baseSpecial = p.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser p.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted p.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame p.traits
                , isNewChar = False
                }

        bookUseTickCost_ : Int
        bookUseTickCost_ =
            bookUseTickCost
                { intelligence = finalSpecial.intelligence }

        youreAtFullHp : Maybe ItemNotUsableReason
        youreAtFullHp =
            if p.hp >= p.maxHp then
                Just YoureAtFullHp

            else
                Nothing

        youNeedTicks : Maybe ItemNotUsableReason
        youNeedTicks =
            if p.ticks < bookUseTickCost_ then
                Just <| YouNeedTicks bookUseTickCost_

            else
                Nothing

        combineErrors : List (Maybe ItemNotUsableReason) -> Result ItemNotUsableReason ()
        combineErrors errors =
            case List.head (Maybe.values errors) of
                Nothing ->
                    Ok ()

                Just err ->
                    Err err
    in
    if List.isEmpty (Item.usageEffects kind) then
        Err ItemHasNoUse

    else
        case kind of
            Stimpak ->
                combineErrors [ youreAtFullHp ]

            BigBookOfScience ->
                combineErrors [ youNeedTicks ]

            DeansElectronics ->
                combineErrors [ youNeedTicks ]

            FirstAidBook ->
                combineErrors [ youNeedTicks ]

            GunsAndBullets ->
                combineErrors [ youNeedTicks ]

            ScoutHandbook ->
                combineErrors [ youNeedTicks ]
