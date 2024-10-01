module Calculator.Meta.Individual exposing (Individual, crossover, generator, mutate)

import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.FightStrategy as FightStrategy exposing (FightStrategy)
import Data.Item as Item
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import List.Extra
import Logic
import Random exposing (Generator)
import Random.List
import SeqSet exposing (SeqSet)


type alias Individual =
    { special : Special
    , traits : SeqSet Trait
    , taggedSkills : SeqSet Skill
    , fightStrategy : FightStrategy
    }


generator : Generator Individual
generator =
    traitsGenerator
        |> Random.andThen
            (\traits ->
                let
                    specialAfterTraits : Special
                    specialAfterTraits =
                        Logic.newCharSpecial
                            { baseSpecial = Special.init
                            , hasBruiserTrait = SeqSet.member Trait.Bruiser traits
                            , hasGiftedTrait = SeqSet.member Trait.Gifted traits
                            , hasSmallFrameTrait = SeqSet.member Trait.SmallFrame traits
                            }
                in
                Random.map3
                    (\special taggedSkills fightStrategy ->
                        { special = special
                        , traits = traits
                        , taggedSkills = taggedSkills
                        , fightStrategy = fightStrategy
                        }
                    )
                    (specialGenerator specialAfterTraits)
                    skillsGenerator
                    fightStrategyGenerator
            )


commandGenerator : Generator FightStrategy.Command
commandGenerator =
    Random.uniform
        (Random.map FightStrategy.Attack shotTypeGenerator)
        [ Random.constant FightStrategy.AttackRandomly
        , Random.map FightStrategy.Heal healingItemKindGenerator
        , Random.constant FightStrategy.MoveForward
        , Random.constant FightStrategy.DoWhatever
        ]
        |> Random.andThen identity


healingItemKindGenerator : Generator Item.Kind
healingItemKindGenerator =
    let
        ( x, xs ) =
            Item.allHealingNonempty
    in
    Random.uniform x xs


itemKindGenerator : Generator Item.Kind
itemKindGenerator =
    let
        ( x, xs ) =
            Item.allNonempty
    in
    Random.uniform x xs


shotTypeGenerator : Generator ShotType
shotTypeGenerator =
    Random.uniform ShotType.NormalShot
        (List.map ShotType.AimedShot ShotType.allAimed)


conditionGenerator : Generator FightStrategy.Condition
conditionGenerator =
    let
        self =
            Random.lazy (\() -> conditionGenerator)
    in
    Random.uniform
        (Random.map3
            (\lhs op rhs ->
                FightStrategy.Operator
                    { lhs = lhs
                    , op = op
                    , rhs = rhs
                    }
            )
            valueGenerator
            operatorGenerator
            valueGenerator
        )
        [ Random.constant FightStrategy.OpponentIsPlayer
        , Random.constant FightStrategy.OpponentIsNPC
        , Random.map2 FightStrategy.Or self self
        , Random.map2 FightStrategy.And self self
        ]
        |> Random.andThen identity


valueGenerator : Generator FightStrategy.Value
valueGenerator =
    Random.uniform
        (Random.constant FightStrategy.MyHP)
        [ Random.constant FightStrategy.MyMaxHP
        , Random.constant FightStrategy.MyAP
        , Random.map FightStrategy.MyItemCount itemKindGenerator
        , Random.map FightStrategy.ItemsUsed itemKindGenerator
        , Random.map FightStrategy.ChanceToHit shotTypeGenerator
        , Random.constant FightStrategy.Distance
        , Random.map FightStrategy.Number (Random.int -50 300)
        ]
        |> Random.andThen identity


operatorGenerator : Generator FightStrategy.Operator
operatorGenerator =
    Random.uniform FightStrategy.LT_
        [ FightStrategy.LTE
        , FightStrategy.EQ_
        , FightStrategy.NE
        , FightStrategy.GTE
        , FightStrategy.GT_
        ]


maxStrategyDepth : Int
maxStrategyDepth =
    2


fightStrategyGenerator : Generator FightStrategy
fightStrategyGenerator =
    strategyGenerator 0
        |> Random.map moveForwardIfNeeded


