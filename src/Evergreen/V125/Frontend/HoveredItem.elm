module Evergreen.V125.Frontend.HoveredItem exposing (..)

import Evergreen.V125.Data.FightStrategy.Help
import Evergreen.V125.Data.Perk
import Evergreen.V125.Data.Skill
import Evergreen.V125.Data.Special
import Evergreen.V125.Data.Special.Perception
import Evergreen.V125.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V125.Data.Perk.Perk
    | HoveredTrait Evergreen.V125.Data.Trait.Trait
    | HoveredSpecial Evergreen.V125.Data.Special.Type
    | HoveredSkill Evergreen.V125.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V125.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V125.Data.Special.Perception.PerceptionLevel
