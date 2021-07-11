module Frontend.Route exposing
    ( AdminRoute(..)
    , Route(..)
    , SettingsRoute(..)
    , TownRoute(..)
    , barterState
    , isMessagesRelatedRoute
    , loggedOut
    , mapBarterState
    , mapSettings
    , needsAdmin
    , needsLogin
    )

import Data.Barter as Barter
import Data.Fight as Fight
import Data.Message exposing (Message)


type Route
    = Character
    | Inventory
    | Map
    | Ladder
    | Town TownRoute
    | About
    | News
    | Fight Fight.Info
    | Messages
    | Message Message
    | CharCreation
    | Admin AdminRoute
    | Settings SettingsData


type alias SettingsData =
    { fightStrategyText : String
    , subroute : SettingsRoute
    , hoveredError : Maybe { index : Int, row : Int, col : Int }
    }


type SettingsRoute
    = FightStrategy
    | FightStrategySyntaxHelp


type TownRoute
    = MainSquare
    | Store { barter : Barter.State }


type AdminRoute
    = LoggedIn


needsLogin : Route -> Bool
needsLogin route =
    case route of
        Character ->
            True

        Inventory ->
            True

        Map ->
            False

        Ladder ->
            False

        Town _ ->
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

        Settings _ ->
            True


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


barterState : Route -> Maybe Barter.State
barterState route =
    case route of
        Town (Store { barter }) ->
            Just barter

        _ ->
            Nothing


mapBarterState : (Barter.State -> Barter.State) -> Route -> Route
mapBarterState fn route =
    case route of
        Town (Store r) ->
            Town (Store { r | barter = fn r.barter })

        _ ->
            route


mapSettings : (SettingsData -> SettingsData) -> Route -> Route
mapSettings fn route =
    case route of
        Settings r ->
            Settings (fn r)

        _ ->
            route


isMessagesRelatedRoute : Route -> Bool
isMessagesRelatedRoute route =
    case route of
        Character ->
            False

        Inventory ->
            False

        Map ->
            False

        Ladder ->
            False

        Town _ ->
            False

        About ->
            False

        News ->
            False

        Fight _ ->
            False

        Messages ->
            True

        Message _ ->
            True

        CharCreation ->
            False

        Admin _ ->
            False

        Settings _ ->
            False
