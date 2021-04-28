module Data.NewChar exposing
    ( CreationError(..)
    , NewChar
    , decSpecial
    , dismissError
    , encode
    , error
    , incSpecial
    , init
    , setError
    , toggleTaggedSkill
    , toggleTrait
    )

import AssocSet as Set_
import AssocSet.Extra as Set_
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special, SpecialType)
import Data.Trait as Trait exposing (Trait)
import Json.Encode as JE
import Json.Encode.Extra as JE
import Logic


type alias NewChar =
    { -- doesn't contain bonuses from traits
      baseSpecial : Special
    , availableSpecial : Int
    , taggedSkills : Set_.Set Skill
    , traits : Set_.Set Trait
    , error : Maybe CreationError
    }


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


init : NewChar
init =
    { baseSpecial = Special.init
    , availableSpecial = 5
    , taggedSkills = Set_.empty
    , traits = Set_.empty
    , error = Nothing
    }


incSpecial : SpecialType -> NewChar -> NewChar
incSpecial type_ char =
    let
        specialAfterTraits : Special
        specialAfterTraits =
            Logic.special
                { baseSpecial = char.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser char.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted char.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame char.traits
                , isNewChar = True
                }
    in
    if Special.canIncrement char.availableSpecial type_ specialAfterTraits then
        { char
            | baseSpecial = Special.increment type_ char.baseSpecial
            , availableSpecial = char.availableSpecial - 1
        }

    else
        char


decSpecial : SpecialType -> NewChar -> NewChar
decSpecial type_ char =
    let
        specialAfterTraits : Special
        specialAfterTraits =
            Logic.special
                { baseSpecial = char.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser char.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted char.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame char.traits
                , isNewChar = True
                }
    in
    if Special.canDecrement type_ specialAfterTraits then
        { char
            | baseSpecial = Special.decrement type_ char.baseSpecial
            , availableSpecial = char.availableSpecial + 1
        }

    else
        char


toggleTaggedSkill : Skill -> NewChar -> NewChar
toggleTaggedSkill skill char =
    let
        newTaggedSkills =
            Set_.toggle skill char.taggedSkills
    in
    if Set_.size newTaggedSkills > 3 then
        char

    else
        { char | taggedSkills = newTaggedSkills }


toggleTrait : Trait -> NewChar -> NewChar
toggleTrait trait char =
    let
        newTraits =
            Set_.toggle trait char.traits
    in
    if Set_.size newTraits > 2 then
        char

    else
        { char | traits = newTraits }


error : CreationError -> String
error err =
    case err of
        DoesNotHaveThreeTaggedSkills ->
            "You need to tag three skills."

        HasSpecialPointsLeft ->
            "You need to distribute all your SPECIAL points."

        UsedMoreSpecialPointsThanAvailable ->
            "[Possible cheater] You used more SPECIAL points than were available to you."

        HasSpecialOutOfRange ->
            "Your SPECIAL attributes need to be in the 1..10 range."

        HasMoreThanTwoTraits ->
            "You can only select up to two traits."


setError : CreationError -> NewChar -> NewChar
setError error_ char =
    { char | error = Just error_ }


dismissError : NewChar -> NewChar
dismissError char =
    { char | error = Nothing }


encode : NewChar -> JE.Value
encode newChar =
    JE.object
        [ ( "baseSpecial", Special.encode newChar.baseSpecial )
        , ( "availableSpecial", JE.int newChar.availableSpecial )
        , ( "taggedSkills", Set_.encode Skill.encode newChar.taggedSkills )
        , ( "traits", Set_.encode Trait.encode newChar.traits )
        , ( "error", JE.maybe encodeCreationError newChar.error )
        ]


encodeCreationError : CreationError -> JE.Value
encodeCreationError err =
    JE.string <|
        case err of
            DoesNotHaveThreeTaggedSkills ->
                "DoesNotHaveThreeTaggedSkills"

            HasSpecialPointsLeft ->
                "HasSpecialPointsLeft"

            UsedMoreSpecialPointsThanAvailable ->
                "UsedMoreSpecialPointsThanAvailable"

            HasSpecialOutOfRange ->
                "HasSpecialOutOfRange"

            HasMoreThanTwoTraits ->
                "HasMoreThanTwoTraits"
