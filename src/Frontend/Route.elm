module Frontend.Route exposing
    ( AdminRoute(..)
    , Route(..)
    , loggedOut
    , needsAdmin
    , needsLogin
    , setImportValue
    )

import Data.Fight exposing (FightInfo)
import Data.Message exposing (Message)


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | About
    | News
    | Fight FightInfo
    | Messages
    | Message Message
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

        About ->
            False

        News ->
            False

        Fight _ ->
            True

        Messages ->
            True

        Message _ ->
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
    if needsLogin route || needsAdmin route then
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