strategyGenerator : Int -> Generator FightStrategy
strategyGenerator depth =
    if depth >= maxStrategyDepth then
        Random.map FightStrategy.Command commandGenerator

    else
        Random.uniform
            (Random.map FightStrategy.Command commandGenerator)
            [ Random.map3
                (\condition thenStrategy elseStrategy ->
                    FightStrategy.If
                        { condition = condition
                        , then_ = thenStrategy
                        , else_ = elseStrategy
                        }
                )
                conditionGenerator
                (strategyGenerator (depth + 1))
                (strategyGenerator (depth + 1))
            ]
            |> Random.andThen identity


moveForwardIfNeeded : FightStrategy -> FightStrategy
moveForwardIfNeeded strategy =
    FightStrategy.If
        { condition =
            FightStrategy.Operator
                { lhs = FightStrategy.Distance
                , op = FightStrategy.GT_
                , rhs = FightStrategy.Number 0
                }
        , then_ = FightStrategy.Command FightStrategy.MoveForward
        , else_ = strategy
        }


specialGenerator : Special -> Generator Special
specialGenerator baseSpecial =
    let
        totalPoints : Int
        totalPoints =
            Special.sum baseSpecial + Logic.newCharAvailableSpecialPoints
    in
    Random.list 7 (Random.float 1 10)
        |> Random.map
            (\weights ->
                let
                    weightSum : Float
                    weightSum =
                        List.sum weights

                    perWeightPoint : Float
                    perWeightPoint =
                        toFloat totalPoints / weightSum

                    normalized : List Int
                    normalized =
                        weights
                            |> List.Extra.indexedFoldl
                                (\i weight ( accSum, accList ) ->
                                    if i == 6 then
                                        ( accSum
                                        , totalPoints - accSum :: accList
                                        )

                                    else
                                        let
                                            new : Int
                                            new =
                                                round (weight * perWeightPoint)
                                        in
                                        ( accSum + new
                                        , new :: accList
                                        )
                                )
                                ( 0, [] )
                            |> Tuple.second
                in
                case normalized of
                    [ s, p, e, c, i, a, l ] ->
                        Special.init
                            |> Special.set Special.Strength s
                            |> Special.set Special.Perception p
                            |> Special.set Special.Endurance e
                            |> Special.set Special.Charisma c
                            |> Special.set Special.Intelligence i
                            |> Special.set Special.Agility a
                            |> Special.set Special.Luck l

                    _ ->
                        -- Can't happen
                        baseSpecial
            )


traitsGenerator : Generator (SeqSet Trait)
traitsGenerator =
    Random.int 0 Logic.maxTraits
        |> Random.andThen
            (\n ->
                if n == 0 then
                    Random.constant []

                else
                    Trait.all
                        |> Random.List.choices n
                        |> Random.map Tuple.first
            )
        |> Random.map SeqSet.fromList


skillsGenerator : Generator (SeqSet Skill)
skillsGenerator =
    Skill.all
        |> Random.List.choices Logic.newCharMaxTaggedSkills
        |> Random.map (Tuple.first >> SeqSet.fromList)


crossover : Individual -> Individual -> Generator Individual
crossover parent1 parent2 =
    Random.map4
        (\special taggedSkills traits fightStrategy ->
            { special = special
            , taggedSkills = taggedSkills
            , traits = traits
            , fightStrategy = fightStrategy
            }
        )
        (crossoverSpecial parent1.special parent2.special)
        (crossoverTaggedSkills parent1.taggedSkills parent2.taggedSkills)
        (crossoverTraits parent1.traits parent2.traits)
        (crossoverFightStrategy parent1.fightStrategy parent2.fightStrategy)


crossoverSpecial : Special -> Special -> Generator Special
crossoverSpecial s1 s2 =
    -- We can't do too much in the way of averaging or picking pointwise - we
    -- couldn't guarantee such a SPECIAL can be made with a new char.
    -- Let's rather pick one or the other parent.
    Random.uniform s1 [ s2 ]


crossoverTaggedSkills : SeqSet Skill -> SeqSet Skill -> Generator (SeqSet Skill)
crossoverTaggedSkills s1 s2 =
    let
        unionSkills : List Skill
        unionSkills =
            SeqSet.union s1 s2
                |> SeqSet.toList
    in
    Random.List.choices Logic.newCharMaxTaggedSkills unionSkills
        |> Random.map (Tuple.first >> SeqSet.fromList)


