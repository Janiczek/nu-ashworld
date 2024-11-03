module Data.NewChar exposing
    ( CreationError(..)
    , NewChar
    , codec
    , decSpecial
    , dismissError
    , error
    , incSpecial
    , init
    , setError
    , toggleTaggedSkill
    , toggleTrait
    )

import Codec exposing (Codec)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Logic
import SeqSet exposing (SeqSet)
import SeqSet.Extra as SeqSet


type alias NewChar =
    { -- doesn't contain bonuses from traits
      baseSpecial : Special
    , availableSpecial : Int
    , taggedSkills : SeqSet Skill
    , traits : SeqSet Trait
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
    , availableSpecial = Logic.newCharAvailableSpecialPoints
    , taggedSkills = SeqSet.empty
    , traits = SeqSet.empty
    , error = Nothing
    }


incSpecial : Special.Type -> NewChar -> NewChar
incSpecial type_ char =
    let
        specialAfterTraits : Special
        specialAfterTraits =
            Logic.newCharSpecial
                { baseSpecial = char.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser char.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted char.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame char.traits
                }
    in
    if Special.canIncrement char.availableSpecial type_ specialAfterTraits then
        { char
            | baseSpecial = Special.increment type_ char.baseSpecial
            , availableSpecial = char.availableSpecial - 1
        }

    else
        char


decSpecial : Special.Type -> NewChar -> NewChar
decSpecial type_ char =
    let
        specialAfterTraits : Special
        specialAfterTraits =
            Logic.newCharSpecial
                { baseSpecial = char.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser char.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted char.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame char.traits
                }
    in
    if Special.canDecrement type_ specialAfterTraits then
        { char
            | baseSpecial = Special.decrementNewChar type_ char.baseSpecial
            , availableSpecial = char.availableSpecial + 1
        }

    else
        char


toggleTaggedSkill : Skill -> NewChar -> NewChar
toggleTaggedSkill skill char =
    let
        newTaggedSkills =
            SeqSet.toggle skill char.taggedSkills
    in
    if SeqSet.size newTaggedSkills > Logic.newCharMaxTaggedSkills then
        char

    else
        { char | taggedSkills = newTaggedSkills }


toggleTrait : Trait -> NewChar -> NewChar
toggleTrait trait char =
    let
        newTraits =
            SeqSet.toggle trait char.traits
    in
    if SeqSet.size newTraits > 2 then
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


codec : Codec NewChar
codec =
    Codec.object NewChar
        |> Codec.field "baseSpecial" .baseSpecial Special.codec
        |> Codec.field "availableSpecial" .availableSpecial Codec.int
        |> Codec.field "taggedSkills" .taggedSkills (SeqSet.codec Skill.codec)
        |> Codec.field "traits" .traits (SeqSet.codec Trait.codec)
        |> Codec.field "error" .error (Codec.nullable creationErrorCodec)
        |> Codec.buildObject


creationErrorCodec : Codec CreationError
creationErrorCodec =
    Codec.custom
        (\doesNotHaveThreeTaggedSkillsEncoder hasSpecialPointsLeftEncoder usedMoreSpecialPointsThanAvailableEncoder hasSpecialOutOfRangeEncoder hasMoreThanTwoTraitsEncoder value ->
            case value of
                DoesNotHaveThreeTaggedSkills ->
                    doesNotHaveThreeTaggedSkillsEncoder

                HasSpecialPointsLeft ->
                    hasSpecialPointsLeftEncoder

                UsedMoreSpecialPointsThanAvailable ->
                    usedMoreSpecialPointsThanAvailableEncoder

                HasSpecialOutOfRange ->
                    hasSpecialOutOfRangeEncoder

                HasMoreThanTwoTraits ->
                    hasMoreThanTwoTraitsEncoder
        )
        |> Codec.variant0 "DoesNotHaveThreeTaggedSkills" DoesNotHaveThreeTaggedSkills
        |> Codec.variant0 "HasSpecialPointsLeft" HasSpecialPointsLeft
        |> Codec.variant0 "UsedMoreSpecialPointsThanAvailable" UsedMoreSpecialPointsThanAvailable
        |> Codec.variant0 "HasSpecialOutOfRange" HasSpecialOutOfRange
        |> Codec.variant0 "HasMoreThanTwoTraits" HasMoreThanTwoTraits
        |> Codec.buildCustom
