module Frontend.Route exposing
    ( AdminRoute(..)
    , Route(..)
    , TownRoute(..)
    , barterState
    , loggedOut
    , needsAdmin
    , needsLogin
    , setImportValue
    )

import Data.Barter as Barter
import Data.Fight exposing (FightInfo)
import Data.Message exposing (Message)
import Data.Vendor exposing (Vendor)


type Route
    = Character
    | Map
    | Ladder
    | Town TownRoute
    | Settings
    | About
    | News
    | Fight FightInfo
    | Messages
    | Message Message
    | CharCreation
    | Admin AdminRoute


type TownRoute
    = MainSquare
    | Store
        { vendor : Vendor
        , barter : Barter.State
        }


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

        Town _ ->
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


barterState : Route -> Maybe Barter.State
barterState route =
    case route of
        Town (Store { barter }) ->
            Just barter

        _ ->
            Nothing
