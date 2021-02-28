module Frontend.Route exposing
    ( Route(..)
    , loggedOut
    , needsLogin
    )

import Data.Fight exposing (FightInfo)
import Data.NewChar exposing (NewChar)


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
    | CharCreation


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

        CharCreation ->
            True


loggedOut : Route -> Route
loggedOut route =
    if needsLogin route then
        News

    else
        route
