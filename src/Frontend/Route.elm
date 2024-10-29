module Frontend.Route exposing
    ( AdminRoute(..)
    , PlayerRoute(..)
    , Route(..)
    , fromUrl
    , isMessagesRelatedRoute
    , loggedOut
    , needsAdmin
    , needsPlayer
    , toString
    )

import Data.Message as Message
import Data.Vendor.Shop as Shop exposing (Shop)
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
    | TownStore Shop
    | Fight
    | Messages
    | Message Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity World.Name
    | AdminWorldHiscores World.Name


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

                TownStore _ ->
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
        , P.map AdminWorldActivity <| P.s "world" </> P.string </> P.s "activity"
        , P.map AdminWorldHiscores <| P.s "world" </> P.string </> P.s "hiscores"
        ]


playerParser : Parser (PlayerRoute -> a) a
playerParser =
    P.oneOf
        [ P.map AboutWorld <| P.s "about"
        , P.map Character <| P.s "character"
        , P.map Inventory <| P.s "inventory"
        , P.map Ladder <| P.s "ladder"
        , P.map TownMainSquare <| P.s "town"
        , P.map TownStore <| P.s "town" </> P.s "store" </> shop
        , P.map Fight <| P.s "fight"
        , P.map Messages <| P.s "messages"
        , P.map Message <| P.s "messages" </> P.int
        , P.map CharCreation <| P.s "character-creation"
        , P.map SettingsFightStrategy <| P.s "settings" </> P.s "fight-strategy"
        , P.map SettingsFightStrategySyntaxHelp <| P.s "settings" </> P.s "fight-strategy" </> P.s "help"
        ]


shop : Parser (Shop -> a) a
shop =
    Shop.all
        |> List.map (\shop_ -> P.map shop_ (P.s (shopUrlFragment shop_)))
        |> P.oneOf


shopUrlFragment : Shop -> String
shopUrlFragment shop_ =
    case shop_ of
        Shop.ArroyoHakunin ->
            "hakunin"

        Shop.KlamathMaida ->
            "maida"

        Shop.KlamathVic ->
            "vic"

        Shop.DenFlick ->
            "flick"

        Shop.ModocJo ->
            "jo"

        Shop.VaultCityRandal ->
            "randal"

        Shop.VaultCityHappyHarry ->
            "happy-harry"

        Shop.GeckoSurvivalGearPercy ->
            "percy"

        Shop.ReddingAscorti ->
            "ascorti"

        Shop.BrokenHillsGeneralStoreLiz ->
            "liz"

        Shop.BrokenHillsChemistJacob ->
            "jacob"

        Shop.NewRenoArmsEldridge ->
            "eldridge"

        Shop.NewRenoRenescoPharmacy ->
            "renesco"

        Shop.NCRBuster ->
            "buster"

        Shop.NCRDuppo ->
            "duppo"

        Shop.SanFranciscoFlyingDragon8LaoChou ->
            "lao-chou"

        Shop.SanFranciscoRed888GunsMaiDaChiang ->
            "mai-da-chiang"

        Shop.SanFranciscoPunksCal ->
            "cal"

        Shop.SanFranciscoPunksJenna ->
            "jenna"


toString : Route -> String
toString route =
    "/"
        ++ (case route of
                About ->
                    "about"

                News ->
                    "news"

                Map ->
                    "map"

                WorldsList ->
                    "worlds"

                NotFound url ->
                    url.path
                        ++ (url.query |> Maybe.map (\q -> "?" ++ q) |> Maybe.withDefault "")
                        ++ (url.fragment |> Maybe.map (\f -> "#" ++ f) |> Maybe.withDefault "")

                -- TODO is this OK?
                PlayerRoute proute ->
                    "game/"
                        ++ (case proute of
                                AboutWorld ->
                                    "about"

                                Character ->
                                    "character"

                                Inventory ->
                                    "inventory"

                                Ladder ->
                                    "ladder"

                                TownMainSquare ->
                                    "town"

                                TownStore shop_ ->
                                    "town/store/" ++ shopUrlFragment shop_

                                Fight ->
                                    "fight"

                                Messages ->
                                    "messages"

                                Message messageId ->
                                    "messages/" ++ String.fromInt messageId

                                CharCreation ->
                                    "character-creation"

                                SettingsFightStrategy ->
                                    "settings/fight-strategy"

                                SettingsFightStrategySyntaxHelp ->
                                    "settings/fight-strategy/help"
                           )

                AdminRoute aroute ->
                    "admin/"
                        ++ (case aroute of
                                AdminWorldsList ->
                                    "worlds"

                                AdminWorldActivity world ->
                                    "world/" ++ world ++ "/activity"

                                AdminWorldHiscores world ->
                                    "world/" ++ world ++ "/hiscores"
                           )
           )
