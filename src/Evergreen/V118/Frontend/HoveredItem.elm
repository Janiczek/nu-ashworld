module Evergreen.V118.Frontend.HoveredItem exposing (..)

import Evergreen.V118.Data.FightStrategy.Help
import Evergreen.V118.Data.Perk
import Evergreen.V118.Data.Skill
import Evergreen.V118.Data.Special
import Evergreen.V118.Data.Special.Perception
import Evergreen.V118.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V118.Data.Perk.Perk
    | HoveredTrait Evergreen.V118.Data.Trait.Trait
    | HoveredSpecial Evergreen.V118.Data.Special.Type
    | HoveredSkill Evergreen.V118.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V118.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V118.Data.Special.Perception.PerceptionLevel
