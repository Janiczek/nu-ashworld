module Data.Fight.View exposing (view)

import Data.Fight
    exposing
        ( FightAction(..)
        , FightInfo
        , FightResult(..)
        , Who(..)
        )
import Data.Fight.ShotType as ShotType exposing (ShotType(..))
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special.Perception as Perception
import Html as H exposing (Html)
import Html.Attributes as HA
import List.Extra
import Markdown
import Set exposing (Set)


type Name
    = You
    | AttackerVerbatim
    | TargetVerbatim


type alias Names =
    -- cap = Capitalized
    -- poss = Possessive
    -- verbPresent = the '-s' or '-es' suffix in "player initiates" VS "you initiate", or "player misses" vs "you miss"
    { name : String
    , nameCap : String
    , namePossCap : String
    , verbPresent : String -> String
    }


esWords : Set String
esWords =
    Set.fromList [ "miss" ]


normalPoss : String -> String
normalPoss name =
    name ++ "'s"


addS : String -> String
addS verb =
    if Set.member verb esWords then
        verb ++ "es"

    else
        verb ++ "s"


view : Int -> FightInfo -> PlayerName -> Html msg
view perception fight yourName =
    let
        youAreAttacker : Bool
        youAreAttacker =
            fight.attackerName == yourName

        names : Name -> Names
        names name =
            case name of
                You ->
                    { name = "you"
                    , nameCap = "You"
                    , namePossCap = "Your"
                    , verbPresent = identity
                    }

                TargetVerbatim ->
                    { name = fight.targetName
                    , nameCap = fight.targetName
                    , namePossCap = normalPoss fight.targetName
                    , verbPresent = addS
                    }

                AttackerVerbatim ->
                    { name = fight.attackerName
                    , nameCap = fight.attackerName
                    , namePossCap = normalPoss fight.attackerName
                    , verbPresent = addS
                    }

        getNames : Who -> { subject : Names, object : Names }
        getNames who =
            case ( who, youAreAttacker ) of
                ( Attacker, True ) ->
                    { subject = names You
                    , object = names TargetVerbatim
                    }

                ( Attacker, False ) ->
                    { subject = names AttackerVerbatim
                    , object = names You
                    }

                ( Target, True ) ->
                    { subject = names TargetVerbatim
                    , object = names You
                    }

                ( Target, False ) ->
                    { subject = names You
                    , object = names AttackerVerbatim
                    }
    in
    H.div [ HA.class "fight-info" ]
        [ fight.log
            |> List.Extra.groupWhile (\( a, _ ) ( b, _ ) -> a == b)
            |> List.map
                (\( ( who, _ ) as first, rest ) ->
                    let
                        names_ : { subject : Names, object : Names }
                        names_ =
                            getNames who

                        name : String -> String
                        name n =
                            -- This is then picked up by the CSS
                            "**" ++ n ++ "**"
                    in
                    H.li []
                        [ H.text <| names_.subject.namePossCap ++ " turn"
                        , (first :: rest)
                            |> List.map
                                (\( _, action ) ->
                                    let
                                        action_ : String
                                        action_ =
                                            case action of
                                                Start { distanceHexes } ->
                                                    if Perception.atLeast Perception.Great perception then
                                                        names_.subject.verbPresent "initiate"
                                                            ++ " the fight from "
                                                            ++ String.fromInt distanceHexes
                                                            ++ " hexes away."

                                                    else
                                                        names_.subject.verbPresent "initiate"
                                                            ++ " the fight."

                                                ComeCloser { hexes, remainingDistanceHexes } ->
                                                    if Perception.atLeast Perception.Great perception then
                                                        names_.subject.verbPresent "come"
                                                            ++ " closer "
                                                            ++ String.fromInt hexes
                                                            ++ " hexes. Remaining distance: "
                                                            ++ String.fromInt remainingDistanceHexes
                                                            ++ " hexes."

                                                    else
                                                        names_.subject.verbPresent "come"
                                                            ++ " closer."

                                                Attack { damage, remainingHp, shotType } ->
                                                    (case shotType of
                                                        NormalShot ->
                                                            ""

                                                        AimedShot aimed ->
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ ShotType.label aimed
                                                                ++ " and "
                                                    )
                                                        ++ names_.subject.verbPresent "attack"
                                                        ++ " "
                                                        ++ name names_.object.name
                                                        ++ " for "
                                                        ++ String.fromInt damage
                                                        ++ " damage."
                                                        ++ (if Perception.atLeast Perception.Great perception then
                                                                " Remaining HP: "
                                                                    ++ String.fromInt remainingHp
                                                                    ++ "."

                                                            else
                                                                ""
                                                           )

                                                Miss { shotType } ->
                                                    (case shotType of
                                                        NormalShot ->
                                                            ""

                                                        AimedShot aimed ->
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ ShotType.label aimed
                                                                ++ " and "
                                                    )
                                                        ++ names_.subject.verbPresent "attack"
                                                        ++ " "
                                                        ++ name names_.object.name
                                                        ++ " but "
                                                        ++ names_.subject.verbPresent "miss"
                                                        ++ "."
                                    in
                                    H.li []
                                        [ Markdown.toHtml [ HA.class "fight-log-action" ] <|
                                            name names_.subject.nameCap
                                                ++ " "
                                                ++ action_
                                        ]
                                )
                            |> H.ul []
                        ]
                )
            |> H.ul []
        , H.div []
            [ H.text <|
                "Result: "
                    ++ (case fight.result of
                            AttackerWon { xpGained, capsGained } ->
                                if youAreAttacker then
                                    "You won! You gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."

                                else
                                    "You lost! Your attacker gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."

                            TargetWon { xpGained, capsGained } ->
                                if youAreAttacker then
                                    "You lost! Your target gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."

                                else
                                    "You won! You gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."

                            TargetAlreadyDead ->
                                if youAreAttacker then
                                    "You wanted to fight them but then realized they're already dead. You feel slightly dumb. (Higher Perception will help you see more info about your opponents.)"

                                else
                                    fight.attackerName ++ " wanted to fight you but due to their low Perception didn't realize you're already dead. Ashamed, they quickly ran away and will deny this ever happened."

                            BothDead ->
                                "You both end up dead."

                            NobodyDead ->
                                "You both get out of the fight alive."
                       )
            ]
        ]