crossoverTraits : SeqSet Trait -> SeqSet Trait -> Generator (SeqSet Trait)
crossoverTraits t1 t2 =
    let
        unionTraits : List Trait
        unionTraits =
            SeqSet.union t1 t2
                |> SeqSet.toList
    in
    Random.int 0 Logic.maxTraits
        |> Random.andThen
            (\traits ->
                Random.List.choices traits unionTraits
                    |> Random.map (Tuple.first >> SeqSet.fromList)
            )


crossoverFightStrategy : FightStrategy -> FightStrategy -> Generator FightStrategy
crossoverFightStrategy f1 f2 =
    let
        getRandomSubtree : FightStrategy -> Generator FightStrategy
        getRandomSubtree strategy =
            case strategy of
                FightStrategy.Command _ ->
                    Random.constant strategy

                FightStrategy.If ifData ->
                    Random.uniform strategy
                        [ ifData.then_
                        , ifData.else_
                        ]
                        |> Random.andThen getRandomSubtree

        replaceRandomSubtree : FightStrategy -> FightStrategy -> Generator FightStrategy
        replaceRandomSubtree original replacement =
            case original of
                FightStrategy.Command _ ->
                    Random.constant replacement

                FightStrategy.If ifData ->
                    let
                        isTerminal strategy =
                            case strategy of
                                FightStrategy.Command _ ->
                                    True

                                FightStrategy.If _ ->
                                    False

                        thenIsTerminal =
                            isTerminal ifData.then_

                        elseIsTerminal =
                            isTerminal ifData.else_
                    in
                    if thenIsTerminal && elseIsTerminal then
                        -- we _have_ to replace somewhere on this level
                        Random.uniform
                            replacement
                            [ FightStrategy.If { ifData | then_ = replacement }
                            , FightStrategy.If { ifData | else_ = replacement }
                            ]

                    else
                        Random.uniform
                            (Random.constant replacement)
                            [ Random.constant <| FightStrategy.If { ifData | then_ = replacement }
                            , Random.constant <| FightStrategy.If { ifData | else_ = replacement }

                            -- replace somewhere deeper
                            , replaceRandomSubtree ifData.then_ replacement |> Random.map (\newThen -> FightStrategy.If { ifData | then_ = newThen })
                            , replaceRandomSubtree ifData.else_ replacement |> Random.map (\newElse -> FightStrategy.If { ifData | else_ = newElse })
                            ]
                            |> Random.andThen identity
    in
    getRandomSubtree f2
        |> Random.andThen (\f2Subtree -> replaceRandomSubtree f1 f2Subtree)


mutateProb : Float
mutateProb =
    0.125


conditionallyMutate : (a -> Generator a) -> a -> Generator a
conditionallyMutate mutate_ thing =
    Random.float 0 1
        |> Random.andThen
            (\p ->
                if p >= mutateProb then
                    mutate_ thing

                else
                    Random.constant thing
            )


mutate : Individual -> Generator Individual
mutate ind =
    Random.map4
        (\special taggedSkills traits fightStrategy ->
            { special = special
            , taggedSkills = taggedSkills
            , traits = traits
            , fightStrategy = fightStrategy
            }
        )
        (conditionallyMutate mutateSpecial ind.special)
        (conditionallyMutate mutateTaggedSkills ind.taggedSkills)
        (conditionallyMutate mutateTraits ind.traits)
        (conditionallyMutate mutateFightStrategy ind.fightStrategy)


mutateSpecial : Special -> Generator Special
mutateSpecial special =
    special
        |> Special.toList
        |> Random.List.shuffle
        |> Random.map (Special.fromList >> Maybe.withDefault special)


mutateTaggedSkills : SeqSet Skill -> Generator (SeqSet Skill)
mutateTaggedSkills taggedSkills =
    let
        nontaggedSkills =
            Skill.all
                |> List.filter (\m -> not (SeqSet.member m taggedSkills))
    in
    Random.List.choose (SeqSet.toList taggedSkills)
        |> Random.andThen
            (\( _, taggedWithoutOne ) ->
                Random.List.choose nontaggedSkills
                    |> Random.map
                        (\( maybeNewTagged, _ ) ->
                            SeqSet.fromList
                                (case maybeNewTagged of
                                    Nothing ->
                                        -- Shouldn't happen
                                        taggedWithoutOne

                                    Just newTagged ->
                                        newTagged :: taggedWithoutOne
                                )
                        )
            )


