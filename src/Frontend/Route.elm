module Frontend.Route exposing (Route(..), needsLogin)


needsLogin : Route -> Bool
needsLogin route =
    case route of
        LoggedOutHomepage ->
            False

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


type Route
    = LoggedOutHomepage
    | Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
