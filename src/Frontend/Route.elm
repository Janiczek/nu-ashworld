module Frontend.Route exposing (Route(..), needsLogin)


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
