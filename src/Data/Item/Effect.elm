module Data.Item.Effect exposing (Effect(..), getHealing, isHealing)

import Data.Skill exposing (Skill)


type Effect
    = Heal { min : Int, max : Int }
    | RemoveAfterUse
    | BookRemoveTicks
    | BookAddSkillPercent Skill


isHealing : Effect -> Bool
isHealing effect =
    getHealing effect /= Nothing


getHealing : Effect -> Maybe { min : Int, max : Int }
getHealing effect =
    case effect of
        Heal r ->
            Just r

        RemoveAfterUse ->
            Nothing

        BookRemoveTicks ->
            Nothing

        BookAddSkillPercent _ ->
            Nothing
