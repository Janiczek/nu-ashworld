module Frontend.HoveredItem exposing (HoveredItem(..), text)

import Data.FightStrategy.Help as FightStrategyHelp
import Data.Perk as Perk exposing (Perk)
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
            , description = Perk.description perk
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
