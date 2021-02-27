module Frontend.Route exposing (Route(..), needsLogin)

import Data.Fight exposing (FightInfo)


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight FightInfo


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

        News ->
            False

        Fight _ ->
            True
