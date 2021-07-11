module Evergreen.V102.Frontend.HoveredItem exposing (..)

import Evergreen.V102.Data.FightStrategy.Help
import Evergreen.V102.Data.Perk
import Evergreen.V102.Data.Skill
import Evergreen.V102.Data.Special
import Evergreen.V102.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V102.Data.Perk.Perk
    | HoveredTrait Evergreen.V102.Data.Trait.Trait
    | HoveredSpecial Evergreen.V102.Data.Special.Type
    | HoveredSkill Evergreen.V102.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V102.Data.FightStrategy.Help.Reference
