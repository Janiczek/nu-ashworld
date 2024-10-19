module Evergreen.V105.Frontend.HoveredItem exposing (..)

import Evergreen.V105.Data.FightStrategy.Help
import Evergreen.V105.Data.Perk
import Evergreen.V105.Data.Skill
import Evergreen.V105.Data.Special
import Evergreen.V105.Data.Special.Perception
import Evergreen.V105.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V105.Data.Perk.Perk
    | HoveredTrait Evergreen.V105.Data.Trait.Trait
    | HoveredSpecial Evergreen.V105.Data.Special.Type
    | HoveredSkill Evergreen.V105.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V105.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V105.Data.Special.Perception.PerceptionLevel
