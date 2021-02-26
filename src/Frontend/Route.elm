module Frontend.Route exposing (Route(..), label, needsLogin)


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About


needsLogin : Route -> Bool
needsLogin route =
    case route of
        Character ->
            True

        Map ->
            False

        Ladder ->
            False

        Town ->
            True

        Settings ->
            True

        FAQ ->
            False

        About ->
            False


label : Route -> String
label route =
    case route of
        Character ->
            "Character"

        Map ->
            "Map"

        Ladder ->
            "Ladder"

        Town ->
            "Town"

        Settings ->
            "Settings"

        FAQ ->
            "FAQ"

        About ->
            "About"
