module Evergreen.V109.Frontend.HoveredItem exposing (..)

import Evergreen.V109.Data.FightStrategy.Help
import Evergreen.V109.Data.Perk
import Evergreen.V109.Data.Skill
import Evergreen.V109.Data.Special
import Evergreen.V109.Data.Special.Perception
import Evergreen.V109.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V109.Data.Perk.Perk
    | HoveredTrait Evergreen.V109.Data.Trait.Trait
    | HoveredSpecial Evergreen.V109.Data.Special.Type
    | HoveredSkill Evergreen.V109.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V109.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V109.Data.Special.Perception.PerceptionLevel
