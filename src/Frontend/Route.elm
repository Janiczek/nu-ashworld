module Frontend.Route exposing
    ( AdminRoute(..)
    , PlayerRoute(..)
    , Route(..)
    , SettingsRoute(..)
    , TownRoute(..)
    , barterState
    , isMessagesRelatedRoute
    , loggedOut
    , mapBarterState
    , mapSettings
    , needsAdmin
    , needsPlayer
    )

import Data.Barter as Barter
import Data.Fight as Fight
import Data.Message exposing (Message)
import Data.World as World


type Route
    = About
    | News
    | Map
    | WorldsList
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | Town TownRoute
    | Fight Fight.Info
    | Messages
    | Message Message
    | CharCreation
    | Settings SettingsData


type alias SettingsData =
    { fightStrategyText : String
    , subroute : SettingsRoute
    }


type SettingsRoute
    = FightStrategy
    | FightStrategySyntaxHelp


type TownRoute
    = MainSquare
    | Store { barter : Barter.State }


type AdminRoute
    = AdminWorldsList
    | AdminWorldDetail World.Name
    | AdminPlayersList World.Name


needsPlayer : Route -> Bool
needsPlayer route =
    case route of
        PlayerRoute _ ->
            True

        AdminRoute _ ->
            False

        About ->
            False

        News ->
            False

        Map ->
            False

        WorldsList ->
            False


needsAdmin : Route -> Bool
needsAdmin route =
    case route of
        AdminRoute _ ->
            True

        PlayerRoute _ ->
            False

        About ->
            False

        News ->
            False

        Map ->
            False

        WorldsList ->
            False


loggedOut : Route -> Route
loggedOut route =
    if needsPlayer route || needsAdmin route then
        News

    else
        route


barterState : Route -> Maybe Barter.State
barterState route =
    case route of
        PlayerRoute (Town (Store { barter })) ->
            Just barter

        _ ->
            Nothing


mapBarterState : (Barter.State -> Barter.State) -> Route -> Route
mapBarterState fn route =
    case route of
        PlayerRoute (Town (Store r)) ->
            PlayerRoute (Town (Store { r | barter = fn r.barter }))

        _ ->
            route


mapSettings : (SettingsData -> SettingsData) -> Route -> Route
mapSettings fn route =
    case route of
        PlayerRoute (Settings r) ->
            PlayerRoute (Settings (fn r))

        _ ->
            route


isMessagesRelatedRoute : Route -> Bool
isMessagesRelatedRoute route =
    case route of
        PlayerRoute subroute ->
            case subroute of
                Messages ->
                    True

                Message _ ->
                    True

                AboutWorld ->
                    False

                Character ->
                    False

                Inventory ->
                    False

                Ladder ->
                    False

                Town _ ->
                    False

                Fight _ ->
                    False

                CharCreation ->
                    False

                Settings _ ->
                    False

        _ ->
            False
