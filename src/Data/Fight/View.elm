module Data.Fight.View exposing (view)

import Data.Enemy as Enemy
import Data.Fight as Fight exposing (Action, CommandRejectionReason(..), Who(..))
import Data.Fight.AimedShot exposing (AimedShot)
import Data.Fight.AttackStyle exposing (AttackStyle(..))
import Data.Fight.Critical as Critical
import Data.Fight.OpponentType as OpponentType exposing (OpponentType)
import Data.Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Extra as H
import List.Extra
import Set exposing (Set)
import UI


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
    , be : String
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


viewLoot : List Item -> String
viewLoot itemsGained =
    String.join ", "
        (List.map
            (\item ->
                String.fromInt item.count
                    ++ "x "
                    ++ ItemKind.name item.kind
            )
            itemsGained
        )


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
                    , be = "are"
                    }

                TargetVerbatim ->
                    { name = targetName
                    , nameCap = targetName
                    , namePossCap = normalPoss targetName
                    , verbPresent = addS
                    , be = "is"
                    }

                AttackerVerbatim ->
                    { name = attackerName
                    , nameCap = attackerName
                    , namePossCap = normalPoss attackerName
                    , verbPresent = addS
                    , be = "is"
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
                OpponentType.Player _ ->
                    Enemy.humanAimedShotName aimedShot

                OpponentType.Npc enemyType ->
                    Enemy.aimedShotName enemyType aimedShot
    in
    H.div [ HA.class "flex flex-col gap-4" ]
        [ if fight.attackerEquipment /= Nothing || fight.targetEquipment /= Nothing then
            let
                yourEquipment =
                    if youAreAttacker then
                        fight.attackerEquipment

                    else
                        fight.targetEquipment

                theirEquipment =
                    if youAreAttacker then
                        fight.targetEquipment

                    else
                        fight.attackerEquipment

                itemName : Maybe ItemKind.Kind -> ( String, String )
                itemName maybeKind =
                    case maybeKind of
                        Nothing ->
                            ( "text-green-300", "None" )

                        Just kind ->
                            ( "text-green-100", ItemKind.name kind )

                equipmentName : (Fight.Equipment -> Maybe ItemKind.Kind) -> Maybe Fight.Equipment -> ( String, String )
                equipmentName getter maybeEquipment =
                    case maybeEquipment of
                        Nothing ->
                            ( "text-green-300", "?" )

                        Just e ->
                            e |> getter |> itemName
            in
            [ ( "Your weapon", equipmentName .weapon yourEquipment )
            , ( "Your armor", equipmentName .armor yourEquipment )
            , ( "Their weapon", equipmentName .weapon theirEquipment )
            , ( "Their armor", equipmentName .armor theirEquipment )
            ]
                |> List.map
                    (\( label, ( color, content ) ) ->
                        H.li []
                            [ H.span [ HA.class "text-green-300" ] [ H.text <| label ++ ": " ]
                            , H.span [ HA.class color ] [ H.text content ]
                            ]
                    )
                |> UI.ul []

          else
            H.nothing
        , fight.log
            |> List.Extra.groupWhile (\( a, _ ) ( b, _ ) -> a == b)
            |> List.map
                (\( ( who, _ ) as first, rest ) ->
                    let
                        names_ : { subject : Names, object : Names }
                        names_ =
                            getNames who

                        highlight : String -> Html msg
                        highlight n =
                            H.span
                                [ HA.class "text-yellow" ]
                                [ H.text n ]

                        other : Who
                        other =
                            Fight.theOther who
                    in
                    H.li []
                        [ H.span
                            [ HA.class "text-green-300" ]
                            [ H.text <| names_.subject.namePossCap ++ " turn" ]
                        , (first :: rest)
                            |> List.map
                                (\( currentActionWho, action ) ->
                                    let
                                        action_ : Html msg
                                        action_ =
                                            case action of
                                                Fight.Start { distanceHexes } ->
                                                    if Perception.atLeast Perception.Great perceptionLevel then
                                                        H.span []
                                                            [ H.text <|
                                                                names_.subject.verbPresent "initiate"
                                                                    ++ " the fight from "
                                                            , highlight <| String.fromInt distanceHexes
                                                            , H.text " hexes away."
                                                            ]

                                                    else
                                                        H.text <|
                                                            names_.subject.verbPresent "initiate"
                                                                ++ " the fight."

                                                Fight.ComeCloser { hexes, remainingDistanceHexes } ->
                                                    if Perception.atLeast Perception.Great perceptionLevel then
                                                        H.span []
                                                            [ H.text <|
                                                                names_.subject.verbPresent "come"
                                                                    ++ " closer "
                                                            , highlight <| String.fromInt hexes
                                                            , H.text " hexes. Remaining distance: "
                                                            , highlight <| String.fromInt remainingDistanceHexes
                                                            , H.text " hexes."
                                                            ]

                                                    else
                                                        H.text <|
                                                            names_.subject.verbPresent "come"
                                                                ++ " closer."

                                                Fight.RunAway { hexes, remainingDistanceHexes } ->
                                                    if Perception.atLeast Perception.Great perceptionLevel then
                                                        H.span []
                                                            [ H.text <|
                                                                names_.subject.verbPresent "run"
                                                                    ++ " away "
                                                            , highlight <| String.fromInt hexes
                                                            , H.text " hexes. Remaining distance: "
                                                            , highlight <| String.fromInt remainingDistanceHexes
                                                            , H.text " hexes."
                                                            ]

                                                    else
                                                        H.text <|
                                                            names_.subject.verbPresent "run"
                                                                ++ " away."

                                                Fight.Attack { damage, remainingHp, attackStyle, critical } ->
                                                    let
                                                        critically =
                                                            if critical /= Nothing then
                                                                "critically "

                                                            else
                                                                ""

                                                        aimed aim =
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ aimedShotName other aim
                                                                ++ " and "
                                                    in
                                                    H.span []
                                                        [ H.text <|
                                                            (case attackStyle of
                                                                UnarmedUnaimed ->
                                                                    ""

                                                                UnarmedAimed aim ->
                                                                    aimed aim

                                                                MeleeUnaimed ->
                                                                    ""

                                                                MeleeAimed aim ->
                                                                    aimed aim

                                                                Throw ->
                                                                    ""

                                                                ShootSingleUnaimed ->
                                                                    ""

                                                                ShootSingleAimed aim ->
                                                                    aimed aim

                                                                ShootBurst ->
                                                                    ""
                                                            )
                                                                ++ critically
                                                                ++ names_.subject.verbPresent
                                                                    (case attackStyle of
                                                                        UnarmedUnaimed ->
                                                                            "attack"

                                                                        UnarmedAimed _ ->
                                                                            "attack"

                                                                        MeleeUnaimed ->
                                                                            "attack"

                                                                        MeleeAimed _ ->
                                                                            "attack"

                                                                        Throw ->
                                                                            "attack"

                                                                        ShootSingleUnaimed ->
                                                                            "shoot"

                                                                        ShootSingleAimed _ ->
                                                                            "shoot"

                                                                        ShootBurst ->
                                                                            "shoot"
                                                                    )
                                                                ++ " "
                                                        , highlight names_.object.name
                                                        , H.text " for "
                                                        , highlight <| String.fromInt damage
                                                        , H.text " damage"
                                                        , case critical of
                                                            Nothing ->
                                                                if remainingHp <= 0 then
                                                                    H.span []
                                                                        [ H.text ", resulting in "
                                                                        , H.span [ HA.class "text-yellow" ] [ H.text "death" ]
                                                                        , H.text "."
                                                                        ]

                                                                else if currentActionWho /= you || Perception.atLeast Perception.Great perceptionLevel then
                                                                    H.span []
                                                                        [ H.text ". Remaining HP: "
                                                                        , highlight <| String.fromInt remainingHp
                                                                        , H.text "."
                                                                        ]

                                                                else
                                                                    H.text "."

                                                            Just ( effects, message ) ->
                                                                H.span []
                                                                    ((H.text <|
                                                                        ", "
                                                                            ++ messageView
                                                                                { -- you're not the attacker, you're the attacked, so we want to say "and it knocks YOU over" (`itsYou` being talked about in the Message!)
                                                                                  itsYou = currentActionWho /= you
                                                                                }
                                                                                message
                                                                     )
                                                                        :: (if remainingHp <= 0 && not (List.member Critical.Death effects) then
                                                                                [ H.text " This results in "
                                                                                , H.span [ HA.class "text-yellow" ] [ H.text "death" ]
                                                                                , H.text "."
                                                                                ]

                                                                            else if currentActionWho /= you || Perception.atLeast Perception.Great perceptionLevel then
                                                                                [ H.text " Remaining HP: "
                                                                                , highlight <| String.fromInt remainingHp
                                                                                , H.text "."
                                                                                ]

                                                                            else
                                                                                []
                                                                           )
                                                                    )
                                                        ]

                                                Fight.Miss { attackStyle } ->
                                                    let
                                                        aimed aim =
                                                            names_.subject.verbPresent "aim"
                                                                ++ " for "
                                                                ++ aimedShotName other aim
                                                                ++ " and "
                                                    in
                                                    H.span []
                                                        [ H.text <|
                                                            (case attackStyle of
                                                                UnarmedUnaimed ->
                                                                    ""

                                                                UnarmedAimed aim ->
                                                                    aimed aim

                                                                MeleeUnaimed ->
                                                                    ""

                                                                MeleeAimed aim ->
                                                                    aimed aim

                                                                Throw ->
                                                                    ""

                                                                ShootSingleUnaimed ->
                                                                    ""

                                                                ShootSingleAimed aim ->
                                                                    aimed aim

                                                                ShootBurst ->
                                                                    ""
                                                            )
                                                                ++ names_.subject.verbPresent
                                                                    (case attackStyle of
                                                                        UnarmedUnaimed ->
                                                                            "attack"

                                                                        UnarmedAimed _ ->
                                                                            "attack"

                                                                        MeleeUnaimed ->
                                                                            "attack"

                                                                        MeleeAimed _ ->
                                                                            "attack"

                                                                        Throw ->
                                                                            "attack"

                                                                        ShootSingleUnaimed ->
                                                                            "shoot"

                                                                        ShootSingleAimed _ ->
                                                                            "shoot"

                                                                        ShootBurst ->
                                                                            "shoot"
                                                                    )
                                                                ++ " "
                                                        , highlight names_.object.name
                                                        , H.text <|
                                                            " but "
                                                                ++ names_.subject.verbPresent "miss"
                                                                ++ "."
                                                        ]

                                                Fight.KnockedOut ->
                                                    H.text <|
                                                        names_.subject.be
                                                            ++ " knocked out."

                                                Fight.StandUp _ ->
                                                    H.text <|
                                                        names_.subject.verbPresent "stand"
                                                            ++ " up."

                                                Fight.Heal r ->
                                                    H.text <|
                                                        names_.subject.verbPresent "heal"
                                                            ++ " with "
                                                            ++ ItemKind.name r.itemKind
                                                            ++ " for "
                                                            ++ String.fromInt r.healedHp
                                                            ++ " HP."
                                                            ++ (if currentActionWho == you || Perception.atLeast Perception.Great perceptionLevel then
                                                                    " Current HP: "
                                                                        ++ String.fromInt r.newHp
                                                                        ++ "."

                                                                else
                                                                    ""
                                                               )

                                                Fight.SkipTurn ->
                                                    H.text <|
                                                        names_.subject.verbPresent "skip"
                                                            ++ " a turn."

                                                Fight.FailToDoAnything rejectionReason ->
                                                    -- TODO make this nicer... probably reads wrong
                                                    let
                                                        ( action__, issue ) =
                                                            case rejectionReason of
                                                                Heal_AlreadyFullyHealed ->
                                                                    ( "heal", "already fully healed" )

                                                                Heal_ItemDoesNotHeal ->
                                                                    ( "heal", "the selected item does not heal" )

                                                                Heal_ItemNotPresent ->
                                                                    ( "heal", "the wanted item is not present" )

                                                                HealWithAnything_AlreadyFullyHealed ->
                                                                    ( "heal with anything", "already fully healed" )

                                                                HealWithAnything_NoHealingItem ->
                                                                    ( "heal with anything", "no healing item in inventory" )

                                                                Attack_NotCloseEnough ->
                                                                    ( "attack", "not close enough" )

                                                                Attack_NotEnoughAP ->
                                                                    ( "attack", "not enough AP" )

                                                                MoveForward_AlreadyNextToEachOther ->
                                                                    ( "move forward", "already next to each other" )
                                                    in
                                                    H.text <|
                                                        names_.subject.verbPresent "fail"
                                                            ++ " to do anything. Wanted to "
                                                            ++ action__
                                                            ++ ". Issue: "
                                                            ++ issue
                                                            ++ "."
                                    in
                                    H.li []
                                        [ highlight names_.subject.nameCap
                                        , H.text " "
                                        , action_
                                        ]
                                )
                            |> UI.ul []
                        ]
                )
            |> UI.ul [ HA.class "flex flex-col gap-4" ]
        , H.div []
            [ H.span
                [ HA.class "text-green-300" ]
                [ H.text "Result: " ]
            , H.span [ HA.class "text-green-100" ]
                [ H.text <|
                    case fight.result of
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
                                                ++ viewLoot itemsGained
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
                                                ++ viewLoot itemsGained
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
                                                    ++ viewLoot itemsGained
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
                                                ++ viewLoot itemsGained
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

                        Fight.NobodyDeadGivenUp ->
                            "You're both so exhausted by this long fight that you agree to finish this some other time."
                ]
            ]
        , H.span [ HA.class "text-green-300" ] [ H.text "Stats:" ]
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

            th attrs children =
                H.th (HA.class "text-right" :: attrs) children

            td attrs children =
                H.td (HA.class "text-right" :: attrs) children
          in
          H.table [ HA.class "w-max" ]
            [ H.thead []
                [ H.tr []
                    [ td [] []
                    , th [] [ H.text "You" ]
                    , th [] [ H.text yourOpponentName ]
                    ]
                ]
            , H.tbody []
                [ H.tr []
                    [ td [] [ H.text "Total damage" ]
                    , td [] [ H.text <| String.fromInt yourTotalDamage ]
                    , td [] [ H.text <| String.fromInt theirTotalDamage ]
                    ]
                , H.tr []
                    [ td [] [ H.text "Hit rate" ]
                    , td [] [ H.text <| formatPercentage yourHitRate ]
                    , td [] [ H.text <| formatPercentage theirHitRate ]
                    ]
                , H.tr []
                    [ td [] [ H.text "Critical hit rate" ]
                    , td [] [ H.text <| formatPercentage yourCritRate ]
                    , td [] [ H.text <| formatPercentage theirCritRate ]
                    ]
                , H.tr []
                    [ td [] [ H.text "Average damage" ]
                    , td [] [ H.text <| formatFloat yourAvgDamage ]
                    , td [] [ H.text <| formatFloat theirAvgDamage ]
                    ]
                , H.tr []
                    [ td [] [ H.text "Max hit" ]
                    , td [] [ H.text <| String.fromInt yourMaxHit ]
                    , td [] [ H.text <| String.fromInt theirMaxHit ]
                    ]
                ]
            ]
        ]


messageView : { itsYou : Bool } -> Critical.Message -> String
messageView { itsYou } message =
    case message of
        Critical.OtherMessage s ->
            s

        Critical.PlayerMessage r ->
            if itsYou then
                r.you

            else
                r.them
