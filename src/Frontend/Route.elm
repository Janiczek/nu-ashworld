module Frontend.Route exposing
    ( AdminRoute(..)
    , PlayerRoute(..)
    , Route(..)
    , fromUrl
    , getShop
    , isMessagesRelatedRoute
    , isStandalone
    , loggedOut
    , needsAdmin
    , needsPlayer
    , needsPlayerSigningUp
    , toString
    )

import Data.Message as Message
import Data.Vendor.Shop as Shop exposing (Shop)
import Data.World as World
import Url exposing (Url)
import Url.Parser as P exposing ((</>), Parser)


type Route
    = About
    | Guide (Maybe String)
    | News
    | Map
    | WorldsList
    | NotFound Url
    | CharCreation
    | FightStrategySyntaxHelp
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
    | SettingsFightStrategy


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity World.Name
    | AdminWorldHiscores World.Name


needsPlayerSigningUp : Route -> Bool
needsPlayerSigningUp route =
    case route of
        CharCreation ->
            True

        PlayerRoute _ ->
            False

        AdminRoute _ ->
            False

        About ->
            False

        Guide _ ->
            False

        News ->
            False

        Map ->
            False

        WorldsList ->
            False

        NotFound _ ->
            False

        FightStrategySyntaxHelp ->
            False


needsPlayer : Route -> Bool
needsPlayer route =
    case route of
        PlayerRoute _ ->
            True

        AdminRoute _ ->
            False

        About ->
            False

        CharCreation ->
            False

        Guide _ ->
            False

        News ->
            False

        Map ->
            False

        WorldsList ->
            False

        NotFound _ ->
            False

        FightStrategySyntaxHelp ->
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

        CharCreation ->
            False

        Guide _ ->
            False

        News ->
            False

        Map ->
            False

        WorldsList ->
            False

        NotFound _ ->
            False

        FightStrategySyntaxHelp ->
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

                SettingsFightStrategy ->
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
        , P.map Guide <| P.s "guide" </> P.fragment identity
        , P.map FightStrategySyntaxHelp <| P.s "fight-strategy-help"
        , P.map Map <| P.s "map"
        , P.map WorldsList <| P.s "worlds"
        , P.map AdminRoute <| P.s "admin" </> adminParser
        , P.map CharCreation <| P.s "game" </> P.s "character-creation"
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
        , P.map SettingsFightStrategy <| P.s "settings" </> P.s "fight-strategy"
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

                Guide currentHeading ->
                    let
                        fragment =
                            case currentHeading of
                                Nothing ->
                                    ""

                                Just heading ->
                                    "#" ++ heading
                    in
                    "guide" ++ fragment

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

                CharCreation ->
                    "game/character-creation"

                FightStrategySyntaxHelp ->
                    "fight-strategy-help"

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

                                SettingsFightStrategy ->
                                    "settings/fight-strategy"
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


getShop : Route -> Maybe Shop
getShop route =
    case route of
        PlayerRoute subroute ->
            case subroute of
                TownStore shop_ ->
                    Just shop_

                AboutWorld ->
                    Nothing

                Character ->
                    Nothing

                Inventory ->
                    Nothing

                Ladder ->
                    Nothing

                TownMainSquare ->
                    Nothing

                Fight ->
                    Nothing

                Messages ->
                    Nothing

                Message _ ->
                    Nothing

                SettingsFightStrategy ->
                    Nothing

        About ->
            Nothing

        CharCreation ->
            Nothing

        FightStrategySyntaxHelp ->
            Nothing

        Guide _ ->
            Nothing

        News ->
            Nothing

        Map ->
            Nothing

        WorldsList ->
            Nothing

        NotFound _ ->
            Nothing

        AdminRoute _ ->
            Nothing


{-| Hides the left navigation if False.
Right now only used for the Fight Strategy and the Guide..
-}
isStandalone : Route -> Bool
isStandalone route =
    case route of
        Guide _ ->
            True

        FightStrategySyntaxHelp ->
            True

        About ->
            False

        News ->
            False

        Map ->
            False

        CharCreation ->
            False

        WorldsList ->
            False

        NotFound _ ->
            False

        AdminRoute _ ->
            False

        PlayerRoute _ ->
            False