mutateTraits : SeqSet Trait -> Generator (SeqSet Trait)
mutateTraits traits =
    let
        removeTrait : SeqSet Trait -> Generator (SeqSet Trait)
        removeTrait ts =
            ts
                |> SeqSet.toList
                |> Random.List.choose
                |> Random.map (\( _, withoutOne ) -> SeqSet.fromList withoutOne)

        addTrait : SeqSet Trait -> Generator (SeqSet Trait)
        addTrait ts =
            Trait.all
                |> List.filter (\m -> not (SeqSet.member m ts))
                |> Random.List.choose
                |> Random.map
                    (\( maybeNew, _ ) ->
                        case maybeNew of
                            Nothing ->
                                ts

                            Just new ->
                                SeqSet.insert new ts
                    )

        replaceTrait : SeqSet Trait -> Generator (SeqSet Trait)
        replaceTrait ts =
            removeTrait ts
                |> Random.andThen addTrait
    in
    Random.uniform
        (replaceTrait traits)
        (List.filterMap identity
            [ if SeqSet.size traits > 0 then
                Just (removeTrait traits)

              else
                Nothing
            , if SeqSet.size traits < Logic.maxTraits then
                Just (addTrait traits)

              else
                Nothing
            ]
        )
        |> Random.andThen identity


mutateFightStrategy : FightStrategy -> Generator FightStrategy
mutateFightStrategy str =
    let
        mutateCommand : FightStrategy.Command -> Generator FightStrategy.Command
        mutateCommand cmd =
            Random.uniform commandGenerator
                [ mutateCommandDetails cmd ]
                |> Random.andThen identity

        mutateCommandDetails : FightStrategy.Command -> Generator FightStrategy.Command
        mutateCommandDetails cmd =
            case cmd of
                FightStrategy.Attack _ ->
                    shotTypeGenerator
                        |> Random.map FightStrategy.Attack

                FightStrategy.AttackRandomly ->
                    Random.constant FightStrategy.AttackRandomly

                FightStrategy.Heal _ ->
                    healingItemKindGenerator
                        |> Random.map FightStrategy.Heal

                FightStrategy.MoveForward ->
                    Random.constant FightStrategy.MoveForward

                FightStrategy.SkipTurn ->
                    Random.constant FightStrategy.SkipTurn

                FightStrategy.DoWhatever ->
                    Random.constant FightStrategy.DoWhatever

        mutateCondition : FightStrategy.Condition -> Generator FightStrategy.Condition
        mutateCondition cond =
            Random.uniform conditionGenerator
                [ mutateConditionDetails cond ]
                |> Random.andThen identity

        mutateConditionDetails : FightStrategy.Condition -> Generator FightStrategy.Condition
        mutateConditionDetails cond =
            case cond of
                FightStrategy.Or c1 c2 ->
                    Random.uniform
                        (mutateCondition c1 |> Random.map (\newC1 -> FightStrategy.Or newC1 c2))
                        [ mutateCondition c2 |> Random.map (\newC2 -> FightStrategy.Or c1 newC2) ]
                        |> Random.andThen identity

                FightStrategy.And c1 c2 ->
                    Random.uniform
                        (mutateCondition c1 |> Random.map (\newC1 -> FightStrategy.And newC1 c2))
                        [ mutateCondition c2 |> Random.map (\newC2 -> FightStrategy.And c1 newC2) ]
                        |> Random.andThen identity

                FightStrategy.Operator _ ->
                    -- TODO tweak the value, op, number. I can't be bothered right now
                    Random.constant cond

                FightStrategy.OpponentIsPlayer ->
                    Random.constant cond

                FightStrategy.OpponentIsNPC ->
                    Random.constant cond
    in
    case str of
        FightStrategy.Command cmd ->
            mutateCommand cmd
                |> Random.map FightStrategy.Command

        FightStrategy.If ifData ->
            Random.uniform
                (mutateCondition ifData.condition |> Random.map (\newCondiiton -> FightStrategy.If { ifData | condition = newCondiiton }))
                [ Random.constant ifData.then_
                , Random.constant ifData.else_
                , mutateFightStrategy ifData.then_ |> Random.map (\newThen -> FightStrategy.If { ifData | then_ = newThen })
                , mutateFightStrategy ifData.else_ |> Random.map (\newElse -> FightStrategy.If { ifData | else_ = newElse })
                ]
                |> Random.andThen identity
