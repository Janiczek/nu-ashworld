module Calculator.Meta.Individual exposing (Individual, generator)

import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.FightStrategy as FightStrategy exposing (FightStrategy)
import Data.Item as Item
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import List.Extra
import Logic
import Random
import Random.List
import SeqSet exposing (SeqSet)


type alias Individual =
    { special : Special
    , traits : SeqSet Trait
    , taggedSkills : SeqSet Skill
    , fightStrategy : FightStrategy
    }


generator : Random.Generator Individual
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


fightStrategyGenerator : Random.Generator FightStrategy
fightStrategyGenerator =
    let
        maxDepth : Int
        maxDepth =
            3

        commandGen : Random.Generator FightStrategy.Command
        commandGen =
            Random.uniform
                (Random.map FightStrategy.Attack shotTypeGen)
                [ Random.constant FightStrategy.AttackRandomly
                , Random.map FightStrategy.Heal healingItemKindGen
                , Random.constant FightStrategy.MoveForward
                , Random.constant FightStrategy.DoWhatever
                ]
                |> Random.andThen identity

        shotTypeGen : Random.Generator ShotType
        shotTypeGen =
            Random.uniform ShotType.NormalShot
                (List.map ShotType.AimedShot ShotType.allAimed)

        healingItemKindGen : Random.Generator Item.Kind
        healingItemKindGen =
            let
                ( x, xs ) =
                    Item.allHealingNonempty
            in
            Random.uniform x xs

        conditionGen : Random.Generator FightStrategy.Condition
        conditionGen =
            Random.uniform
                (FightStrategy.Operator
                    { value = FightStrategy.MyHP
                    , op = FightStrategy.LT_
                    , number_ = 50
                    }
                )
                [ FightStrategy.OpponentIsPlayer
                , FightStrategy.OpponentIsNPC
                ]

        strategyGen : Int -> Random.Generator FightStrategy
        strategyGen depth =
            if depth >= maxDepth then
                Random.map FightStrategy.Command commandGen

            else
                Random.uniform
                    (Random.map FightStrategy.Command commandGen)
                    [ Random.map3
                        (\condition thenStrategy elseStrategy ->
                            FightStrategy.If
                                { condition = condition
                                , then_ = thenStrategy
                                , else_ = elseStrategy
                                }
                        )
                        conditionGen
                        (strategyGen (depth + 1))
                        (strategyGen (depth + 1))
                    ]
                    |> Random.andThen identity
    in
    strategyGen 0
        |> Random.map moveForwardIfNeeded


moveForwardIfNeeded : FightStrategy -> FightStrategy
moveForwardIfNeeded strategy =
    FightStrategy.If
        { condition =
            FightStrategy.Operator
                { value = FightStrategy.Distance
                , op = FightStrategy.GT_
                , number_ = 0
                }
        , then_ = FightStrategy.Command FightStrategy.MoveForward
        , else_ = strategy
        }


specialGenerator : Special -> Random.Generator Special
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


traitsGenerator : Random.Generator (SeqSet Trait)
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


skillsGenerator : Random.Generator (SeqSet Skill)
skillsGenerator =
    Skill.all
        |> Random.List.choices Logic.newCharMaxTaggedSkills
        |> Random.map (Tuple.first >> SeqSet.fromList)
