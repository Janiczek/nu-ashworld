module Frontend.HoveredItem exposing (HoveredItem(..), text)

import Data.FightStrategy.Help as FightStrategyHelp
import Data.Perk as Perk exposing (Perk)
import Data.Perk.Requirement as PerkRequirement
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Trait as Trait exposing (Trait)


type HoveredItem
    = HoveredPerk Perk
    | HoveredTrait Trait
    | HoveredSpecial Special.Type
    | HoveredSkill Skill
    | HoveredFightStrategyReference FightStrategyHelp.Reference
    | HoveredPerceptionLevel PerceptionLevel


text : HoveredItem -> { title : String, description : String }
text hoveredItem =
    case hoveredItem of
        HoveredPerk perk ->
            { title = Perk.name perk
            , description =
                [ Perk.description perk
                , "Max rank: " ++ String.fromInt (Perk.maxRank perk)
                , "Requirements:"
                , PerkRequirement.requirements perk
                    |> List.map (\req -> "- " ++ requirementText req)
                    |> String.join "\n"
                ]
                    |> String.join "\n\n"
            }

        HoveredTrait trait ->
            { title = Trait.name trait
            , description = Trait.description trait
            }

        HoveredSpecial specialType ->
            { title = Special.label specialType
            , description = Special.description specialType
            }

        HoveredSkill skill ->
            { title = Skill.name skill
            , description =
                Skill.description skill
                    ++ (if Skill.isUseful skill then
                            ""

                        else
                            "\n\nThis skill is not useful in the game yet."
                       )
            }

        HoveredFightStrategyReference reference ->
            { title = FightStrategyHelp.referenceTitle reference
            , description = FightStrategyHelp.referenceDescription reference
            }

        HoveredPerceptionLevel perceptionLevel ->
            { title = "Perception Level: " ++ Perception.label perceptionLevel
            , description = Perception.tooltip perceptionLevel
            }


requirementText : PerkRequirement.Requirement -> String
requirementText req =
    case req of
        PerkRequirement.ROneOf reqs ->
            "One of:\n"
                ++ (List.map requirementText reqs
                        |> List.map (\req_ -> "  - " ++ req_)
                        |> String.join "\n"
                   )

        PerkRequirement.RLevel lvl ->
            "Level " ++ String.fromInt lvl

        PerkRequirement.RSpecial special n ->
            Special.label special ++ " " ++ String.fromInt n

        PerkRequirement.RSpecialLT special n ->
            Special.label special ++ " < " ++ String.fromInt n

        PerkRequirement.RSkill skill n ->
            Skill.name skill ++ ": " ++ String.fromInt n ++ "%"

        PerkRequirement.RQuest quest ->
            "Quest: " ++ Quest.title quest
