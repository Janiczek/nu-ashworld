module Data.Fight.View exposing (view)

import Data.Enemy as Enemy
import Data.Fight as Fight exposing (Action, OpponentType, Who(..))
import Data.Fight.ShotType as ShotType exposing (AimedShot, ShotType(..))
import Data.Item as Item
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special.Perception as Perception exposing (PerceptionLevel)
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


view : PerceptionLevel -> Fight.Info -> PlayerName -> Html msg
view perceptionLevel fight yourName =
    let
        attackerName : String
        attackerName =
            Fight.opponentName fight.attacker

        targetName : String
        targetName =
            Fight.opponentName fight.target

        youAreAttacker : Bool
        youAreAttacker =
            attackerName == yourName

        you : Who
        you =
            if youAreAttacker then
                Attacker

            else
                Target

        yourOpponentName : String
        yourOpponentName =
            if youAreAttacker then
                targetName

            else
                attackerName

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
                    { name = targetName
                    , nameCap = targetName
                    , namePossCap = normalPoss targetName
                    , verbPresent = addS
                    }

                AttackerVerbatim ->
                    { name = attackerName
                    , nameCap = attackerName
                    , namePossCap = normalPoss attackerName
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

        aimedShotName : Who -> AimedShot -> String
        aimedShotName who aimedShot =
            let
                opponentType : OpponentType
                opponentType =
                    case who of
                        Fight.Attacker ->
                            fight.attacker

                        Fight.Target ->
                            fight.target
            in
            case opponentType of
                Fight.Player _ ->
                    Enemy.humanAimedShotName aimedShot

                Fight.Npc enemyType ->
                    Enemy.aimedShotName enemyType aimedShot
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

                        other : Who
                        other =
                            Fight.theOther who
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
                                                Fight.Start { distanceHexes } ->
                                                    if Perception.atLeast Perception.Great perceptionLevel then
                                                        names_.subject.verbPresent "initiate"
                                                            ++ " the fight from "
                                                            ++ String.fromInt distanceHexes
                                                            ++ " hexes away."

                                                    else
                                                        names_.subject.verbPresent "initiate"
                                                            ++ " the fight."

                                                Fight.ComeCloser { hexes, remainingDistanceHexes } ->
                                                    if Perception.atLeast Perception.Great perceptionLevel then
                                                        names_.subject.verbPresent "come"
                                                            ++ " closer "
                                                            ++ String.fromInt hexes
                                                            ++ " hexes. Remaining distance: "
                                                            ++ String.fromInt remainingDistanceHexes
                                                            ++ " hexes."

                                                    else
                                                        names_.subject.verbPresent "come"
                                                            ++ " closer."

                                                Fight.Attack { damage, remainingHp, shotType, isCritical } ->
                                                    (case shotType of
                                                        NormalShot ->
                                                            ""

                                                        AimedShot aimed ->
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ aimedShotName other aimed
                                                                ++ " and "
                                                    )
                                                        ++ (if isCritical then
                                                                "critically "

                                                            else
                                                                ""
                                                           )
                                                        ++ names_.subject.verbPresent "attack"
                                                        ++ " "
                                                        ++ name names_.object.name
                                                        ++ " for "
                                                        ++ String.fromInt damage
                                                        ++ " damage."
                                                        ++ (if Perception.atLeast Perception.Great perceptionLevel then
                                                                " Remaining HP: "
                                                                    ++ String.fromInt remainingHp
                                                                    ++ "."

                                                            else
                                                                ""
                                                           )

                                                Fight.Miss { shotType } ->
                                                    (case shotType of
                                                        NormalShot ->
                                                            ""

                                                        AimedShot aimed ->
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ aimedShotName other aimed
                                                                ++ " and "
                                                    )
                                                        ++ names_.subject.verbPresent "attack"
                                                        ++ " "
                                                        ++ name names_.object.name
                                                        ++ " but "
                                                        ++ names_.subject.verbPresent "miss"
                                                        ++ "."

                                                Fight.Heal r ->
                                                    names_.subject.verbPresent "heal"
                                                        ++ " with "
                                                        ++ Item.name r.itemKind
                                                        ++ " for "
                                                        ++ String.fromInt r.healedHp
                                                        ++ " HP. Current HP: "
                                                        ++ String.fromInt r.newHp
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
                            Fight.AttackerWon { xpGained, capsGained, itemsGained } ->
                                if youAreAttacker then
                                    "You won! You gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."
                                        ++ (if List.isEmpty itemsGained then
                                                ""

                                            else
                                                " You also looted "
                                                    ++ String.join ", "
                                                        (List.map
                                                            (\item ->
                                                                String.fromInt item.count
                                                                    ++ "x "
                                                                    ++ Item.name item.kind
                                                            )
                                                            itemsGained
                                                        )
                                                    ++ "."
                                           )

                                else
                                    "You lost! Your attacker gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."
                                        ++ (if List.isEmpty itemsGained then
                                                ""

                                            else
                                                " They also looted "
                                                    ++ String.join ", "
                                                        (List.map
                                                            (\item ->
                                                                String.fromInt item.count
                                                                    ++ "x "
                                                                    ++ Item.name item.kind
                                                            )
                                                            itemsGained
                                                        )
                                                    ++ "."
                                           )

                            Fight.TargetWon { xpGained, capsGained, itemsGained } ->
                                if youAreAttacker then
                                    if Fight.isPlayer fight.target then
                                        "You lost! Your target gained "
                                            ++ String.fromInt xpGained
                                            ++ " XP and looted "
                                            ++ String.fromInt capsGained
                                            ++ " caps."
                                            ++ (if List.isEmpty itemsGained then
                                                    ""

                                                else
                                                    " They also looted "
                                                        ++ String.join ", "
                                                            (List.map
                                                                (\item ->
                                                                    String.fromInt item.count
                                                                        ++ "x "
                                                                        ++ Item.name item.kind
                                                                )
                                                                itemsGained
                                                            )
                                                        ++ "."
                                               )

                                    else
                                        "You lost!"

                                else
                                    "You won! You gained "
                                        ++ String.fromInt xpGained
                                        ++ " XP and looted "
                                        ++ String.fromInt capsGained
                                        ++ " caps."
                                        ++ (if List.isEmpty itemsGained then
                                                ""

                                            else
                                                " You also looted "
                                                    ++ String.join ", "
                                                        (List.map
                                                            (\item ->
                                                                String.fromInt item.count
                                                                    ++ "x "
                                                                    ++ Item.name item.kind
                                                            )
                                                            itemsGained
                                                        )
                                                    ++ "."
                                           )

                            Fight.TargetAlreadyDead ->
                                if youAreAttacker then
                                    "You wanted to fight them but then realized they're already dead. You feel slightly dumb. (Higher Perception will help you see more info about your opponents.)"

                                else
                                    attackerName ++ " wanted to fight you but due to their low Perception didn't realize you're already dead. Ashamed, they quickly ran away and will deny this ever happened."

                            Fight.BothDead ->
                                "You both end up dead."

                            Fight.NobodyDead ->
                                "You both get out of the fight alive."
                       )
            ]
        , H.p [] [ H.text "Stats:" ]
        , let
            ( yourActions, theirActions ) =
                List.partition (\( who, _ ) -> who == you) fight.log

            processBoth : (val -> val -> val) -> val -> (Action -> val) -> ( val, val )
            processBoth combine init fromAction =
                ( yourActions |> List.foldl (\( _, action ) acc -> combine (fromAction action) acc) init
                , theirActions |> List.foldl (\( _, action ) acc -> combine (fromAction action) acc) init
                )

            ( yourTotalDamage, theirTotalDamage ) =
                processBoth (+) 0 Fight.attackDamage

            ( yourAttackCount, theirAttackCount ) =
                processBoth (+)
                    0
                    (\action ->
                        if Fight.isAttack action || Fight.isMiss action then
                            1

                        else
                            0
                    )

            ( yourLandingAttackCount, theirLandingAttackCount ) =
                processBoth (+)
                    0
                    (\action ->
                        if Fight.isAttack action then
                            1

                        else
                            0
                    )

            ( yourCritAttackCount, theirCritAttackCount ) =
                processBoth (+)
                    0
                    (\action ->
                        if Fight.isCriticalAttack action then
                            1

                        else
                            0
                    )

            ( yourMaxHit, theirMaxHit ) =
                processBoth max 0 Fight.attackDamage

            ( yourHitRate, theirHitRate ) =
                ( toFloat yourLandingAttackCount / toFloat yourAttackCount
                , toFloat theirLandingAttackCount / toFloat theirAttackCount
                )

            ( yourCritRate, theirCritRate ) =
                ( toFloat yourCritAttackCount / toFloat yourLandingAttackCount
                , toFloat theirCritAttackCount / toFloat theirLandingAttackCount
                )

            ( yourAvgDamage, theirAvgDamage ) =
                ( toFloat yourTotalDamage / toFloat yourLandingAttackCount
                , toFloat theirTotalDamage / toFloat theirLandingAttackCount
                )

            formatFloat : Float -> String
            formatFloat n =
                if isNaN n then
                    formatFloat 0

                else
                    String.fromFloat <| (\x -> x / 100) <| toFloat <| round <| n * 100

            formatPercentage : Float -> String
            formatPercentage pct =
                if isNaN pct then
                    formatPercentage 0

                else
                    (String.fromFloat <| (\x -> x / 100) <| toFloat <| round <| pct * 10000) ++ "%"
          in
          H.table [ HA.id "fight-stats-table" ]
            [ H.thead []
                [ H.tr []
                    [ H.td [] []
                    , H.th [] [ H.text "You" ]
                    , H.th [] [ H.text yourOpponentName ]
                    ]
                ]
            , H.tbody []
                [ H.tr []
                    [ H.td [] [ H.text "Total damage" ]
                    , H.td [] [ H.text <| String.fromInt yourTotalDamage ]
                    , H.td [] [ H.text <| String.fromInt theirTotalDamage ]
                    ]
                , H.tr []
                    [ H.td [] [ H.text "Hit rate" ]
                    , H.td [] [ H.text <| formatPercentage yourHitRate ]
                    , H.td [] [ H.text <| formatPercentage theirHitRate ]
                    ]
                , H.tr []
                    [ H.td [] [ H.text "Critical hit rate" ]
                    , H.td [] [ H.text <| formatPercentage yourCritRate ]
                    , H.td [] [ H.text <| formatPercentage theirCritRate ]
                    ]
                , H.tr []
                    [ H.td [] [ H.text "Average damage" ]
                    , H.td [] [ H.text <| formatFloat yourAvgDamage ]
                    , H.td [] [ H.text <| formatFloat theirAvgDamage ]
                    ]
                , H.tr []
                    [ H.td [] [ H.text "Max hit" ]
                    , H.td [] [ H.text <| String.fromInt yourMaxHit ]
                    , H.td [] [ H.text <| String.fromInt theirMaxHit ]
                    ]
                ]
            ]
        ]
