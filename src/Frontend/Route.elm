module Frontend.Route exposing
    ( AdminRoute(..)
    , Route(..)
    , loggedOut
    , needsAdmin
    , needsLogin
    , setImportValue
    )

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
    | CharCreation
    | Admin AdminRoute


type AdminRoute
    = Players
    | LoggedIn
    | Import String


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

        Admin _ ->
            False


needsAdmin : Route -> Bool
needsAdmin route =
    case route of
        Admin _ ->
            True

        _ ->
            False


loggedOut : Route -> Route
loggedOut route =
    if needsLogin route then
        News

    else
        route


setImportValue : String -> Route -> Route
setImportValue newValue route =
    case route of
        Admin (Import _) ->
            Admin (Import newValue)

        _ ->
            route
