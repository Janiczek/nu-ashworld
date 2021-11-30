module Frontend.Route exposing
    ( AdminRoute(..)
    , PlayerRoute(..)
    , Route(..)
    , fromUrl
    , isMessagesRelatedRoute
    , loggedOut
    , needsAdmin
    , needsPlayer
    )

import Data.Barter as Barter
import Data.Fight as Fight
import Data.Message as Message exposing (Message)
import Data.World as World
import Url exposing (Url)
import Url.Parser as P exposing ((</>), Parser)


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore
    | Fight
    | Messages
    | Message Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


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

        NotFound _ ->
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

        NotFound _ ->
            False


loggedOut : Route -> Route
loggedOut route =
    if needsPlayer route || needsAdmin route then
        News

    else
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

                TownMainSquare ->
                    False

                TownStore ->
                    False

                Fight ->
                    False

                CharCreation ->
                    False

                SettingsFightStrategy ->
                    False

                SettingsFightStrategySyntaxHelp ->
                    False

        _ ->
            False


fromUrl : Url -> Route
fromUrl url =
    P.parse parser url
        |> Maybe.withDefault (NotFound url)


parser : Parser (Route -> a) a
parser =
    P.oneOf
        [ P.map News P.top
        , P.map News <| P.s "news"
        , P.map About <| P.s "about"
        , P.map Map <| P.s "map"
        , P.map WorldsList <| P.s "worlds"
        , P.map AdminRoute <| P.s "admin" </> adminParser
        , P.map PlayerRoute <| P.s "game" </> playerParser
        ]


adminParser : Parser (AdminRoute -> a) a
adminParser =
    P.oneOf
        [ P.map AdminWorldsList <| P.s "worlds"
        , P.map AdminWorldDetail <| P.s "world" </> P.string
        , P.map AdminPlayersList <| P.s "world" </> P.string </> P.s "players"
        ]


playerParser : Parser (PlayerRoute -> a) a
playerParser =
    P.oneOf
        [ P.map AboutWorld <| P.s "about"
        , P.map Character <| P.s "character"
        , P.map Inventory <| P.s "inventory"
        , P.map Ladder <| P.s "ladder"
        , P.map TownMainSquare <| P.s "town"
        , P.map TownStore <| P.s "town" </> P.s "store"
        , P.map Fight <| P.s "fight"
        , P.map Messages <| P.s "messages"
        , P.map Message <| P.s "messages" </> P.int
        , P.map CharCreation <| P.s "character-creation"
        , P.map SettingsFightStrategy <| P.s "settings" </> P.s "fight-strategy"
        , P.map SettingsFightStrategySyntaxHelp <| P.s "settings" </> P.s "fight-strategy" </> P.s "help"
        ]
