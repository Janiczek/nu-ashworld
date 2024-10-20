module Evergreen.V108.Frontend.HoveredItem exposing (..)

import Evergreen.V108.Data.FightStrategy.Help
import Evergreen.V108.Data.Perk
import Evergreen.V108.Data.Skill
import Evergreen.V108.Data.Special
import Evergreen.V108.Data.Special.Perception
import Evergreen.V108.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V108.Data.Perk.Perk
    | HoveredTrait Evergreen.V108.Data.Trait.Trait
    | HoveredSpecial Evergreen.V108.Data.Special.Type
    | HoveredSkill Evergreen.V108.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V108.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V108.Data.Special.Perception.PerceptionLevel
