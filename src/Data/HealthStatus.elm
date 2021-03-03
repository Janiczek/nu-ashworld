module Data.HealthStatus exposing
    ( HealthStatus(..)
    , check
    , isDead
    , label
    )


type HealthStatus
    = ExactHp { current : Int, max : Int }
    | Unhurt
    | SlightlyWounded
    | Wounded
    | SeverelyWounded
    | AlmostDead
    | Dead
    | Alive
    | Unknown


label : HealthStatus -> String
label status =
    case status of
        ExactHp { current, max } ->
            String.fromInt current
                ++ "/"
                ++ String.fromInt max

        Unhurt ->
            "Unhurt"

        SlightlyWounded ->
            "Slightly wounded"

        Wounded ->
            "Wounded"

        SeverelyWounded ->
            "Severely wounded"

        AlmostDead ->
            "Almost dead"

        Dead ->
            "Dead"

        Alive ->
            "Alive"

        Unknown ->
            "-"


check : Int -> { a | hp : Int, maxHp : Int } -> HealthStatus
check perception player =
    if perception >= 10 then
        ExactHp
            { current = player.hp
            , max = player.maxHp
            }

    else if perception >= 7 then
        greatPerceptionCheck player

    else if perception >= 5 then
        goodPerceptionCheck player

    else if perception >= 2 then
        badPerceptionCheck player

    else
        Unknown


{-| 0-100
-}
hpPercentage : { a | hp : Int, maxHp : Int } -> Int
hpPercentage { hp, maxHp } =
    hp * 100 // maxHp


slightlyWoundedThreshold : Int
slightlyWoundedThreshold =
    85


woundedThreshold : Int
woundedThreshold =
    50


severelyWoundedThreshold : Int
severelyWoundedThreshold =
    15


greatPerceptionCheck : { a | hp : Int, maxHp : Int } -> HealthStatus
greatPerceptionCheck player =
    let
        percentage =
            hpPercentage player
    in
    if player.hp == player.maxHp then
        Unhurt

    else if percentage >= slightlyWoundedThreshold then
        SlightlyWounded

    else if percentage >= woundedThreshold then
        Wounded

    else if percentage >= severelyWoundedThreshold then
        SeverelyWounded

    else if player.hp > 0 then
        AlmostDead

    else
        Dead


goodPerceptionCheck : { a | hp : Int, maxHp : Int } -> HealthStatus
goodPerceptionCheck player =
    let
        percentage =
            hpPercentage player
    in
    if player.hp == player.maxHp then
        Unhurt

    else if percentage >= woundedThreshold then
        Wounded

    else if percentage >= severelyWoundedThreshold then
        SeverelyWounded

    else if player.hp > 0 then
        AlmostDead

    else
        Dead


badPerceptionCheck : { a | hp : Int, maxHp : Int } -> HealthStatus
badPerceptionCheck player =
    if player.hp > 0 then
        Alive

    else
        Dead


isDead : HealthStatus -> Bool
isDead status =
    case status of
        ExactHp { current } ->
            current <= 0

        Unhurt ->
            False

        SlightlyWounded ->
            False

        Wounded ->
            False

        SeverelyWounded ->
            False

        AlmostDead ->
            False

        Dead ->
            True

        Alive ->
            False

        Unknown ->
            False
