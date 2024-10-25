module Frontend exposing (..)

import Admin
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Cmd.ExtraExtra as Cmd
import Data.Auth as Auth exposing (Auth, Plaintext)
import Data.Barter as Barter
import Data.Fight as Fight
import Data.Fight.AttackStyle as AttackStyle
import Data.Fight.DamageType exposing (DamageType)
import Data.Fight.OpponentType as OpponentType exposing (OpponentType)
import Data.Fight.View
import Data.FightStrategy as FightStrategy exposing (FightStrategy)
import Data.FightStrategy.Help as FightStrategyHelp
import Data.FightStrategy.Named as FightStrategy
import Data.FightStrategy.Parser as FightStrategy
import Data.HealthStatus as HealthStatus
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Item.Type as ItemType
import Data.Ladder as Ladder
import Data.Map as Map exposing (TileCoords)
import Data.Map.BigChunk as BigChunk exposing (BigChunk(..))
import Data.Map.Location as Location exposing (Location)
import Data.Map.Pathfinding as Pathfinding
import Data.Map.Terrain as Terrain
import Data.Message as Message
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player as Player
    exposing
        ( COtherPlayer
        , CPlayer
        , Player(..)
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Special.Perception as Perception exposing (PerceptionLevel)
import Data.Tick as Tick
import Data.Trait as Trait exposing (Trait)
import Data.Vendor as Vendor exposing (Vendor)
import Data.Vendor.Shop as Shop exposing (Shop)
import Data.Version as Version
import Data.World as World
import Data.WorldData as WorldData
    exposing
        ( AdminData
        , PlayerData
        , WorldData(..)
        )
import Data.WorldInfo exposing (WorldInfo)
import Data.Xp as Xp
import DateFormat
import DateFormat.Relative
import Dict exposing (Dict)
import Dict.Extra as Dict
import File
import File.Download
import File.Select
import Frontend.HoveredItem as HoveredItem exposing (HoveredItem(..))
import Frontend.News as News
import Frontend.Route as Route
    exposing
        ( AdminRoute(..)
        , Route(..)
        )
import Fusion.Editor
import Fusion.Generated.TypeDict
import Fusion.Generated.TypeDict.Types
import Fusion.Generated.Types
import Fusion.Patch
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HA
import Html.Events as HE
import Html.Events.Extra as HE
import Html.Extra as H
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Lamdera
import List.ExtraExtra as List
import Logic exposing (AttackStats, ItemNotUsableReason(..))
import Markdown
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import Parser
import Result.Extra as Result
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import Set exposing (Set)
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Tailwind as TW
import Task
import Time exposing (Posix)
import Time.Extra as Time
import Time.ExtraExtra as Time
import Types exposing (..)
import UI
import Url exposing (Url)


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


viewFusion : Model -> Browser.Document FrontendMsg
viewFusion model =
    { title = ""
    , body =
        []
    }


init : Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    let
        worldData =
            NotLoggedIn

        route =
            url
                |> Route.fromUrl
                |> sanitizeRoute worldData
    in
    ( { key = key
      , time = Time.millisToPosix 0
      , route = route
      , zone = Time.utc
      , loginForm = Auth.init
      , worlds = Nothing
      , worldData = worldData

      -- mostly player frontend state
      , newChar = NewChar.init
      , alertMessage = Nothing
      , mapMouseCoords = Nothing
      , hoveredItem = Nothing
      , barter = Barter.empty
      , fightInfo = Nothing
      , fightStrategyText = ""
      , expandedQuests = SeqSet.empty
      , userWantsToShowAreaDanger = False

      -- backend state
      , lastTenToBackendMsgs = []
      , adminNewWorldName = ""
      , adminNewWorldFast = False
      , fusionBackendModel = FNotLoaded
      }
    , Cmd.batch
        [ Task.perform GotZone Time.here
        , Task.perform GotTime Time.now
        , Nav.pushUrl key (Route.toString route)

        -- TODO don't push this, only for developing styles
        --, let
        --    initAuth =
        --        Auth.init
        --  in
        --  Lamdera.sendToBackend <|
        --    LogMeIn <|
        --        Auth.hash
        --            ({ initAuth
        --                | name = "j2"
        --                , worldName = "main"
        --             }
        --                |> Auth.setPlaintextPassword "j2"
        --            )
        ]
    )


subscriptions : Model -> Sub FrontendMsg
subscriptions _ =
    Time.every 1000 GotTime


isPlayer : Model -> Bool
isPlayer model =
    WorldData.isPlayer model.worldData


isAdmin : Model -> Bool
isAdmin model =
    WorldData.isAdmin model.worldData


sanitizeRoute : WorldData -> Route -> Route
sanitizeRoute worldData route =
    if Route.needsAdmin route && not (WorldData.isAdmin worldData) then
        News

    else if Route.needsPlayer route && not (WorldData.isPlayer worldData) then
        News

    else
        route


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg ({ loginForm } as model) =
    let
        withLoggedInPlayer : (PlayerData -> ( Model, Cmd FrontendMsg )) -> ( Model, Cmd FrontendMsg )
        withLoggedInPlayer fn =
            case model.worldData of
                IsPlayer data ->
                    fn data

                IsAdmin _ ->
                    ( model, Cmd.none )

                NotLoggedIn ->
                    ( model, Cmd.none )
    in
    case msg of
        LoadFusionBackendModel ->
            ( model
            , Lamdera.sendToBackend FusionGiveMeBackendModel
            )

        ResetFusionBackendModel ->
            ( { model
                | fusionBackendModel =
                    case model.fusionBackendModel of
                        FNotLoaded ->
                            FNotLoaded

                        FOriginalOnly original ->
                            FOriginalOnly original

                        FEdited { original } ->
                            FOriginalOnly original
              }
            , Cmd.none
            )

        PersistFusionBackendModel ->
            case model.fusionBackendModel of
                FNotLoaded ->
                    ( model, Cmd.none )

                FOriginalOnly _ ->
                    ( model, Cmd.none )

                FEdited { patch } ->
                    ( model
                    , Lamdera.sendToBackend <| ApplyThisFusionPatch patch
                    )

        FusionEdit patch ->
            let
                edit maybeOriginal maybeOldPatch value =
                    let
                        patchResult =
                            Fusion.Patch.patch
                                { force = False }
                                patch
                                value
                    in
                    case patchResult of
                        Err _ ->
                            ( model, Cmd.none )

                        Ok newBackendModel ->
                            ( { model
                                | fusionBackendModel =
                                    case maybeOriginal of
                                        Nothing ->
                                            FEdited { original = value, edited = newBackendModel, patch = patch }

                                        Just original ->
                                            case Fusion.Patch.merge maybeOldPatch (Just patch) of
                                                Err _ ->
                                                    -- TODO be vocal about this?
                                                    model.fusionBackendModel

                                                Ok Nothing ->
                                                    -- TODO be vocal about this?
                                                    model.fusionBackendModel

                                                Ok (Just newPatch) ->
                                                    FEdited
                                                        { original = original
                                                        , edited = newBackendModel
                                                        , patch = newPatch
                                                        }
                              }
                            , Cmd.none
                            )
            in
            case model.fusionBackendModel of
                FNotLoaded ->
                    ( model, Cmd.none )

                FOriginalOnly value ->
                    edit Nothing Nothing value

                FEdited r ->
                    edit (Just r.original) (Just r.patch) r.edited

        FusionQuery _ ->
            ( model, Cmd.none )

        GoToRoute route ->
            let
                finalRoute =
                    sanitizeRoute model.worldData route
            in
            ( { model
                | route = finalRoute
                , alertMessage = Nothing
              }
            , Nav.pushUrl model.key (Route.toString finalRoute)
            )

        GoToTownStore shop ->
            { model | barter = Barter.empty }
                |> update (GoToRoute (PlayerRoute (Route.TownStore shop)))

        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            let
                route : Route
                route =
                    url
                        |> Route.fromUrl
                        |> sanitizeRoute model.worldData
            in
            ( { model | route = route }
            , Cmd.none
            )

        Logout ->
            ( model
            , Lamdera.sendToBackend LogMeOut
            )

        Login ->
            let
                logMeIn =
                    ( model
                    , Lamdera.sendToBackend <| LogMeIn <| Auth.hash model.loginForm
                    )
            in
            if Auth.isAdminName model.loginForm then
                logMeIn

            else if String.isEmpty model.loginForm.worldName then
                ( { model | alertMessage = Just "Select a world first" }
                , Cmd.none
                )

            else
                logMeIn

        Register ->
            let
                register =
                    ( model
                    , Lamdera.sendToBackend <| RegisterMe <| Auth.hash model.loginForm
                    )
            in
            if Auth.isAdminName model.loginForm then
                register

            else if String.isEmpty model.loginForm.worldName then
                ( { model | alertMessage = Just "Select a world first" }
                , Cmd.none
                )

            else
                register

        GotTime time ->
            ( { model | time = time }
            , Cmd.none
            )

        GotZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        AskToFight playerName ->
            ( model
            , Lamdera.sendToBackend <| Fight playerName
            )

        AskToHeal ->
            ( model
            , Lamdera.sendToBackend HealMe
            )

        AskToEquipArmor itemId ->
            ( model
            , Lamdera.sendToBackend <| EquipArmor itemId
            )

        AskToEquipWeapon itemId ->
            ( model
            , Lamdera.sendToBackend <| EquipWeapon itemId
            )

        AskToPreferAmmo itemKind ->
            ( model
            , Lamdera.sendToBackend <| PreferAmmo itemKind
            )

        AskToUnequipArmor ->
            ( model
            , Lamdera.sendToBackend UnequipArmor
            )

        AskToUnequipWeapon ->
            ( model
            , Lamdera.sendToBackend UnequipWeapon
            )

        AskToClearPreferredAmmo ->
            ( model
            , Lamdera.sendToBackend ClearPreferredAmmo
            )

        AskToUseItem itemId ->
            ( model
            , Lamdera.sendToBackend <| UseItem itemId
            )

        AskToWander ->
            ( model
            , Lamdera.sendToBackend Wander
            )

        AskToSetFightStrategy ( strategy, text ) ->
            ( model
            , Lamdera.sendToBackend <| SetFightStrategy ( strategy, text )
            )

        Refresh ->
            ( model
            , Lamdera.sendToBackend RefreshPlease
            )

        AskForWorldsAndGoToWorldsRoute ->
            ( model
            , Lamdera.sendToBackend WorldsPlease
            )
                |> Cmd.andThen (update (GoToRoute Route.WorldsList))

        AskToTagSkill skill ->
            ( model
            , Lamdera.sendToBackend <| TagSkill skill
            )

        AskToUseSkillPoints skill ->
            ( model
            , Lamdera.sendToBackend <| UseSkillPoints skill
            )

        AskToChoosePerk perk ->
            ( model
            , Lamdera.sendToBackend <| ChoosePerk perk
            )

        SetAuthName newName ->
            ( { model
                | loginForm = { loginForm | name = newName }
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        SetAuthPassword newPassword ->
            ( { model
                | loginForm = Auth.setPlaintextPassword newPassword model.loginForm
                , alertMessage = Nothing
              }
            , Cmd.none
            )

        SetAuthWorld worldName ->
            case model.worlds of
                Nothing ->
                    ( model, Cmd.none )

                Just worlds ->
                    if List.any (.name >> (==) worldName) worlds then
                        ( { model
                            | loginForm = { loginForm | worldName = worldName }
                            , alertMessage = Nothing
                          }
                        , Cmd.none
                        )

                    else
                        ( model, Cmd.none )

        CreateChar ->
            ( model
            , Lamdera.sendToBackend <| CreateNewChar model.newChar
            )

        NewCharIncSpecial type_ ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.incSpecial type_
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharDecSpecial type_ ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.decSpecial type_
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharToggleTaggedSkill skill ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.toggleTaggedSkill skill
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        NewCharToggleTrait trait ->
            ( { model
                | newChar =
                    model.newChar
                        |> NewChar.toggleTrait trait
                        |> NewChar.dismissError
              }
            , Cmd.none
            )

        MapMouseAtCoords mouseCoords ->
            withLoggedInPlayer <|
                \data ->
                    case data.player of
                        Player cPlayer ->
                            let
                                perceptionLevel : PerceptionLevel
                                perceptionLevel =
                                    Perception.level
                                        { perception = cPlayer.special.perception
                                        , hasAwarenessPerk = Perk.rank Perk.Awareness cPlayer.perks > 0
                                        }

                                playerCoords =
                                    Map.toTileCoords cPlayer.location
                            in
                            ( { model
                                | mapMouseCoords =
                                    Just
                                        ( mouseCoords
                                        , Pathfinding.path
                                            perceptionLevel
                                            { from = playerCoords
                                            , to = mouseCoords
                                            }
                                        )
                              }
                            , Cmd.none
                            )

                        NeedsCharCreated _ ->
                            ( model, Cmd.none )

        MapMouseOut ->
            ( { model | mapMouseCoords = Nothing }
            , Cmd.none
            )

        MapMouseClick ->
            case model.mapMouseCoords of
                Nothing ->
                    ( model, Cmd.none )

                Just ( newCoords, path ) ->
                    ( model
                    , Lamdera.sendToBackend <| MoveTo newCoords path
                    )

        SetShowAreaDanger newShow ->
            ( { model | userWantsToShowAreaDanger = newShow }
            , Cmd.none
            )

        OpenMessage messageId ->
            ( model
            , Lamdera.sendToBackend <| MessageWasRead messageId
            )
                |> Cmd.andThen (update (GoToRoute (PlayerRoute (Route.Message messageId))))

        AskToRemoveMessage messageId ->
            ( model
            , Lamdera.sendToBackend <| RemoveMessage messageId
            )

        AskToRemoveFightMessages ->
            ( model
            , Lamdera.sendToBackend RemoveFightMessages
            )

        AskToRemoveAllMessages ->
            ( model
            , Lamdera.sendToBackend RemoveAllMessages
            )

        BarterMsg barterMsg ->
            updateBarter barterMsg model

        HoverItem item ->
            ( { model | hoveredItem = Just item }
            , Cmd.none
            )

        StopHoveringItem ->
            ( { model | hoveredItem = Nothing }
            , Cmd.none
            )

        SetFightStrategyText text ->
            ( { model | fightStrategyText = text }
            , Cmd.none
            )

        SetAdminNewWorldName text ->
            ( { model | adminNewWorldName = text }
            , Cmd.none
            )

        SetAdminNewWorldFast new ->
            ( { model | adminNewWorldFast = new }
            , Cmd.none
            )

        AskToCreateNewWorld ->
            ( { model
                | adminNewWorldName = ""
                , adminNewWorldFast = False
              }
            , Lamdera.sendToBackend
                (AdminToBackend
                    (CreateNewWorld
                        model.adminNewWorldName
                        model.adminNewWorldFast
                    )
                )
            )

        CollapseQuestItem quest ->
            ( { model | expandedQuests = SeqSet.remove quest model.expandedQuests }
            , Cmd.none
            )

        ExpandQuestItem quest ->
            ( { model | expandedQuests = SeqSet.insert quest model.expandedQuests }
            , Cmd.none
            )

        AskToStopProgressing quest ->
            ( model
            , Lamdera.sendToBackend <| StopProgressing quest
            )

        AskToStartProgressing quest ->
            ( model
            , Lamdera.sendToBackend <| StartProgressing quest
            )


resetBarter : Model -> ( Model, Cmd FrontendMsg )
resetBarter model =
    ( { model | barter = Barter.empty }
    , Cmd.none
    )


mapBarter_ : (Barter.State -> Barter.State) -> Model -> Model
mapBarter_ fn model =
    { model | barter = fn model.barter }


mapBarter : (Barter.State -> Barter.State) -> Model -> ( Model, Cmd FrontendMsg )
mapBarter fn model =
    ( mapBarter_ fn model
    , Cmd.none
    )


updateBarter : BarterMsg -> Model -> ( Model, Cmd FrontendMsg )
updateBarter msg model =
    Tuple.mapFirst (\model_ -> { model_ | barter = Barter.dismissMessage model_.barter }) <|
        case msg of
            ResetBarter ->
                resetBarter model

            ConfirmBarter shop ->
                ( model
                , Lamdera.sendToBackend <| Barter model.barter shop
                )

            AddPlayerItem itemId count ->
                mapBarter (Barter.addPlayerItem itemId count) model

            AddVendorItem itemId count ->
                mapBarter (Barter.addVendorItem itemId count) model

            AddPlayerCaps amount ->
                mapBarter (Barter.addPlayerCaps amount) model

            AddVendorCaps amount ->
                mapBarter (Barter.addVendorCaps amount) model

            RemovePlayerItem itemId count ->
                mapBarter (Barter.removePlayerItem itemId count) model

            RemoveVendorItem itemId count ->
                mapBarter (Barter.removeVendorItem itemId count) model

            RemovePlayerCaps amount ->
                mapBarter (Barter.removePlayerCaps amount) model

            RemoveVendorCaps amount ->
                mapBarter (Barter.removeVendorCaps amount) model

            SetTransferNInput position string ->
                mapBarter (Barter.setTransferNInput position string) model

            SetTransferNActive position ->
                mapBarter (Barter.setTransferNActive position) model

            UnsetTransferNActive ->
                mapBarter Barter.unsetTransferNActive model


mapLoggedInWorld : (PlayerData -> PlayerData) -> Model -> Model
mapLoggedInWorld fn model =
    case model.worldData of
        IsPlayer data ->
            { model | worldData = IsPlayer (fn data) }

        IsAdmin _ ->
            model

        NotLoggedIn ->
            model


updateLoggedInWorld : PlayerData -> Model -> Model
updateLoggedInWorld data model =
    mapLoggedInWorld (always data) model


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        FusionHeresBackendModel value ->
            ( { model | fusionBackendModel = FOriginalOnly value }
            , Cmd.none
            )

        YoureLoggedIn data ->
            let
                newRoute =
                    case data.player of
                        NeedsCharCreated _ ->
                            PlayerRoute Route.CharCreation

                        Player _ ->
                            PlayerRoute Route.Ladder
            in
            { model
                | worldData = IsPlayer data
                , alertMessage = Nothing
                , fightStrategyText =
                    case data.player of
                        NeedsCharCreated _ ->
                            ""

                        Player playerData ->
                            playerData.fightStrategyText
            }
                |> update (GoToRoute newRoute)

        YoureLoggedInAsAdmin data ->
            { model
                | worldData = IsAdmin data
                , alertMessage = Nothing
            }
                |> update (GoToRoute (AdminRoute AdminWorldsList))

        YoureRegistered data ->
            { model
                | worldData = IsPlayer data
                , alertMessage = Nothing
            }
                |> update (GoToRoute (PlayerRoute Route.CharCreation))

        CharCreationError error ->
            ( { model | newChar = NewChar.setError error model.newChar }
            , Cmd.none
            )

        YouHaveCreatedChar cPlayer data ->
            { model
                | worldData = IsPlayer data
                , alertMessage = Nothing
                , newChar = NewChar.init
                , fightStrategyText = cPlayer.fightStrategyText
            }
                |> update (GoToRoute (PlayerRoute Route.Ladder))

        YoureLoggedOut worlds ->
            { model
                | loginForm =
                    Auth.init
                        |> Auth.selectDefaultWorld worlds
                , alertMessage = Nothing
                , worlds = Just worlds
                , worldData = NotLoggedIn
            }
                |> update (GoToRoute (Route.loggedOut model.route))

        CurrentWorlds worlds ->
            ( { model
                | worlds = Just worlds
                , loginForm =
                    model.loginForm
                        |> Auth.selectDefaultWorld worlds
              }
            , Cmd.none
            )

        CurrentPlayer data ->
            ( case model.worldData of
                IsPlayer _ ->
                    { model | worldData = IsPlayer data }

                _ ->
                    model
            , Cmd.none
            )

        CurrentAdmin data ->
            ( case model.worldData of
                IsAdmin _ ->
                    { model | worldData = IsAdmin data }

                _ ->
                    model
            , Cmd.none
            )

        CurrentAdminLoggedInPlayers players ->
            ( case model.worldData of
                IsAdmin data ->
                    { model
                        | worldData =
                            IsAdmin { data | loggedInPlayers = players }
                    }

                _ ->
                    model
            , Cmd.none
            )

        CurrentAdminLastTenToBackendMsgs msgs ->
            ( { model | lastTenToBackendMsgs = msgs }
            , Cmd.none
            )

        YourFightResult ( fightInfo, world ) ->
            { model
                | -- TODO clear it once you go away
                  fightInfo = Just fightInfo
            }
                |> updateLoggedInWorld world
                |> update (GoToRoute (PlayerRoute Route.Fight))

        YourMessages messages ->
            ( model
                |> mapLoggedInWorld
                    (\world ->
                        { world
                            | player =
                                world.player
                                    |> Player.map (\player -> { player | messages = messages })
                        }
                    )
            , Cmd.none
            )

        AlertMessage message ->
            ( { model | alertMessage = Just message }
            , Cmd.none
            )

        BarterDone ( world, maybeMessage ) ->
            model
                |> updateLoggedInWorld world
                |> resetBarter
                |> (case maybeMessage of
                        Nothing ->
                            identity

                        Just message ->
                            Tuple.mapFirst (mapBarter_ (Barter.setMessage message))
                   )

        BarterMessage message ->
            mapBarter (Barter.setMessage message) model


view : Model -> Browser.Document FrontendMsg
view model =
    let
        worldNames : List World.Name
        worldNames =
            model.worlds
                |> Maybe.withDefault []
                |> List.map .name

        leftNav =
            case model.worldData of
                IsAdmin _ ->
                    [ alertMessageView model.alertMessage
                    , H.div [ HA.class "flex flex-col gap-4" ]
                        [ adminLinksView model.route
                        , commonLinksView model.route
                        ]
                    ]

                IsPlayer data ->
                    [ alertMessageView model.alertMessage
                    , playerInfoView data.player
                    , H.div [ HA.class "flex flex-col gap-4" ]
                        [ loggedInLinksView data.player model.route
                        , commonLinksView model.route
                        ]
                    ]

                NotLoggedIn ->
                    [ loginFormView worldNames model.loginForm
                    , alertMessageView model.alertMessage
                    , H.div [ HA.class "flex flex-col gap-4" ]
                        [ loggedOutLinksView model.route
                        , commonLinksView model.route
                        ]
                    ]
    in
    { title = "NuAshworld " ++ Version.version
    , body = [ appView { leftNav = leftNav } model ]
    }


appView :
    { leftNav : List (Html FrontendMsg) }
    -> Model
    -> Html FrontendMsg
appView { leftNav } model =
    H.div [ HA.class "flex flex-1 flex-row bg-green-900 max-w-vw max-h-vh overflow-hidden" ]
        [ leftNavView leftNav model
        , contentView model
        ]


leftNavView : List (Html FrontendMsg) -> Model -> Html FrontendMsg
leftNavView leftNav model =
    let
        tickData :
            Maybe
                { tickFrequency : Time.Interval
                , worldName : String
                }
        tickData =
            case model.worldData of
                IsAdmin _ ->
                    Nothing

                IsPlayer data ->
                    Just
                        { tickFrequency = data.tickFrequency
                        , worldName = data.worldName
                        }

                NotLoggedIn ->
                    Nothing
    in
    H.div [ HA.class "bg-green-800 min-w-fit px-6 pb-10 pt-[26px] flex flex-col gap-10 items-center max-h-vh overflow-auto" ]
        [ logoView model
        , H.div [ HA.class "flex flex-col items-center gap-6" ]
            ((tickData |> H.viewMaybe (nextTickView model.zone model.time))
                :: leftNav
            )
        ]


nextTickView :
    Time.Zone
    -> Posix
    ->
        { tickFrequency : Time.Interval
        , worldName : String
        }
    -> Html FrontendMsg
nextTickView zone time { tickFrequency, worldName } =
    let
        millis =
            Time.posixToMillis time
    in
    -- The -0.5px is a hack to prevent text on Windows from being blurry (basically aligning it back to the pixel grid)
    H.div [ HA.class "grid grid-cols-2 gap-x-[1ch] -translate-x-[0.5px]" ] <|
        List.fastConcat
            [ [ H.span
                    [ HA.class "text-green-300 text-right" ]
                    [ H.text "World:" ]
              , H.span [] [ H.text worldName ]
              ]
            , if millis == 0 then
                []

              else
                let
                    nextTick =
                        Tick.nextTick tickFrequency time

                    nextTickString =
                        DateFormat.format
                            [ DateFormat.hourMilitaryFixed
                            , DateFormat.text ":"
                            , DateFormat.minuteFixed
                            , DateFormat.text ":"
                            , DateFormat.secondFixed
                            ]
                            zone
                            nextTick
                in
                [ H.span
                    [ HA.class "text-green-300 text-right" ]
                    [ H.text "Next tick:" ]
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text nextTickString ]
                ]
            ]


contentView : Model -> Html FrontendMsg
contentView model =
    let
        withCreatedPlayer :
            PlayerData
            -> (PlayerData -> CPlayer -> List (Html FrontendMsg))
            -> List (Html FrontendMsg)
        withCreatedPlayer data fn =
            case data.player of
                NeedsCharCreated _ ->
                    contentUnavailableToNonCreatedView

                Player cPlayer ->
                    fn data cPlayer

        withLocation :
            PlayerData
            -> (Location -> PlayerData -> CPlayer -> List (Html FrontendMsg))
            -> List (Html FrontendMsg)
        withLocation data fn =
            data.player
                |> Player.getPlayerData
                |> Maybe.andThen (.location >> Location.location)
                |> Maybe.map (\loc -> withCreatedPlayer data (fn loc))
                |> Maybe.withDefault contentUnavailableWhenNotInTownView
    in
    H.div [ HA.class "pt-8 px-10 pb-10 flex flex-col flex-1 items-start overflow-auto max-h-vh" ]
        (case ( model.route, model.worldData ) of
            ( AdminRoute subroute, IsAdmin data ) ->
                case subroute of
                    AdminWorldsList ->
                        adminWorldsListView model.adminNewWorldName model.adminNewWorldFast data

                    AdminWorldActivity worldName ->
                        adminWorldActivityView model.lastTenToBackendMsgs worldName data

                    AdminWorldHiscores worldName ->
                        adminWorldHiscoresView worldName data

                    AdminBackendModelEditor ->
                        adminFusionEditorView model.fusionBackendModel

            ( AdminRoute _, _ ) ->
                contentUnavailableToNonAdminView

            ( About, _ ) ->
                aboutView

            ( News, _ ) ->
                newsView model.zone

            ( WorldsList, _ ) ->
                worldsListView model.worlds

            ( NotFound url, _ ) ->
                notFoundView url

            ( Map, IsPlayer data ) ->
                withCreatedPlayer data (mapView model)

            ( Map, _ ) ->
                mapLoggedOutView

            ( PlayerRoute worldRoute, IsPlayer data ) ->
                let
                    withCreatedPlayer_ :
                        (PlayerData -> CPlayer -> List (Html FrontendMsg))
                        -> List (Html FrontendMsg)
                    withCreatedPlayer_ =
                        withCreatedPlayer data

                    withLocation_ :
                        (Location -> PlayerData -> CPlayer -> List (Html FrontendMsg))
                        -> List (Html FrontendMsg)
                    withLocation_ =
                        withLocation data
                in
                case worldRoute of
                    Route.AboutWorld ->
                        withCreatedPlayer_ aboutWorldView

                    Route.Character ->
                        withCreatedPlayer_ (characterView model.hoveredItem)

                    Route.Inventory ->
                        withCreatedPlayer_ inventoryView

                    Route.Ladder ->
                        withCreatedPlayer_ ladderView

                    Route.TownMainSquare ->
                        withLocation_ (townMainSquareView model.expandedQuests)

                    Route.TownStore shop ->
                        withLocation_ (townStoreView model.barter shop)

                    Route.Fight ->
                        withCreatedPlayer_ (fightView model.fightInfo)

                    Route.Messages ->
                        withCreatedPlayer_ (messagesView model.time model.zone)

                    Route.Message messageId ->
                        withCreatedPlayer_ (messageView model.zone messageId)

                    Route.CharCreation ->
                        newCharView model.hoveredItem model.newChar

                    Route.SettingsFightStrategy ->
                        withCreatedPlayer_ <|
                            settingsFightStrategyView
                                model.fightStrategyText

                    Route.SettingsFightStrategySyntaxHelp ->
                        settingsFightStrategySyntaxHelpView model.hoveredItem

            ( PlayerRoute _, _ ) ->
                contentUnavailableToLoggedOutView
        )


pageTitleView : String -> Html FrontendMsg
pageTitleView title =
    H.h2
        [ HA.class "text-lg font-extraBold mb-10" ]
        [ H.text title ]


aboutView : List (Html FrontendMsg)
aboutView =
    [ pageTitleView "About"
    , H.div [ HA.class "flex flex-col gap-4 max-w-[60ch]" ]
        [ H.p []
            [ H.text "Welcome to "
            , H.span [ HA.class "text-green-100" ] [ H.text "NuAshworld" ]
            , H.text " - a multiplayer turn-based browser game set in the universe of Fallout 2."
            ]
        , H.p []
            [ H.text "Do you have what it takes to survive in the post-apocalyptic wasteland? Can you shape the world for the better?"
            ]
        , H.p []
            [ H.text "What more, "
            , H.span [ HA.class "text-green-100" ] [ H.text "can you stand up to the Enclave?" ]
            ]
        ]
    ]


worldsListView : Maybe (List WorldInfo) -> List (Html FrontendMsg)
worldsListView worlds =
    case worlds of
        Nothing ->
            contentUnavailableView "list of worlds didn't load"

        Just worlds_ ->
            [ pageTitleView "Worlds"
            , H.div [ HA.class "flex flex-row flex-wrap gap-4" ]
                (worlds_
                    |> List.sortBy
                        (\w ->
                            if w.name == Logic.mainWorldName then
                                0

                            else
                                1
                        )
                    |> List.map
                        (\world ->
                            H.div [ HA.class "bg-green-800 p-[2ch]" ]
                                [ worldInfoView
                                    { name = world.name
                                    , description = world.description
                                    , startedAt = world.startedAt
                                    , tickFrequency = world.tickFrequency
                                    , tickPerIntervalCurve = world.tickPerIntervalCurve
                                    , vendorRestockFrequency = world.vendorRestockFrequency
                                    , playersCount = world.playersCount
                                    }
                                ]
                        )
                )
            ]


notFoundView : Url -> List (Html FrontendMsg)
notFoundView url =
    [ pageTitleView "Not found"
    , """
Page `{URL}` not found.
"""
        |> String.replace "{URL}" (Url.toString url)
        |> Markdown.toHtml [ HA.id "not-found-content" ]
    ]


adminMapView : World.Name -> AdminData -> Html FrontendMsg
adminMapView worldName adminData =
    case Dict.get worldName adminData.worlds of
        Nothing ->
            H.text <| "Error: World '" ++ worldName ++ "' was not found"

        Just world ->
            let
                playerCoords : List TileCoords
                playerCoords =
                    world.players
                        |> Dict.values
                        |> List.filterMap Player.getPlayerData
                        |> List.map (.location >> Map.toTileCoords)
            in
            H.div
                [ cssVars
                    [ ( "--map-columns", String.fromInt Map.columns )
                    , ( "--map-rows", String.fromInt Map.rows )
                    , ( "--map-cell-size", String.fromInt Map.tileSize ++ "px" )
                    ]
                , HA.class "relative bg-black bg-[url('/images/map_whole.webp')] bg-[0_0] bg-no-repeat select-none"
                , HA.class "min-w-[calc(var(--map-columns)*var(--map-cell-size))]"
                , HA.class "max-w-[calc(var(--map-columns)*var(--map-cell-size))]"
                , HA.class "min-h-[calc(var(--map-rows)*var(--map-cell-size))]"
                , HA.class "max-h-[calc(var(--map-rows)*var(--map-cell-size))]"
                ]
                (locationsView
                    :: List.map mapMarkerView playerCoords
                )


mapView :
    { model
        | mapMouseCoords : Maybe ( TileCoords, Set TileCoords )
        , userWantsToShowAreaDanger : Bool
    }
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
mapView { mapMouseCoords, userWantsToShowAreaDanger } _ player =
    let
        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                }

        playerCoords : TileCoords
        playerCoords =
            Map.toTileCoords player.location

        mouseRelatedView : ( TileCoords, Set TileCoords ) -> Html FrontendMsg
        mouseRelatedView ( ( x, y ) as mouseCoords, pathTaken ) =
            let
                impassableTiles : Set TileCoords
                impassableTiles =
                    pathTaken
                        |> Set.filter (Terrain.forCoords >> Terrain.isPassable >> not)

                notAllPassable : Bool
                notAllPassable =
                    not (Set.isEmpty impassableTiles)

                cost : Int
                cost =
                    Pathfinding.tickCost
                        { pathTaken = pathTaken
                        , pathfinderPerkRanks = Perk.rank Perk.Pathfinder player.perks
                        }

                tooDistant : Bool
                tooDistant =
                    cost > player.ticks

                ticksString : String
                ticksString =
                    if cost == 1 then
                        "tick"

                    else
                        "ticks"

                bigChunk : BigChunk
                bigChunk =
                    BigChunk.forCoords mouseCoords

                impossiblePath : Bool
                impossiblePath =
                    tooDistant || notAllPassable

                ( pathTextColor, pathBgColor ) =
                    if impossiblePath then
                        ( "text-yellow", "bg-yellow" )

                    else
                        ( "text-green-200", "bg-green-300" )

                tileUnderCursor =
                    H.div
                        [ tileClass
                        , HA.class
                            (if Set.member mouseCoords impassableTiles then
                                "bg-red"

                             else
                                pathBgColor
                            )
                        , HA.class "opacity-75 pointer-events-none z-[1]"
                        , cssVars
                            [ ( "--tile-coord-x", String.fromInt x )
                            , ( "--tile-coord-y", String.fromInt y )
                            ]
                        ]
                        []

                pathTiles =
                    H.div
                        [ HA.class "absolute inset-0" ]
                        (List.map (pathTileView pathBgColor impassableTiles)
                            (Set.toList (Set.remove mouseCoords pathTaken))
                        )

                tooltip =
                    H.div
                        [ HA.class "w-fit whitespace-nowrap p-5 bg-green-900 relative z-[3]"
                        , HA.class pathTextColor
                        , HA.class "translate-x-[calc(var(--map-cell-size)*(0.5+var(--tile-coord-x))-50%)]"
                        , HA.class "translate-y-[calc(var(--map-cell-size)*var(--tile-coord-y)-100%-10px)]"
                        , cssVars
                            [ ( "--tile-coord-x", String.fromInt x )
                            , ( "--tile-coord-y", String.fromInt y )
                            ]
                        ]
                        [ if notAllPassable then
                            H.text "Not all tiles in your path are passable."

                          else
                            H.div []
                                [ H.div [] [ H.text <| "Path cost: " ++ String.fromInt cost ++ " " ++ ticksString ]
                                , H.viewIf tooDistant <|
                                    H.div [] [ H.text "You don't have enough ticks." ]
                                , H.viewIf canShowAreaDanger <|
                                    H.div [] [ H.text <| "Map area danger: " ++ BigChunk.difficulty bigChunk ]
                                ]
                        ]
            in
            H.div
                [ HA.class "absolute inset-0" ]
                [ tileUnderCursor
                , pathTiles
                , tooltip
                    |> H.viewIf (Perception.atLeast Perception.Good perceptionLevel)
                ]

        pathTileView : String -> Set TileCoords -> TileCoords -> Html FrontendMsg
        pathTileView pathBgColor impassableTiles (( x, y ) as coord) =
            H.div
                [ HA.class
                    (if Set.member coord impassableTiles then
                        "bg-red"

                     else
                        pathBgColor
                    )
                , HA.class "opacity-50 pointer-events-none z-[1]"
                , tileClass
                , cssVars
                    [ ( "--tile-coord-x", String.fromInt x )
                    , ( "--tile-coord-y", String.fromInt y )
                    ]
                ]
                []

        mouseCoordsOnly : Maybe TileCoords
        mouseCoordsOnly =
            Maybe.map Tuple.first mapMouseCoords

        mouseEventCatcherView : Html FrontendMsg
        mouseEventCatcherView =
            H.div
                [ HA.class "absolute inset-0 z-[4]"
                , HE.stopPropagationOn "mouseover"
                    (JD.map (\c -> ( MapMouseAtCoords c, True )) <|
                        changedCoordsDecoder mouseCoordsOnly
                    )
                , HE.stopPropagationOn "mousemove"
                    (JD.map (\c -> ( MapMouseAtCoords c, True )) <|
                        changedCoordsDecoder mouseCoordsOnly
                    )
                , HE.onMouseOut MapMouseOut
                , HE.onClick MapMouseClick
                ]
                []

        bigChunkColor : BigChunk -> String
        bigChunkColor bigChunk =
            case bigChunk of
                C1 ->
                    "lime"

                C2 ->
                    "yellow"

                C3 ->
                    "yellow"

                C4 ->
                    "red"

                C5 ->
                    "purple"

        bigChunkLayerView : () -> Html FrontendMsg
        bigChunkLayerView () =
            S.svg
                [ SA.viewBox <| "0 0 " ++ String.fromInt Map.columns ++ " " ++ String.fromInt Map.rows
                ]
                (BigChunk.all
                    |> List.map
                        (\chunk ->
                            let
                                tiles : List TileCoords
                                tiles =
                                    BigChunk.tileCoords chunk
                            in
                            svgPolygonForTiles (bigChunkColor chunk) tiles
                        )
                )

        canShowAreaDanger : Bool
        canShowAreaDanger =
            Perception.atLeast Perception.Perfect perceptionLevel

        showAreaDanger : Bool
        showAreaDanger =
            canShowAreaDanger && userWantsToShowAreaDanger
    in
    [ pageTitleView "Map"
    , H.div [ HA.class "flex flex-col items-start gap-4" ]
        [ H.viewIf canShowAreaDanger <|
            UI.checkbox
                { isOn = userWantsToShowAreaDanger
                , toggle = SetShowAreaDanger
                , label = "Show area danger levels"
                }
        , H.div
            [ cssVars
                [ ( "--map-columns", String.fromInt Map.columns )
                , ( "--map-rows", String.fromInt Map.rows )
                , ( "--map-cell-size", String.fromInt Map.tileSize ++ "px" )
                ]
            , HA.class "relative bg-black bg-[url('/images/map_whole.webp')] bg-[0_0] bg-no-repeat select-none"
            , HA.class "min-w-[calc(var(--map-columns)*var(--map-cell-size))]"
            , HA.class "max-w-[calc(var(--map-columns)*var(--map-cell-size))]"
            , HA.class "min-h-[calc(var(--map-rows)*var(--map-cell-size))]"
            , HA.class "max-h-[calc(var(--map-rows)*var(--map-cell-size))]"
            ]
            [ locationsView
            , mapMarkerView playerCoords
            , bigChunkLayerView
                |> H.viewIfLazy showAreaDanger
            , mouseEventCatcherView
            , H.viewMaybe mouseRelatedView mapMouseCoords
            ]
        ]
    ]


svgPolygonForTiles : String -> List TileCoords -> Svg FrontendMsg
svgPolygonForTiles color coords =
    let
        rectangle : TileCoords -> String
        rectangle ( x, y ) =
            let
                left =
                    String.fromInt x

                top =
                    String.fromInt y
            in
            [ "M " ++ left ++ "," ++ top
            , "h 1"
            , "v 1"
            , "h -1"
            , "v -1"
            ]
                |> String.join " "

        path : String
        path =
            coords
                |> List.map rectangle
                |> String.join " "
    in
    S.path
        [ SA.d path
        , SA.fill color
        , SA.fillOpacity "0.25"
        ]
        []


tileClass : Attribute msg
tileClass =
    HA.class "absolute left-0 top-0 w-[var(--map-cell-size)] h-[var(--map-cell-size)] translate-x-[calc(var(--map-cell-size)*var(--tile-coord-x))] translate-y-[calc(var(--map-cell-size)*var(--tile-coord-y))]"


locationView : Location -> Html FrontendMsg
locationView location =
    let
        ( x, y ) =
            Location.coords location

        size : Location.Size
        size =
            Location.size location

        name : String
        name =
            Location.name location

        borderWidth : String
        borderWidth =
            case size of
                Location.Small ->
                    "border"

                Location.Middle ->
                    "border"

                Location.Large ->
                    "border-2"
    in
    H.div
        [ tileClass
        , HA.class "text-green-100 absolute inset-0"
        , HA.attribute "data-location-name" name
        , TW.mod "before" <|
            "absolute top-1/2 left-1/2 content-[''] block w-[var(--location-size)] h-[var(--location-size)] border-green-100 rounded-full -translate-x-1/2 -translate-y-1/2 bg-[radial-gradient(circle,var(--green-100-fully-transparent)_0%,var(--green-100-half-transparent)_100%)] "
                ++ borderWidth
        , TW.mod "after" "content-[attr(data-location-name)] block top-[var(--location-name-top)] left-1/2 -translate-x-1/2 text-center absolute whitespace-nowrap bg-black-transparent p-x-1 leading-[13px]"
        , HA.style "text-shadow" "2px 0 2px #000, 0 2px 2px #000, -2px 0 2px #000, 0 -2px 2px #000"
        , cssVars <|
            List.fastConcat
                [ [ ( "--tile-coord-x", String.fromInt x )
                  , ( "--tile-coord-y", String.fromInt y )
                  ]
                , case size of
                    Location.Small ->
                        [ ( "--location-size", "11px" )
                        , ( "--location-name-top", "68%" )
                        ]

                    Location.Middle ->
                        [ ( "--location-size", "23px" )
                        , ( "--location-name-top", "75%" )
                        ]

                    Location.Large ->
                        [ ( "--location-size", "45px" )
                        , ( "--location-name-top", "100%" )
                        ]
                ]
        ]
        []


locationsView : Html FrontendMsg
locationsView =
    Location.allLocations
        |> List.map locationView
        |> H.div [ HA.class "absolute inset-0 bg-black-transparent" ]


changedCoordsDecoder : Maybe TileCoords -> Decoder TileCoords
changedCoordsDecoder mouseCoords =
    JD.map2 Tuple.pair
        (JD.field "offsetX" JD.int)
        (JD.field "offsetY" JD.int)
        |> JD.andThen
            (\( x, y ) ->
                let
                    newCoords =
                        ( x // Map.tileSize
                        , y // Map.tileSize
                        )
                in
                case mouseCoords of
                    Nothing ->
                        JD.succeed newCoords

                    Just oldCoords ->
                        if oldCoords == newCoords then
                            JD.fail "no change"

                        else
                            JD.succeed newCoords
            )


mapMarkerView : TileCoords -> Html FrontendMsg
mapMarkerView ( x, y ) =
    H.img
        [ HA.class "absolute left-0 top-0 z-[2]"
        , HA.class "translate-x-[calc(var(--map-cell-size)*(0.5+var(--player-coord-x))-50%)]"
        , HA.class "translate-y-[calc(var(--map-cell-size)*(0.5+var(--player-coord-y))-50%)]"
        , cssVars
            [ ( "--player-coord-x", String.fromInt x )
            , ( "--player-coord-y", String.fromInt y )
            ]
        , HA.src "/images/map_marker.webp"
        , HA.width 25
        , HA.height 13
        ]
        []


cssVars : List ( String, String ) -> Attribute FrontendMsg
cssVars vars =
    vars
        |> List.map (\( var, value ) -> var ++ ": " ++ value)
        |> String.join ";"
        |> HA.attribute "style"


mapLoggedOutView : List (Html FrontendMsg)
mapLoggedOutView =
    [ pageTitleView "Map"
    , H.div [ HA.class "flex flex-col items-start gap-4" ]
        [ H.div
            [ cssVars
                [ ( "--map-columns", String.fromInt Map.columns )
                , ( "--map-rows", String.fromInt Map.rows )
                , ( "--map-cell-size", String.fromInt Map.tileSize ++ "px" )
                ]
            , HA.class "relative bg-black bg-[url('/images/map_whole.webp')] bg-[0_0] bg-no-repeat select-none"
            , HA.class "min-w-[calc(var(--map-columns)*var(--map-cell-size))]"
            , HA.class "max-w-[calc(var(--map-columns)*var(--map-cell-size))]"
            , HA.class "min-h-[calc(var(--map-rows)*var(--map-cell-size))]"
            , HA.class "max-h-[calc(var(--map-rows)*var(--map-cell-size))]"
            ]
            [ locationsView ]
        ]
    ]


questProgressbarView :
    { ticksGiven : Int
    , ticksNeeded : Int
    , ticksGivenByPlayer : Int
    }
    -> Html FrontendMsg
questProgressbarView { ticksGiven, ticksNeeded, ticksGivenByPlayer } =
    let
        percentDone : Float
        percentDone =
            toFloat ticksGiven / toFloat ticksNeeded

        totalCount : Int
        totalCount =
            20

        doneCount : Int
        doneCount =
            clamp 0 totalCount <|
                round (toFloat totalCount * percentDone)

        emptyCount : Int
        emptyCount =
            totalCount - doneCount
    in
    H.div [ HA.class "flex flex-row gap-[1ch]" ]
        [ H.span [ HA.class "text-green-300" ]
            [ H.text <|
                "["
                    ++ String.repeat doneCount "="
                    ++ String.repeat emptyCount "-"
                    ++ "]"
            ]
        , H.text <|
            String.fromInt (round (percentDone * 100))
                ++ "%"
                ++ " done ("
                ++ String.fromInt ticksGiven
                ++ "/"
                ++ String.fromInt ticksNeeded
                ++ " ticks, you gave "
                ++ String.fromInt ticksGivenByPlayer
                ++ ")"
        ]


townMainSquareView : SeqSet Quest.Name -> Location -> PlayerData -> CPlayer -> List (Html FrontendMsg)
townMainSquareView expandedQuests location { questsProgress, questRewardShops } player =
    let
        quests : List Quest.Name
        quests =
            Quest.allForLocation location

        hasQuests : Bool
        hasQuests =
            not <| List.isEmpty quests

        availableShops : List Shop
        availableShops =
            Shop.forLocation location
                |> List.filter (Shop.isAvailable questRewardShops)
    in
    [ pageTitleView <| "Town: " ++ Location.name location
    , H.div [ HA.class "flex flex-col gap-4" ]
        [ if List.isEmpty availableShops then
            H.div [] [ H.text "No vendor in this town..." ]

          else
            availableShops
                |> List.map
                    (\shop ->
                        H.div [ HA.class "flex flex-row gap-[1ch]" ]
                            [ H.text <| Shop.personName shop
                            , UI.button
                                [ HE.onClick <| GoToTownStore shop ]
                                [ H.text "[Visit store]" ]
                            ]
                    )
                |> H.div [ HA.class "flex flex-col" ]
        , if hasQuests then
            H.h3 [] [ H.text "Quests" ]

          else
            H.text "No quests in this town..."
        , H.viewIf hasQuests <|
            H.ul []
                (quests
                    |> List.map (questView player questsProgress expandedQuests)
                )
        ]
    ]


questView : CPlayer -> SeqDict Quest.Name Quest.Progress -> SeqSet Quest.Name -> Quest.Name -> Html FrontendMsg
questView player questsProgress expandedQuests quest =
    case SeqDict.get quest questsProgress of
        Nothing ->
            H.text "BUG: couldn't get quest progress, please report this"

        Just progress ->
            let
                isExpanded : Bool
                isExpanded =
                    SeqSet.member quest expandedQuests
            in
            H.li
                [ HA.classList
                    [ ( "[&:not(:last-child)]:mb-5", isExpanded ) ]
                ]
                (if isExpanded then
                    expandedQuestView player progress quest

                 else
                    collapsedQuestView quest
                )


collapsedQuestView : Quest.Name -> List (Html FrontendMsg)
collapsedQuestView quest =
    [ H.span
        [ HA.class "cursor-pointer"
        , TW.mod "hover" "text-green-100 bg-green-800"
        , HE.onClick (ExpandQuestItem quest)
        ]
        [ H.span
            [ HA.class "text-green-100 pr-2" ]
            [ H.text "[+]" ]
        , H.text <| Quest.title quest
        ]
    ]


expandedQuestView : CPlayer -> Quest.Progress -> Quest.Name -> List (Html FrontendMsg)
expandedQuestView player progress quest =
    let
        liText : String -> Html FrontendMsg
        liText text =
            H.li [] [ H.text text ]

        questRequirements : List Quest.Name
        questRequirements =
            Quest.questRequirements quest

        playerRequirements : List Quest.PlayerRequirement
        playerRequirements =
            Quest.playerRequirements quest

        globalRewards : List Quest.GlobalReward
        globalRewards =
            Quest.globalRewards quest

        playerRewards : List Quest.PlayerReward
        playerRewards =
            Quest.playerRewards quest

        ticksNeeded : Int
        ticksNeeded =
            Quest.ticksNeeded quest
    in
    [ H.div [ HA.class "flex flex-col gap-[2ch]" ]
        [ H.div []
            [ H.span
                [ HE.onClick <| CollapseQuestItem quest
                , HA.class "cursor-pointer"
                , TW.mod "hover" "text-green-100 bg-green-800"
                ]
                [ H.span
                    [ HA.class "text-green-100 pr-2" ]
                    [ H.text "["
                    , H.span [ HA.class "min-w-[1ch] text-center inline-block" ] [ H.text "-" ]
                    , H.text "]"
                    ]
                , H.text <| Quest.title quest
                ]
            , if SeqSet.member quest player.questsActive then
                UI.button
                    [ HA.class "ml-[1ch] !text-green-100"
                    , TW.mod "hover" "text-yellow"
                    , HE.onClickStopPropagation <| AskToStopProgressing quest
                    ]
                    [ H.text "[STOP]" ]

              else
                UI.button
                    [ HA.class "ml-[1ch] !text-green-100"
                    , TW.mod "hover" "text-yellow"
                    , HE.onClickStopPropagation <| AskToStartProgressing quest
                    ]
                    [ H.text "[START]" ]
            ]
        , H.div [ HA.class "bg-green-800 p-[2ch]" ]
            [ questProgressbarView
                { ticksGiven = progress.ticksGiven
                , ticksNeeded = ticksNeeded
                , ticksGivenByPlayer = progress.ticksGivenByPlayer
                }
            , H.div []
                [ H.text <|
                    "Players active: "
                        ++ String.fromInt progress.playersActive
                        ++ " ("
                        ++ String.fromInt progress.ticksPerHour
                        ++ " ticks/hour)"
                ]
            , H.div []
                [ H.text <|
                    "XP per tick: "
                        ++ String.fromInt (Quest.xpPerTickGiven quest)
                ]
            , H.div
                [ HA.class "mt-5" ]
                [ H.text "Quest Requirements" ]
            , if List.isEmpty questRequirements then
                H.div
                    [ HA.class "ml-[4ch]" ]
                    [ H.text "NONE" ]

              else
                H.ul
                    [ HA.class "ps-[4ch]" ]
                    (List.map (Quest.title >> liText) questRequirements)
            , H.div
                [ HA.class "mt-5" ]
                [ H.text "Player Requirements (affect ticks/hour)" ]
            , if List.isEmpty playerRequirements then
                H.div
                    [ HA.class "ml-[4ch]" ]
                    [ H.text "NONE" ]

              else
                H.ul
                    [ HA.class "ps-[4ch]" ]
                    (List.map (Quest.playerRequirementTitle >> liText) playerRequirements)
            , H.div
                [ HA.class "mt-5" ]
                [ H.text "Global Rewards" ]
            , if List.isEmpty globalRewards then
                H.div
                    [ HA.class "ml-[4ch]" ]
                    [ H.text "NONE" ]

              else
                H.ul
                    [ HA.class "ps-[4ch]" ]
                    (List.map (Quest.globalRewardTitle >> liText) globalRewards)
            , H.div
                [ HA.class "mt-5" ]
                (if List.isEmpty playerRewards then
                    [ H.text "Player Rewards" ]

                 else
                    [ H.text "Player Rewards"
                    , H.text " (if you give "
                    , H.span
                        []
                        [ H.text <|
                            String.fromInt (Quest.ticksNeededForPlayerReward quest)
                                ++ "+"
                        ]
                    , H.text " ticks)"
                    ]
                )
            , if List.isEmpty playerRewards then
                H.div
                    [ HA.class "ml-[4ch]" ]
                    [ H.text "NONE" ]

              else
                H.ul
                    [ HA.class "ps-[4ch]" ]
                    (List.map (Quest.playerRewardTitle >> liText) playerRewards)
            ]
        ]
    ]


townStoreView :
    Barter.State
    -> Shop
    -> Location
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
townStoreView barter shop location world player =
    if Shop.isInLocation location shop then
        if Shop.isAvailable world.questRewardShops shop then
            let
                vendor : Vendor
                vendor =
                    Vendor.getFrom world.vendors shop
            in
            let
                playerKeptCaps : Int
                playerKeptCaps =
                    player.caps - barter.playerCaps

                vendorKeptCaps : Int
                vendorKeptCaps =
                    vendor.caps - barter.vendorCaps

                playerTradedCaps : Int
                playerTradedCaps =
                    barter.playerCaps

                vendorTradedCaps : Int
                vendorTradedCaps =
                    barter.vendorCaps

                playerTradedItemsValue : Int
                playerTradedItemsValue =
                    playerTradedItems
                        |> List.filterMap
                            (\( id, count ) ->
                                Dict.get id player.items
                                    |> Maybe.map (\{ kind } -> ItemKind.baseValue kind * count)
                            )
                        |> List.sum

                playerTradedValue : Int
                playerTradedValue =
                    barter.playerCaps + playerTradedItemsValue

                vendorTradedItemsValue : Int
                vendorTradedItemsValue =
                    vendorTradedItems
                        |> List.filterMap
                            (\( id, count ) ->
                                Dict.get id vendor.items
                                    |> Maybe.map
                                        (\{ kind } ->
                                            Logic.price
                                                { baseValue = count * ItemKind.baseValue kind
                                                , playerBarterSkill = Skill.get player.special player.addedSkillPercentages Skill.Barter
                                                , traderBarterSkill = Shop.barterSkill vendor.shop
                                                , hasMasterTraderPerk = Perk.rank Perk.MasterTrader player.perks > 0
                                                , discountPct = vendor.discountPct
                                                }
                                        )
                            )
                        |> List.sum

                vendorTradedValue : Int
                vendorTradedValue =
                    barter.vendorCaps + vendorTradedItemsValue

                playerKeptItems : List ( Item.Id, Int )
                playerKeptItems =
                    player.items
                        |> Dict.filterMap
                            (\itemId item ->
                                case Dict.get itemId barter.playerItems of
                                    Nothing ->
                                        -- player is not trading this item at all
                                        Just item.count

                                    Just tradedCount ->
                                        if tradedCount >= item.count then
                                            -- player is trading it all!
                                            Nothing

                                        else
                                            -- what amount does player have left in the inventory
                                            Just <| item.count - tradedCount
                            )
                        |> Dict.toList

                vendorKeptItems : List ( Item.Id, Int )
                vendorKeptItems =
                    vendor.items
                        |> Dict.filterMap
                            (\itemId item ->
                                case Dict.get itemId barter.vendorItems of
                                    Nothing ->
                                        -- vendor is not trading this item at all
                                        Just item.count

                                    Just tradedCount ->
                                        if tradedCount >= item.count then
                                            -- vendor is trading it all!
                                            Nothing

                                        else
                                            -- what amount does vendor have left in the inventory
                                            Just <| item.count - tradedCount
                            )
                        |> Dict.toList

                playerTradedItems : List ( Item.Id, Int )
                playerTradedItems =
                    Dict.toList barter.playerItems

                vendorTradedItems : List ( Item.Id, Int )
                vendorTradedItems =
                    Dict.toList barter.vendorItems

                resetBtn : Html FrontendMsg
                resetBtn =
                    UI.button
                        [ HA.style "grid-area" "barter-reset-btn"
                        , HE.onClick <| BarterMsg ResetBarter
                        ]
                        [ H.text "[Reset]" ]

                confirmBtn : Html FrontendMsg
                confirmBtn =
                    UI.button
                        [ HA.style "grid-area" "barter-confirm-btn"
                        , HE.onClick <| BarterMsg (ConfirmBarter shop)
                        ]
                        [ H.text "[Confirm]" ]

                capsView :
                    { itemLabelClass : String
                    , gridArea : String
                    , transfer : Int -> FrontendMsg
                    , transferNPosition : Barter.TransferNPosition
                    }
                    -> Int
                    -> Html FrontendMsg
                capsView { itemLabelClass, gridArea, transfer, transferNPosition } caps =
                    let
                        capsString : String
                        capsString =
                            String.fromInt caps

                        arrowsDirection : Barter.ArrowsDirection
                        arrowsDirection =
                            Barter.arrowsDirection transferNPosition

                        transferNValue : String
                        transferNValue =
                            SeqDict.get transferNPosition barter.transferNInputs
                                |> Maybe.withDefault Barter.defaultTransferN

                        isNActive : Bool
                        isNActive =
                            barter.activeN == Just transferNPosition

                        transferNView =
                            if isNActive then
                                H.div
                                    [ HA.class "flex" ]
                                    [ UI.input
                                        [ HA.class "w-10 bg-green-800 pl-[6px]"
                                        , HA.value transferNValue
                                        , HE.onInput <| BarterMsg << SetTransferNInput transferNPosition
                                        , HA.title "Transfer N caps"
                                        ]
                                        []
                                    , case String.toInt transferNValue of
                                        Nothing ->
                                            UI.highContrastButton
                                                [ HA.disabled True
                                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                                , HA.title "Transfer N caps"
                                                ]
                                                [ H.text "OK" ]

                                        Just n ->
                                            UI.highContrastButton
                                                [ HE.onClick <| transfer n
                                                , HA.disabled <| n <= 0 || n > caps
                                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                                , HA.title "Transfer N caps"
                                                ]
                                                [ H.text "OK" ]
                                    , UI.highContrastButton
                                        [ HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200 block"
                                        , HA.title "Close the N input"
                                        , HE.onClick <| BarterMsg UnsetTransferNActive
                                        ]
                                        [ H.text "X" ]
                                    ]

                            else
                                UI.highContrastButton
                                    [ HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                    , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                    , HA.disabled <| caps <= 0
                                    , HA.title "Transfer N items"
                                    , HE.onClick <| BarterMsg <| SetTransferNActive transferNPosition
                                    ]
                                    [ H.text "N" ]

                        transferOneView =
                            UI.highContrastButton
                                [ HE.onClick <| transfer 1
                                , HA.disabled <| caps <= 0
                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                , HA.classList [ ( "hidden", isNActive ) ]
                                , HA.title "Transfer 1 cap"
                                ]
                                [ H.text <| Barter.singleArrow arrowsDirection ]

                        transferAllView =
                            UI.highContrastButton
                                [ HE.onClick <| transfer caps
                                , HA.disabled <| caps <= 0
                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                , HA.classList [ ( "hidden", isNActive ) ]
                                , HA.title "Transfer all caps"
                                ]
                                [ H.text <| Barter.doubleArrow arrowsDirection ]

                        itemView =
                            H.span
                                [ HA.class <| "flex-1 " ++ itemLabelClass ]
                                [ H.text <| "Caps: $" ++ capsString ]
                    in
                    H.div
                        [ HA.class "flex items-center px-2 pt-1 pb-0.5"
                        , TW.mod "[&[data-caps='0']]" "text-green-300"
                        , HA.style "grid-area" gridArea
                        , HA.attribute "data-caps" capsString
                        ]
                    <|
                        case arrowsDirection of
                            Barter.ArrowLeft ->
                                [ transferAllView
                                , transferNView
                                , transferOneView
                                , itemView
                                ]

                            Barter.ArrowRight ->
                                [ itemView
                                , transferOneView
                                , transferNView
                                , transferAllView
                                ]

                playerItemView :
                    { items : Dict Item.Id Item
                    , itemLabelClass : String
                    , transfer : Item.Id -> Int -> FrontendMsg
                    , transferNPosition : Item.Id -> Barter.TransferNPosition
                    }
                    -> ( Item.Id, Int )
                    -> Html FrontendMsg
                playerItemView { items, itemLabelClass, transfer, transferNPosition } ( id, count ) =
                    let
                        itemName =
                            case Dict.get id items of
                                Nothing ->
                                    "<BUG>"

                                Just item ->
                                    ItemKind.name item.kind

                        position : Barter.TransferNPosition
                        position =
                            transferNPosition id

                        arrowsDirection : Barter.ArrowsDirection
                        arrowsDirection =
                            Barter.arrowsDirection position

                        transferNValue : String
                        transferNValue =
                            SeqDict.get position barter.transferNInputs
                                |> Maybe.withDefault Barter.defaultTransferN

                        isNActive : Bool
                        isNActive =
                            barter.activeN == Just (transferNPosition id)

                        transferNView =
                            if isNActive then
                                H.div
                                    [ HA.class "flex" ]
                                    [ UI.input
                                        [ HA.class "w-10 bg-green-800 pl-[6px]"
                                        , HA.value transferNValue
                                        , HE.onInput <| BarterMsg << SetTransferNInput position
                                        , HA.title "Transfer N items"
                                        ]
                                        []
                                    , case String.toInt transferNValue of
                                        Nothing ->
                                            UI.highContrastButton
                                                [ HA.disabled True
                                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                                , HA.title "Transfer N items"
                                                ]
                                                [ H.text "OK" ]

                                        Just n ->
                                            UI.highContrastButton
                                                [ HE.onClick <| transfer id n
                                                , HA.disabled <| n <= 0 || n > count
                                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                                , HA.title "Transfer N items"
                                                ]
                                                [ H.text "OK" ]
                                    , UI.highContrastButton
                                        [ HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200 block"
                                        , HA.title "Close the N input"
                                        , HE.onClick <| BarterMsg UnsetTransferNActive
                                        ]
                                        [ H.text "X" ]
                                    ]

                            else
                                UI.highContrastButton
                                    [ HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                    , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                    , HA.disabled <| count <= 0
                                    , HA.title "Transfer N items"
                                    , HE.onClick <| BarterMsg <| SetTransferNActive (transferNPosition id)
                                    ]
                                    [ H.text "N" ]

                        transferOneView =
                            UI.highContrastButton
                                [ HE.onClick <| transfer id 1
                                , HA.disabled <| count <= 0
                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                , HA.classList [ ( "hidden", isNActive ) ]
                                , HA.title "Transfer 1 item"
                                ]
                                [ H.text <| Barter.singleArrow arrowsDirection ]

                        transferAllView =
                            UI.highContrastButton
                                [ HE.onClick <| transfer id count
                                , HA.disabled <| count <= 0
                                , HA.class "py-0.5 px-1 mx-1 bg-green-800 text-green-200"
                                , TW.mod "disabled" "text-green-300 opacity-50 pointer-events-none"
                                , HA.classList [ ( "hidden", isNActive ) ]
                                , HA.title "Transfer all items"
                                ]
                                [ H.text <| Barter.doubleArrow arrowsDirection ]

                        itemView =
                            H.span
                                [ HA.class <| "flex-1 " ++ itemLabelClass ]
                                [ H.text <| String.fromInt count ++ "x " ++ itemName ]
                    in
                    H.div [ HA.class "flex items-center px-2 py-0.5" ] <|
                        case arrowsDirection of
                            Barter.ArrowLeft ->
                                [ transferAllView
                                , transferNView
                                , transferOneView
                                , itemView
                                ]

                            Barter.ArrowRight ->
                                [ itemView
                                , transferOneView
                                , transferNView
                                , transferAllView
                                ]

                playerNameView : Html FrontendMsg
                playerNameView =
                    H.div
                        [ HA.class "p-2 border-b-2 border-b-green-800"
                        , HA.style "grid-area" "player-name"
                        ]
                        [ H.text <| "Player: " ++ player.name ]

                playerTradesView : Html FrontendMsg
                playerTradesView =
                    H.div
                        [ HA.class "p-2 border-b-2 border-b-green-800"
                        , HA.style "grid-area" "player-trades"
                        ]
                        [ H.text "Player trades:" ]

                vendorTradesView : Html FrontendMsg
                vendorTradesView =
                    H.div
                        [ HA.class "p-2 border-b-2 border-b-green-800"
                        , HA.style "grid-area" "vendor-trades"
                        ]
                        [ H.text "Vendor trades:" ]

                vendorNameView : Html FrontendMsg
                vendorNameView =
                    H.div
                        [ HA.class "p-2 border-b-2 border-b-green-800 text-right"
                        , HA.style "grid-area" "vendor-name"
                        ]
                        [ "Vendor: {NAME} ({LOCATION})"
                            |> String.replace "{NAME}" (Shop.personName vendor.shop)
                            |> String.replace "{LOCATION}" (Shop.location vendor.shop |> Location.name)
                            |> H.text
                        ]

                playerTradedValueView : Html FrontendMsg
                playerTradedValueView =
                    H.div
                        [ HA.class "text-green-100 text-center p-2"
                        , HA.style "grid-area" "player-traded-value"
                        ]
                        [ H.text <| "Value: $" ++ String.fromInt playerTradedValue ]

                vendorTradedValueView : Html FrontendMsg
                vendorTradedValueView =
                    H.div
                        [ HA.class "text-green-100 text-center p-2"
                        , HA.style "grid-area" "vendor-traded-value"
                        ]
                        [ H.text <| "Value: $" ++ String.fromInt vendorTradedValue ]

                playerKeptItemsView : Html FrontendMsg
                playerKeptItemsView =
                    H.div [ HA.style "grid-area" "player-kept-items" ]
                        (List.map
                            (playerItemView
                                { items = player.items
                                , itemLabelClass = ""
                                , transfer = \id count -> BarterMsg <| AddPlayerItem id count
                                , transferNPosition = Barter.PlayerKeptItem
                                }
                            )
                            playerKeptItems
                        )

                playerTradedItemsView : Html FrontendMsg
                playerTradedItemsView =
                    H.div [ HA.style "grid-area" "player-traded-items" ]
                        (List.map
                            (playerItemView
                                { items = player.items
                                , itemLabelClass = "ml-1"
                                , transfer = \id count -> BarterMsg <| RemovePlayerItem id count
                                , transferNPosition = Barter.PlayerTradedItem
                                }
                            )
                            playerTradedItems
                        )

                vendorKeptItemsView : Html FrontendMsg
                vendorKeptItemsView =
                    H.div [ HA.style "grid-area" "vendor-kept-items" ]
                        (List.map
                            (playerItemView
                                { items = vendor.items
                                , itemLabelClass = "ml-1"
                                , transfer = \id count -> BarterMsg <| AddVendorItem id count
                                , transferNPosition = Barter.VendorKeptItem
                                }
                            )
                            vendorKeptItems
                        )

                vendorTradedItemsView : Html FrontendMsg
                vendorTradedItemsView =
                    H.div [ HA.style "grid-area" "vendor-traded-items" ]
                        (List.map
                            (playerItemView
                                { items = vendor.items
                                , itemLabelClass = ""
                                , transfer = \id count -> BarterMsg <| RemoveVendorItem id count
                                , transferNPosition = Barter.VendorTradedItem
                                }
                            )
                            vendorTradedItems
                        )

                playerKeptCapsView : Html FrontendMsg
                playerKeptCapsView =
                    capsView
                        { itemLabelClass = ""
                        , gridArea = "player-kept-caps"
                        , transfer = BarterMsg << AddPlayerCaps
                        , transferNPosition = Barter.PlayerKeptCaps
                        }
                        playerKeptCaps

                playerTradedCapsView : Html FrontendMsg
                playerTradedCapsView =
                    capsView
                        { itemLabelClass = "ml-1"
                        , gridArea = "player-traded-caps"
                        , transfer = BarterMsg << RemovePlayerCaps
                        , transferNPosition = Barter.PlayerTradedCaps
                        }
                        playerTradedCaps

                vendorKeptCapsView : Html FrontendMsg
                vendorKeptCapsView =
                    capsView
                        { itemLabelClass = "ml-1"
                        , gridArea = "vendor-kept-caps"
                        , transfer = BarterMsg << AddVendorCaps
                        , transferNPosition = Barter.VendorKeptCaps
                        }
                        vendorKeptCaps

                vendorTradedCapsView : Html FrontendMsg
                vendorTradedCapsView =
                    capsView
                        { itemLabelClass = ""
                        , gridArea = "vendor-traded-caps"
                        , transfer = BarterMsg << RemoveVendorCaps
                        , transferNPosition = Barter.VendorTradedCaps
                        }
                        vendorTradedCaps

                playerTradedBg : Html FrontendMsg
                playerTradedBg =
                    H.div
                        [ HA.style "grid-area" "2 / 2 / 5 / 3"
                        , HA.class "bg-green-800-half-transparent border-r border-r-green-800"
                        ]
                        []

                vendorTradedBg : Html FrontendMsg
                vendorTradedBg =
                    H.div
                        [ HA.style "grid-area" "2 / 3 / 5 / 4"
                        , HA.class "bg-green-800-half-transparent border-l border-l-green-800"
                        ]
                        []

                gridContents : List (Html FrontendMsg)
                gridContents =
                    [ playerTradedBg
                    , vendorTradedBg
                    , resetBtn
                    , confirmBtn
                    , playerNameView
                    , playerTradesView
                    , vendorTradesView
                    , vendorNameView
                    , playerKeptCapsView
                    , vendorKeptCapsView
                    , playerTradedCapsView
                    , vendorTradedCapsView
                    , playerTradedValueView
                    , vendorTradedValueView
                    , playerKeptItemsView
                    , playerTradedItemsView
                    , vendorKeptItemsView
                    , vendorTradedItemsView
                    ]
            in
            [ pageTitleView <| "Store: " ++ Shop.personName shop ++ " (" ++ Location.name location ++ ")"
            , H.div [ HA.class "flex flex-col gap-2 items-start" ]
                [ UI.button
                    [ HE.onClick (GoToRoute (PlayerRoute Route.TownMainSquare)) ]
                    [ H.text "[Back]" ]
                , H.div [] [ H.text <| Shop.description shop ]
                ]
            , H.div
                [ HA.class "mt-10 self-stretch grid grid-cols-[repeat(4,1fr)]"
                , HA.class "town-store-grid"
                ]
                gridContents
            , H.viewMaybe
                (\message ->
                    H.div
                        [ HA.class "mt-10 text-yellow" ]
                        [ H.text <| Barter.messageText message ]
                )
                barter.lastMessage
            ]

        else
            contentUnavailableDueToQuests

    else
        contentUnavailableDueToWrongLocation


newCharView : Maybe HoveredItem -> NewChar -> List (Html FrontendMsg)
newCharView hoveredItem newChar =
    let
        createBtnView =
            H.div [ HA.class "mt-10" ]
                [ UI.button
                    [ HE.onClick CreateChar ]
                    [ H.text "[ Create ]" ]
                ]

        errorView =
            H.viewMaybe
                (\error ->
                    H.div [ HA.class "text-yellow mt-5" ]
                        [ H.text <| NewChar.error error ]
                )
                newChar.error
    in
    [ pageTitleView "New Character"
    , H.div
        [ HA.class "grid grid-cols-[42ch_42ch_38ch] gap-5" ]
        [ H.div [ HA.class "flex flex-col gap-8" ]
            [ newCharSpecialView newChar
            , newCharTraitsView newChar.traits
            , createBtnView
            , errorView
            ]
        , H.div [ HA.class "flex flex-col gap-8" ]
            [ newCharSkillsView newChar
            ]
        , H.div [ HA.class "flex flex-col gap-8" ]
            [ newCharDerivedStatsView newChar
            , newCharHelpView hoveredItem
            ]
        ]
    ]


newCharHelpView : Maybe HoveredItem -> Html FrontendMsg
newCharHelpView maybeHoveredItem =
    let
        helpContent : Html FrontendMsg
        helpContent =
            case maybeHoveredItem of
                Nothing ->
                    H.p
                        [ HA.class "max-w-[50ch] text-green-300" ]
                        [ H.text "Hover over an item to show more information about it here!" ]

                Just hoveredItem ->
                    let
                        { title, description } =
                            HoveredItem.text hoveredItem
                    in
                    H.div [ HA.class "max-w-[50ch] flex flex-col gap-2" ]
                        [ H.h4
                            [ HA.class "text-yellow" ]
                            [ H.text title ]
                        , description
                            |> Markdown.Parser.parse
                            |> Result.mapError (\_ -> "")
                            |> Result.andThen (Markdown.Renderer.render hoveredItemRenderer)
                            |> Result.withDefault [ H.text "Failed to parse Markdown" ]
                            |> H.div [ HA.class "flex flex-col gap-2" ]
                        ]
    in
    H.div
        [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Help" ]
        , helpContent
        ]


hoveredItemRenderer : Markdown.Renderer.Renderer (Html a)
hoveredItemRenderer =
    { defaultHtmlRenderer
        | paragraph =
            \children ->
                H.span [] children
        , link =
            \{ title, destination } children ->
                H.a
                    [ HA.class "text-yellow relative no-underline"
                    , TW.mod "after" "absolute content-[''] bg-yellow-transparent inset-x-[-3px] bottom-[-2px] h-1 transition-all duration-[250ms]"
                    , TW.mod "hover:after" "bottom-0 h-full"
                    , HA.href destination
                    , HA.attributeMaybe HA.title title
                    ]
                    children
        , unorderedList =
            \list ->
                list
                    |> List.map
                        (\(Markdown.Block.ListItem _ children) ->
                            H.li [] (UI.liBullet :: children)
                        )
                    |> H.ul [ HA.class "flex flex-col" ]
    }


newCharDerivedStatsView : NewChar -> Html FrontendMsg
newCharDerivedStatsView newChar =
    let
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                }

        itemView : ( String, String, Maybe HoveredItem ) -> Html FrontendMsg
        itemView ( label, value, hoveredItem ) =
            let
                liAttrs =
                    case hoveredItem of
                        Just hoveredItem_ ->
                            [ HE.onMouseOver <| HoverItem hoveredItem_
                            , HE.onMouseOut StopHoveringItem
                            ]

                        Nothing ->
                            []
            in
            H.li
                (TW.mod "hover" "bg-green-800"
                    :: liAttrs
                )
                [ UI.liBullet
                , H.text <| label ++ ": "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text value ]
                ]

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = finalSpecial.perception
                , hasAwarenessPerk = False
                }
    in
    H.div [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Derived stats" ]
        , H.ul [] <|
            List.map itemView
                [ ( "Hitpoints"
                  , String.fromInt <|
                        Logic.hitpoints
                            { level = 1
                            , special = finalSpecial
                            , lifegiverPerkRanks = 0
                            }
                  , Nothing
                  )
                , ( "Heal when using tick"
                  , (String.fromInt <|
                        Logic.tickHealPercentage
                            { special = finalSpecial
                            , addedSkillPercentages = SeqDict.empty
                            , fasterHealingPerkRanks = 0
                            }
                    )
                        ++ " % of max HP"
                  , Nothing
                  )
                , ( "Heal over time"
                  , (String.fromInt <|
                        Logic.healOverTimePerTick
                            { special = finalSpecial
                            , addedSkillPercentages = SeqDict.empty
                            , fasterHealingPerkRanks = 0
                            }
                    )
                        ++ " HP every tick"
                  , Nothing
                  )
                , ( "Perception Level"
                  , Perception.label perceptionLevel
                  , Just <| HoveredPerceptionLevel perceptionLevel
                  )
                , ( "Action Points"
                  , String.fromInt <|
                        Logic.actionPoints
                            { hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                            , actionBoyPerkRanks = 0
                            , special = finalSpecial
                            }
                  , Nothing
                  )
                ]
        ]


newCharSpecialView : NewChar -> Html FrontendMsg
newCharSpecialView newChar =
    let
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                }

        specialItemView type_ =
            let
                value =
                    Special.get type_ finalSpecial

                isInRange =
                    Special.isValueInRange value
            in
            H.div
                [ HE.onMouseOver <| HoverItem <| HoveredSpecial type_
                , HE.onMouseOut StopHoveringItem
                , HA.class "contents group"
                ]
                [ H.div []
                    [ UI.button
                        [ HE.onClick <| NewCharDecSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canDecrement
                                    type_
                                    finalSpecial
                        , HA.class "!text-green-100"
                        , TW.mod "disabled" "!text-green-300 cursor-not-allowed"
                        , TW.mod "[&:not(:disabled):hover]" "!text-yellow"
                        , TW.mod "group-hover" "bg-green-800"
                        ]
                        [ H.text "[-]" ]
                    ]
                , H.div
                    [ HA.class "px-[1ch]"
                    , HA.classList [ ( "!text-yellow", not isInRange ) ]
                    , TW.mod "group-hover" "text-green-100 bg-green-800"
                    ]
                    [ H.text <| Special.label type_ ]
                , H.div
                    [ HA.class "pr-[1ch] text-right"
                    , HA.classList [ ( "!text-yellow", not isInRange ) ]
                    , TW.mod "group-hover" "text-green-100 bg-green-800"
                    ]
                    [ H.text <| String.fromInt value ]
                , H.div
                    []
                    [ UI.button
                        [ HE.onClick <| NewCharIncSpecial type_
                        , HA.disabled <|
                            not <|
                                Special.canIncrement
                                    newChar.availableSpecial
                                    type_
                                    finalSpecial
                        , HA.class "!text-green-100"
                        , TW.mod "disabled" "!text-green-300 cursor-not-allowed"
                        , TW.mod "[&:not(:disabled):hover]" "!text-yellow"
                        , TW.mod "group-hover" "bg-green-800"
                        ]
                        [ H.text "[+]" ]
                    ]
                ]
    in
    H.div
        [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "SPECIAL ("
            , H.span
                [ HA.class "text-yellow" ]
                [ H.text <| String.fromInt newChar.availableSpecial ]
            , H.text " points left)"
            ]
        , H.div [ HA.class "grid grid-cols-[3ch_13ch_3ch_3ch] auto-rows-auto" ]
            (List.map specialItemView Special.all)
        , H.p
            [ HA.class "text-green-300" ]
            [ H.text "Distribute your SPECIAL points (each attribute can be in range 1..10)." ]
        ]


newCharTraitsView : SeqSet Trait -> Html FrontendMsg
newCharTraitsView traits =
    let
        availableTraits : Int
        availableTraits =
            Logic.maxTraits - SeqSet.size traits

        traitView : Trait -> Html FrontendMsg
        traitView trait =
            let
                isToggled : Bool
                isToggled =
                    SeqSet.member trait traits
            in
            H.li
                [ HA.class "flex flex-row gap-[1ch] pr-[2ch] justify-start cursor-pointer group"
                , TW.mod "hover" "text-yellow bg-green-800"
                , HA.classList [ ( "text-yellow", isToggled ) ]
                , HE.onClick <| NewCharToggleTrait trait
                , HE.onMouseOver <| HoverItem <| HoveredTrait trait
                , HE.onMouseOut StopHoveringItem
                ]
                [ UI.button
                    [ HE.onClickStopPropagation <| NewCharToggleTrait trait
                    , HA.class "!text-green-100"
                    , HA.classList [ ( "!text-yellow", isToggled ) ]
                    , TW.mod "group-hover" "!text-yellow bg-green-800"
                    ]
                    [ H.text <| UI.checkboxLabel isToggled ]
                , H.div [] [ H.text <| Trait.name trait ]
                ]
    in
    H.div
        [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Traits ("
            , H.span
                [ HA.class "text-yellow" ]
                [ H.text <| String.fromInt availableTraits ]
            , H.text " available)"
            ]
        , H.ul
            [ HA.class "w-max grid grid-cols-2 gap-x-[2ch]" ]
            (List.map traitView Trait.all)
        , H.p
            [ HA.class "text-green-300" ]
            [ H.text "Select up to two traits." ]
        ]


newCharSkillsView : NewChar -> Html FrontendMsg
newCharSkillsView newChar =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                }
    in
    skillsView_
        { addedSkillPercentages =
            Logic.addedSkillPercentages
                { taggedSkills = newChar.taggedSkills
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                }
        , special = finalSpecial
        , taggedSkills = newChar.taggedSkills
        , hasTagPerk = False
        , availableSkillPoints = 0
        , isNewChar = True
        }


characterView : Maybe HoveredItem -> PlayerData -> CPlayer -> List (Html FrontendMsg)
characterView maybeHoveredItem _ player =
    let
        level =
            Xp.currentLevel player.xp

        applicablePerks : List Perk
        applicablePerks =
            Perk.allApplicableForLevelup
                { level = level
                , special = player.special
                , addedSkillPercentages = player.addedSkillPercentages
                , perks = player.perks
                }
    in
    [ pageTitleView "Character"
    , if player.availablePerks > 0 && not (List.isEmpty applicablePerks) then
        choosePerkView maybeHoveredItem applicablePerks

      else
        normalCharacterView maybeHoveredItem player
    ]


choosePerkView : Maybe HoveredItem -> List Perk -> Html FrontendMsg
choosePerkView maybeHoveredItem applicablePerks =
    let
        perkView : Perk -> Html FrontendMsg
        perkView perk =
            H.li
                [ HE.onClick <| AskToChoosePerk perk
                , HA.class "cursor-pointer group"
                , HE.onMouseOver <| HoverItem <| HoveredPerk perk
                , HE.onMouseOut StopHoveringItem
                ]
                [ UI.liBullet
                , H.span
                    [ TW.mod "group-hover" "text-yellow"
                    ]
                    [ H.text <| Perk.name perk ]
                ]
    in
    H.div
        [ HA.class "flex-1 flex flex-col self-stretch" ]
        [ H.div
            [ HA.class "flex-1 grid grid-cols-[minmax(0,max-content)_minmax(0,60ch)] gap-8" ]
            [ H.div [ HA.class "flex flex-col gap-4" ]
                [ H.h3 [] [ H.text "Choose a perk!" ]
                , H.ul [] (List.map perkView applicablePerks)
                ]
            , H.viewMaybe perkDescriptionView maybeHoveredItem
            ]
        ]


perkDescriptionView : HoveredItem -> Html FrontendMsg
perkDescriptionView hoveredItem =
    let
        { title, description } =
            HoveredItem.text hoveredItem
    in
    H.div
        [ HA.id "character-perk-description" ]
        [ H.h3 [] [ H.text title ]
        , H.text description
        ]


normalCharacterView : Maybe HoveredItem -> CPlayer -> Html FrontendMsg
normalCharacterView maybeHoveredItem player =
    H.div
        [ HA.class "grid grid-cols-[24ch_34ch_minmax(0,1fr)] gap-5" ]
        [ H.div [ HA.class "flex flex-col gap-8" ]
            [ charSpecialView player
            , charTraitsView player.traits
            , charPerksView player.perks
            ]
        , H.div [ HA.class "flex flex-col gap-8" ]
            [ charSkillsView player
            ]
        , H.div [ HA.class "flex flex-col gap-8" ]
            [ charDerivedStatsView player
            , charHelpView maybeHoveredItem
            ]
        ]


charTraitsView : SeqSet Trait -> Html FrontendMsg
charTraitsView traits =
    let
        itemView : Trait -> Html FrontendMsg
        itemView trait =
            H.li
                [ HA.class "pr-[2ch]"
                , TW.mod "hover" "text-green-100 bg-green-800"
                , HE.onMouseOver <| HoverItem <| HoveredTrait trait
                , HE.onMouseOut StopHoveringItem
                ]
                [ UI.liBullet
                , H.text <| Trait.name trait
                ]
    in
    H.div
        [ HA.class "flex flex-col" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Traits" ]
        , if SeqSet.isEmpty traits then
            H.p
                [ HA.class "text-green-300" ]
                [ H.text "You have no traits." ]

          else
            H.ul [ HA.class "w-fit" ]
                (List.map itemView <| SeqSet.toList traits)
        ]


charHelpView : Maybe HoveredItem -> Html FrontendMsg
charHelpView maybeHoveredItem =
    let
        helpContent : Html FrontendMsg
        helpContent =
            case maybeHoveredItem of
                Nothing ->
                    H.p
                        [ HA.class "max-w-[50ch] text-green-300" ]
                        [ H.text "Hover over an item to show more information about it here!" ]

                Just hoveredItem ->
                    let
                        { title, description } =
                            HoveredItem.text hoveredItem
                    in
                    H.div [ HA.class "max-w-[50ch] flex flex-col gap-2" ]
                        [ H.h4
                            [ HA.class "text-yellow" ]
                            [ H.text title ]
                        , description
                            |> Markdown.Parser.parse
                            |> Result.mapError (\_ -> "")
                            |> Result.andThen (Markdown.Renderer.render hoveredItemRenderer)
                            |> Result.withDefault [ H.text "Failed to parse Markdown" ]
                            |> H.div [ HA.class "flex flex-col gap-2" ]
                        ]
    in
    H.div
        [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Help" ]
        , helpContent
        ]


charDerivedStatsView : CPlayer -> Html FrontendMsg
charDerivedStatsView player =
    let
        itemView : ( String, String, Maybe HoveredItem ) -> Html FrontendMsg
        itemView ( label, value, hoveredItem ) =
            let
                liAttrs =
                    case hoveredItem of
                        Just hoveredItem_ ->
                            [ HE.onMouseOver <| HoverItem hoveredItem_
                            , HE.onMouseOut StopHoveringItem
                            ]

                        Nothing ->
                            []
            in
            H.li
                (TW.mod "hover" "bg-green-800"
                    :: liAttrs
                )
                [ UI.liBullet
                , H.text <| label ++ ": "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text value ]
                ]

        perceptionLevel : PerceptionLevel
        perceptionLevel =
            Perception.level
                { perception = player.special.perception
                , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                }
    in
    H.div [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Derived stats" ]
        , H.ul [] <|
            List.map itemView
                [ ( "Max HP"
                  , String.fromInt <|
                        Logic.hitpoints
                            { level = Xp.currentLevel player.xp
                            , special = player.special
                            , lifegiverPerkRanks = Perk.rank Perk.Lifegiver player.perks
                            }
                  , Nothing
                  )
                , ( "Heal when using tick"
                  , (String.fromInt <|
                        Logic.tickHealPercentage
                            { special = player.special
                            , addedSkillPercentages = player.addedSkillPercentages
                            , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                            }
                    )
                        ++ " % of max HP"
                  , Nothing
                  )
                , ( "Heal over time"
                  , (String.fromInt <|
                        Logic.healOverTimePerTick
                            { special = player.special
                            , addedSkillPercentages = player.addedSkillPercentages
                            , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                            }
                    )
                        ++ " HP every tick"
                  , Nothing
                  )
                , ( "Perception Level"
                  , Perception.label perceptionLevel
                  , Just <| HoveredPerceptionLevel perceptionLevel
                  )
                , ( "Action Points"
                  , String.fromInt <|
                        Logic.actionPoints
                            { hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                            , actionBoyPerkRanks = Perk.rank Perk.ActionBoy player.perks
                            , special = player.special
                            }
                  , Nothing
                  )
                ]
        ]


charSpecialView : CPlayer -> Html FrontendMsg
charSpecialView player =
    let
        specialItemView type_ =
            let
                value =
                    Special.get type_ player.special
            in
            H.div
                [ HE.onMouseOver <| HoverItem <| HoveredSpecial type_
                , HE.onMouseOut StopHoveringItem
                , HA.class "contents group"
                ]
                [ H.div
                    [ HA.class "px-[1ch]"
                    , TW.mod "group-hover" "text-green-100 bg-green-800"
                    ]
                    [ H.text <| Special.label type_ ]
                , H.div
                    -- TODO highlighted if addiction etc?
                    [ HA.class "text-right pr-[1ch]"
                    , TW.mod "group-hover" "text-green-100 bg-green-800"
                    ]
                    [ H.text <| String.fromInt value ]
                ]
    in
    H.div
        [ HA.class "flex flex-col gap-4" ]
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "SPECIAL" ]
        , H.div [ HA.class "grid grid-cols-[13ch_3ch]" ]
            (List.map specialItemView Special.all)
        ]


skillsView_ :
    { addedSkillPercentages : SeqDict Skill Int
    , special : Special
    , taggedSkills : SeqSet Skill
    , hasTagPerk : Bool
    , availableSkillPoints : Int
    , isNewChar : Bool
    }
    -> Html FrontendMsg
skillsView_ r =
    let
        onTag : Skill -> FrontendMsg
        onTag =
            if r.isNewChar then
                NewCharToggleTaggedSkill

            else
                AskToTagSkill

        totalTags : Int
        totalTags =
            Logic.totalTags { hasTagPerk = r.hasTagPerk }

        availableTags : Int
        availableTags =
            max 0 <| totalTags - SeqSet.size r.taggedSkills

        skillView : Skill -> Html FrontendMsg
        skillView skill =
            let
                percent : Int
                percent =
                    Skill.get r.special r.addedSkillPercentages skill

                notUseful : Bool
                notUseful =
                    not <| Skill.isUseful skill

                isTagged : Bool
                isTagged =
                    SeqSet.member skill r.taggedSkills

                ( showTagButton, isTaggingDisabled ) =
                    case ( r.isNewChar, isTagged ) of
                        ( True, True ) ->
                            ( True, False )

                        ( True, False ) ->
                            ( True, availableTags == 0 )

                        ( False, True ) ->
                            ( availableTags > 0, True )

                        ( False, False ) ->
                            ( availableTags > 0, availableTags == 0 )

                isIncButtonDisabled : Bool
                isIncButtonDisabled =
                    r.availableSkillPoints <= 0

                isTaggable : Bool
                isTaggable =
                    showTagButton && not isTaggingDisabled

                hoverTextColor : String
                hoverTextColor =
                    if r.isNewChar then
                        "text-yellow"

                    else
                        "text-green-100"
            in
            H.div
                [ HA.class "contents group"
                , TW.mod "hover" hoverTextColor
                , HA.classList
                    [ ( "text-green-300", notUseful )
                    , ( "text-yellow", isTagged )
                    , ( "cursor-pointer", isTaggable )
                    ]
                , HA.attributeIf (not isTaggingDisabled) <| HE.onClick <| onTag skill
                , HE.onMouseOver <| HoverItem <| HoveredSkill skill
                , HE.onMouseOut StopHoveringItem
                ]
                [ H.viewIf showTagButton <|
                    UI.button
                        [ HE.onClickStopPropagation <| onTag skill
                        , HA.disabled isTaggingDisabled
                        , HA.class "!text-green-100 px-[1ch]"
                        , HA.classList
                            [ ( "!text-yellow", isTagged )
                            , ( "!text-green-300", notUseful )
                            ]
                        , TW.mod "group-hover" "!text-yellow bg-green-800"
                        ]
                        [ H.text <| UI.checkboxLabel isTagged ]
                , H.div
                    [ HA.class "pr-[1ch]"
                    , HA.classList [ ( "pl-[1ch]", not showTagButton ) ]
                    , TW.mod "group-hover" "bg-green-800"
                    ]
                    [ H.text <| Skill.name skill ]
                , H.div
                    [ HA.class "text-right"
                    , TW.mod "group-hover" "bg-green-800"
                    ]
                    [ H.text <| String.fromInt percent ++ "%" ]
                , H.viewIf (not r.isNewChar) <|
                    UI.button
                        [ HE.onClickStopPropagation <| AskToUseSkillPoints skill
                        , HA.disabled isIncButtonDisabled
                        , HA.attributeIf isIncButtonDisabled <|
                            HA.title "You have no skill points available."
                        , HA.class "pl-[1ch]"
                        , TW.mod "[&:not(:disabled):hover]" "!text-green-100 cursor-pointer"
                        , TW.mod "disabled" "cursor-not-allowed opacity-50"
                        , TW.mod "group-hover" "bg-green-800"
                        ]
                        [ H.text "[+]" ]
                ]
    in
    if r.isNewChar then
        H.div
            [ HA.class "flex flex-col gap-4" ]
            [ H.h3
                [ HA.class "text-green-300" ]
                [ H.text "Skills ("
                , H.span
                    [ HA.class "text-yellow" ]
                    [ H.text <| String.fromInt availableTags ]
                , H.text " tags left)"
                ]
            , H.div [ HA.class "grid grid-cols-[5ch_16ch_minmax(auto,5ch)]" ]
                (List.map skillView Skill.all)
            , H.p
                [ HA.class "text-green-300" ]
                [ H.text "Tag three skills. Dimmed skills are not yet useful in the game." ]
            ]

    else
        H.div [ HA.class "flex flex-col gap-4" ]
            [ H.h3
                [ HA.class "text-green-300" ]
                [ H.text "Skills ("
                , H.span
                    [ HA.class "text-yellow" ]
                    [ H.text <| String.fromInt r.availableSkillPoints ]
                , H.text " points available)"
                ]
            , H.div [ HA.class "grid grid-cols-[16ch_minmax(auto,5ch)_4ch]" ]
                (List.map skillView Skill.all)
            , H.viewIf (availableTags > 0) <|
                H.p [] [ H.text <| "Tags available: " ++ String.fromInt availableTags ]
            ]


charSkillsView : CPlayer -> Html FrontendMsg
charSkillsView player =
    skillsView_
        { addedSkillPercentages = player.addedSkillPercentages
        , special = player.special
        , taggedSkills = player.taggedSkills
        , hasTagPerk = Perk.rank Perk.Tag player.perks > 0
        , availableSkillPoints = player.availableSkillPoints
        , isNewChar = False
        }


charPerksView : SeqDict Perk Int -> Html FrontendMsg
charPerksView perks =
    let
        itemView : ( Perk, Int ) -> Html FrontendMsg
        itemView ( perk, rank ) =
            let
                maxRank : Int
                maxRank =
                    Perk.maxRank perk
            in
            H.li
                [ HE.onMouseOver <| HoverItem <| HoveredPerk perk
                , HE.onMouseOut StopHoveringItem
                , HA.class "pr-[2ch]"
                , TW.mod "hover" "text-green-100 bg-green-800"
                ]
                [ UI.liBullet
                , H.text <|
                    if maxRank == 1 then
                        Perk.name perk

                    else
                        Perk.name perk ++ " (" ++ String.fromInt rank ++ "x)"
                ]
    in
    H.div []
        [ H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Perks" ]
        , if SeqDict.isEmpty perks then
            H.p [] [ H.text "No perks yet!" ]

          else
            H.ul []
                (List.map itemView <| SeqDict.toList perks)
        ]


inventoryView : PlayerData -> CPlayer -> List (Html FrontendMsg)
inventoryView _ player =
    let
        inventoryTotalValue : Int
        inventoryTotalValue =
            player.items
                |> Dict.values
                |> List.map (\{ kind, count } -> ItemKind.baseValue kind * count)
                |> List.sum

        equippedArmorValue : Int
        equippedArmorValue =
            case player.equippedArmor of
                Nothing ->
                    0

                Just { kind, count } ->
                    ItemKind.baseValue kind * count

        equippedWeaponValue : Int
        equippedWeaponValue =
            case player.equippedWeapon of
                Nothing ->
                    0

                Just { kind, count } ->
                    ItemKind.baseValue kind * count

        totalValue : Int
        totalValue =
            inventoryTotalValue
                + equippedArmorValue
                + equippedWeaponValue
                + player.caps

        itemView : Item -> Html FrontendMsg
        itemView item =
            let
                disabledTooltip =
                    case Logic.canUseItem player item.kind of
                        Ok () ->
                            Nothing

                        Err ItemCannotBeUsedDirectly ->
                            Just "This item cannot be used directly."

                        Err (YouNeedTicks n) ->
                            Just <| "You need " ++ String.fromInt n ++ " ticks to use this item."

                        Err YoureAtFullHp ->
                            Just "You're at full HP."
            in
            H.li
                [ HA.class "flex flex-row gap-[1ch] group" ]
                [ UI.liBullet
                , H.span
                    [ HA.class "flex flex-row" ]
                    [ UI.button
                        [ HE.onClick <| AskToUseItem item.id
                        , HA.disabled <| disabledTooltip /= Nothing
                        , HA.attributeMaybe HA.title disabledTooltip
                        ]
                        [ H.text "[Use]" ]
                    ]
                , H.span [] [ H.text <| String.fromInt item.count ++ "x " ]
                , H.span [ HA.class "text-green-100" ] [ H.text <| ItemKind.name item.kind ]
                , if ItemKind.isArmor item.kind then
                    UI.button
                        [ HE.onClick <| AskToEquipArmor item.id ]
                        [ H.text "[Equip]" ]

                  else if ItemKind.isWeapon item.kind then
                    UI.button
                        [ HE.onClick <| AskToEquipWeapon item.id ]
                        [ H.text "[Equip]" ]

                  else
                    case player.equippedWeapon of
                        Nothing ->
                            H.text ""

                        Just weapon ->
                            if ItemKind.isAmmo item.kind && ItemKind.isUsableAmmoForWeapon weapon.kind item.kind then
                                UI.button
                                    [ HE.onClick <| AskToPreferAmmo item.kind ]
                                    [ H.text "[Prefer]" ]

                            else
                                H.text ""
                ]

        armorClass =
            Logic.armorClass
                { naturalArmorClass =
                    Logic.naturalArmorClass
                        { special = player.special
                        , hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                        , hasDodgerPerk = Perk.rank Perk.Dodger player.perks > 0
                        }
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                , apFromPreviousTurn = 0
                , hasHthEvadePerk = Perk.rank Perk.HthEvade player.perks > 0
                , unarmedSkill = Skill.get player.special player.addedSkillPercentages Skill.Unarmed
                }

        damageType : DamageType
        damageType =
            player.equippedWeapon
                |> Maybe.map .kind
                |> Logic.weaponDamageType

        opponentType : OpponentType
        opponentType =
            OpponentType.Player
                { xp = 0
                , name = "Opponent"
                }

        damageThreshold : Int
        damageThreshold =
            Logic.damageThreshold
                { damageType = damageType
                , opponentType = opponentType
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                }

        damageResistance : Int
        damageResistance =
            Logic.damageResistance
                { damageType = damageType
                , opponentType = opponentType
                , equippedArmor = player.equippedArmor |> Maybe.map .kind
                , toughnessPerkRanks = Perk.rank Perk.Toughness player.perks
                }

        attackStats : AttackStats
        attackStats =
            Logic.attackStats
                { special = player.special
                , traits = player.traits
                , perks = player.perks
                , items = player.items
                , addedSkillPercentages = player.addedSkillPercentages
                , equippedWeapon = player.equippedWeapon |> Maybe.map .kind
                , preferredAmmo = player.preferredAmmo
                , level = Xp.currentLevel player.xp
                , unarmedDamageBonus = 0
                , attackStyle =
                    player.equippedWeapon
                        |> Maybe.map (.kind >> Logic.unaimedAttackStyle)
                        |> Maybe.withDefault AttackStyle.UnarmedUnaimed
                , crippledArms = 0
                }
    in
    [ pageTitleView "Inventory"
    , H.div [ HA.class "flex flex-col gap-4" ]
        [ H.p []
            [ H.text "Total value: "
            , H.span [ HA.class "text-green-100" ] [ H.text <| "$" ++ String.fromInt totalValue ]
            ]
        , H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Items" ]
        , if Dict.isEmpty player.items then
            H.p [] [ H.text "You have no items!" ]

          else
            H.ul []
                (player.items
                    |> Dict.values
                    |> List.sortBy
                        (\{ kind } ->
                            ( List.map ItemType.name (ItemKind.types kind)
                            , ItemKind.baseValue kind
                            , ItemKind.name kind
                            )
                        )
                    |> List.map itemView
                )
        , H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Equipment" ]
        , [ [ ( player.equippedArmor, "Armor", ( AskToUnequipArmor, "[Unequip]" ) )
            , ( player.equippedWeapon, "Weapon", ( AskToUnequipWeapon, "[Unequip]" ) )
            ]
                |> List.map
                    (\( maybeItem, label, ( unequipMsg, unequipLabel ) ) ->
                        H.div []
                            [ UI.liBullet
                            , H.text <| label ++ ": "
                            , H.span [ HA.class "text-green-100" ] <|
                                case maybeItem of
                                    Nothing ->
                                        [ H.text "None" ]

                                    Just item ->
                                        [ H.text <| ItemKind.name item.kind
                                        , UI.button
                                            [ HE.onClick unequipMsg
                                            , HA.class "ml-[1ch]"
                                            ]
                                            [ H.text unequipLabel ]
                                        ]
                            ]
                    )
          , [ H.div []
                [ UI.liBullet
                , H.text "Preferred ammo: "
                , H.span [ HA.class "text-green-100" ] <|
                    case player.preferredAmmo of
                        Nothing ->
                            [ H.text "None" ]

                        Just ammo ->
                            [ H.text <| ItemKind.name ammo
                            , UI.button
                                [ HE.onClick AskToClearPreferredAmmo
                                , HA.class "ml-[1ch]"
                                ]
                                [ H.text "[Clear]" ]
                            ]
                ]
            ]
          ]
            |> List.fastConcat
            |> H.ul []
        , H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Defence stats" ]
        , H.ul []
            [ H.li []
                [ UI.liBullet
                , H.text "Armor Class: "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| String.fromInt armorClass ]
                ]
            , H.li []
                [ UI.liBullet
                , H.text "Damage Threshold: "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| String.fromInt damageThreshold ]
                ]
            , H.li []
                [ UI.liBullet
                , H.text "Damage Resistance: "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| String.fromInt damageResistance ]
                ]
            ]
        , H.h3
            [ HA.class "text-green-300" ]
            [ H.text "Attack stats" ]
        , H.ul []
            [ H.li []
                [ UI.liBullet
                , H.text "Min Damage: "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| String.fromInt attackStats.minDamage ]
                ]
            , H.li []
                [ UI.liBullet
                , H.text "Max Damage: "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| String.fromInt attackStats.maxDamage ]
                ]
            ]
        ]
    ]


messagesView : Posix -> Time.Zone -> PlayerData -> CPlayer -> List (Html FrontendMsg)
messagesView currentTime zone _ player =
    [ pageTitleView "Messages"
    , H.div [ HA.class "flex flex-col gap-4 items-start" ]
        [ UI.button
            [ HE.onClick AskToRemoveFightMessages
            , HA.disabled <| not (Dict.any (\_ { content } -> Message.isFightMessage content) player.messages)
            , HA.class "normal-case"
            ]
            [ H.text "[Remove fight messages]" ]
        , H.table [ HA.id "messages-table" ]
            [ H.thead []
                [ H.tr []
                    [ H.th [ HA.title "Unread" ] [ H.text "U" ]
                    , H.th [] [ H.text "Summary" ]
                    , H.th [] [ H.text "Date" ]
                    , H.th
                        [ HA.title "Remove all"
                        , HE.onClick AskToRemoveAllMessages
                        ]
                        [ H.text "X" ]
                    ]
                ]
            , H.tbody []
                (player.messages
                    |> Dict.values
                    |> List.sortBy (.id >> negate)
                    |> List.map
                        (\message ->
                            let
                                isUnread : Bool
                                isUnread =
                                    not message.hasBeenRead

                                summary : String
                                summary =
                                    Message.summary message

                                relativeDate : String
                                relativeDate =
                                    DateFormat.Relative.relativeTime
                                        currentTime
                                        message.date
                            in
                            H.tr
                                [ HA.classList [ ( "text-green-100", isUnread ) ]
                                , HE.onClick <| OpenMessage message.id
                                ]
                                [ if isUnread then
                                    H.td [ HA.title "Unread" ] [ H.text "*" ]

                                  else
                                    H.td [] []
                                , H.td
                                    [ HA.title summary ]
                                    [ H.text summary ]
                                , H.td
                                    [ HA.title <| Message.fullDate zone message ]
                                    [ H.text relativeDate ]
                                , H.td
                                    [ TW.mod "hover" "text-yellow"
                                    , HA.title "Remove"
                                    , HE.onClickStopPropagation <| AskToRemoveMessage message.id
                                    ]
                                    [ H.text "X" ]
                                ]
                        )
                )
            ]
        , H.viewIf (Dict.isEmpty player.messages) <|
            H.div [] [ H.text "No messages right now!" ]
        ]
    ]


messageView : Time.Zone -> Message.Id -> PlayerData -> CPlayer -> List (Html FrontendMsg)
messageView zone messageId _ player =
    case Dict.get messageId player.messages of
        Nothing ->
            contentUnavailableView <|
                "Message #"
                    ++ String.fromInt messageId
                    ++ " not found"

        Just message ->
            let
                perceptionLevel =
                    Perception.level
                        { perception = player.special.perception
                        , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                        }
            in
            [ pageTitleView "Message"
            , H.div [ HA.class "flex flex-col gap-4" ]
                [ H.div [ HA.class "flex flex-col items-start" ]
                    [ H.h3
                        [ HA.class "m-0 text-green-100 font-bold" ]
                        [ H.text <| Message.summary message ]
                    , H.div
                        [ HA.class "text-green-300" ]
                        [ H.text <| Message.fullDate zone message ]
                    , UI.button
                        [ HE.onClick <| GoToRoute (PlayerRoute Route.Messages) ]
                        [ H.text "[Back]" ]
                    ]
                , Message.content
                    [ HA.class "max-w-[70ch]" ]
                    perceptionLevel
                    message
                ]
            ]


settingsFightStrategySyntaxHelpView : Maybe HoveredItem -> List (Html FrontendMsg)
settingsFightStrategySyntaxHelpView maybeHoveredItem =
    let
        viewMarkup : FightStrategyHelp.Markup -> Html FrontendMsg
        viewMarkup markup =
            case markup of
                FightStrategyHelp.Text text ->
                    H.text text

                FightStrategyHelp.Reference reference ->
                    H.span
                        [ HA.class "text-yellow font-mono"
                        , HE.onMouseOver <| HoverItem <| HoveredFightStrategyReference reference
                        , HE.onMouseOut StopHoveringItem
                        ]
                        [ H.text <| FightStrategyHelp.referenceText reference ]

        hoverInfo =
            case maybeHoveredItem of
                Nothing ->
                    { title = "Hover a [THING] for help"
                    , description = ""
                    }

                Just hoveredItem ->
                    HoveredItem.text hoveredItem
    in
    [ pageTitleView "Fight Strategy syntax help"
    , H.div [ HA.class "flex flex-col gap-4 items-start" ]
        [ UI.button
            [ HE.onClick (GoToRoute (PlayerRoute Route.SettingsFightStrategy)) ]
            [ H.text "[Back]" ]
        , H.div
            [ HA.class "flex flex-row gap-[2ch]" ]
            [ H.div [ HA.class "w-[85ch]" ]
                [ H.div []
                    [ H.text "Your strategy needs to be of the shape "
                    , H.span [ HA.class "text-green-100" ] [ H.text "[STRATEGY]" ]
                    , H.text ", and its goal is to choose which "
                    , H.span [ HA.class "text-green-100" ] [ H.text "[COMMAND]" ]
                    , H.text " to do in your current turn. See below for your options:"
                    ]
                , H.pre [ HA.class "font-mono" ]
                    (List.map viewMarkup FightStrategyHelp.help)
                ]
            , H.div [ HA.class "flex-1" ]
                [ H.h3 [ HA.classList [ ( "text-yellow pb-4", maybeHoveredItem /= Nothing ) ] ] [ H.text hoverInfo.title ]
                , H.pre
                    [ HA.class "font-sans whitespace-pre-wrap max-w-[60ch]" ]
                    [ H.text hoverInfo.description ]
                ]
            ]
        ]
    ]


settingsFightStrategyView :
    String
    -> PlayerData
    -> CPlayer
    -> List (Html FrontendMsg)
settingsFightStrategyView fightStrategyText _ player =
    let
        hasTextChanged : Bool
        hasTextChanged =
            fightStrategyText /= player.fightStrategyText

        parseResult : Result (List Parser.DeadEnd) FightStrategy
        parseResult =
            FightStrategy.parse fightStrategyText

        deadEnds : List Parser.DeadEnd
        deadEnds =
            case parseResult of
                Ok _ ->
                    []

                Err deadEnds_ ->
                    deadEnds_

        viewWarning : FightStrategy.ValidationWarning -> Html FrontendMsg
        viewWarning warning =
            H.li
                [ HA.class "text-yellow" ]
                [ UI.liBullet
                , H.text <|
                    case warning of
                        FightStrategy.ItemDoesntHeal itemKind ->
                            "Item doesn't heal: " ++ ItemKind.name itemKind

                        FightStrategy.YouCantUseAimedShots ->
                            "You can't use aimed shots (due to the Fast Shot trait)"

                        FightStrategy.MinDistanceIs1 ->
                            "Your condition will be always true/false because the minimal distance between opponents is 1, not between opponents is 1, not 0."
                ]

        viewDeadEnd : Parser.DeadEnd -> List (Html FrontendMsg)
        viewDeadEnd deadEnd =
            let
                wrapped : String -> String
                wrapped string =
                    "\"" ++ string ++ "\""

                fixAttack : String -> List String
                fixAttack str =
                    List.map wrapped <|
                        if str == "unarmed" then
                            [ "unarmed", "unarmed, ..." ]

                        else if str == "melee" then
                            [ "melee", "melee, ..." ]

                        else if str == "shoot" then
                            [ "shoot", "shoot, ..." ]

                        else
                            [ str ]

                items : List String
                items =
                    case deadEnd.problem of
                        Parser.ExpectingInt ->
                            [ "a number" ]

                        Parser.Expecting string ->
                            fixAttack string

                        Parser.ExpectingSymbol string ->
                            fixAttack string

                        Parser.ExpectingKeyword string ->
                            fixAttack string

                        Parser.ExpectingEnd ->
                            [ "end of the strategy" ]

                        Parser.UnexpectedChar ->
                            -- we're only using `chompIf` for whitespace in nonemptySpaces
                            [ "a space" ]

                        _ ->
                            [ "<HEY YOU FOUND A BUG, PLEASE SHARE ON DISCORD>" ]
            in
            -- TODO when user clicks the dead end, splice it into the program
            items
                |> List.map
                    (\item ->
                        H.li
                            [ TW.mod "hover" "text-green-100" ]
                            [ UI.liBullet
                            , H.text item
                            ]
                    )

        deadEndCategorization : Parser.DeadEnd -> ( ( Int, Int ), String, String )
        deadEndCategorization deadEnd =
            let
                ( item, category ) =
                    case deadEnd.problem of
                        Parser.ExpectingInt ->
                            ( "", "int" )

                        Parser.Expecting string ->
                            ( string, "3: token" )

                        Parser.ExpectingSymbol string ->
                            ( string, "2: symbol" )

                        Parser.ExpectingKeyword string ->
                            if string == "healing items" then
                                ( string, "0: special keyword" )

                            else
                                ( string, "1: keyword" )

                        _ ->
                            ( "", "weird" )
            in
            ( ( deadEnd.row, deadEnd.col )
            , category
            , item
            )

        helpBtn =
            UI.button
                [ HA.class "ml-[1ch]"
                , HE.onClick (GoToRoute (PlayerRoute Route.SettingsFightStrategySyntaxHelp))
                ]
                [ H.text "[Syntax cheatsheet]" ]

        firstDeadEnd : Maybe Parser.DeadEnd
        firstDeadEnd =
            List.head deadEnds

        firstDeadEndRow : Int
        firstDeadEndRow =
            Maybe.map .row firstDeadEnd
                |> Maybe.withDefault 1

        firstDeadEndColumn : Int
        firstDeadEndColumn =
            Maybe.map .col firstDeadEnd
                |> Maybe.withDefault 1

        warnings : List FightStrategy.ValidationWarning
        warnings =
            parseResult
                |> Result.map (FightStrategy.warnings player.traits)
                |> Result.withDefault []
    in
    [ pageTitleView "Settings: Fight Strategy"
    , H.div
        [ HA.class "flex flex-row gap-4" ]
        [ H.div [ HA.class "flex flex-col" ]
            [ H.div []
                (H.text "Examples: "
                    :: (FightStrategy.all
                            |> List.map
                                (\( name, strategy ) ->
                                    UI.button
                                        [ HE.onClick <| SetFightStrategyText <| FightStrategy.toString strategy
                                        , HA.class "normal-case"
                                        , TW.mod "before" "content-['[']"
                                        , TW.mod "after" "content-[']']"
                                        ]
                                        [ H.text name ]
                                )
                            |> List.intersperse (H.text ", ")
                       )
                )
            , H.div [ HA.class "relative" ]
                -- TODO change ch measurements to some kind of pixels. We'll have to hardcode this
                [ UI.textarea
                    [ HE.onInput SetFightStrategyText
                    , HA.class "!bg-green-800 w-[75ch] h-[25rem] my-4 py-4 px-4 rounded leading-[18px] overflow-x-auto whitespace-pre font-mono"
                    , HA.value fightStrategyText
                    ]
                    []
                , firstDeadEnd
                    |> H.viewMaybe
                        (\{ row, col } ->
                            H.div
                                [ HA.class "absolute left-4 top-4 pointer-events-none select-none w-[24px] h-4 -ml-0.5 pl-0.5 border-l border-l-yellow leading-[18px]"
                                , HA.class "bg-[linear-gradient(90deg,var(--yellow-transparent)_0%,var(--yellow-fully-transparent)_100%)]"
                                , HA.class "translate-x-[calc((var(--error-col)-1)*8px+1px)]"
                                , HA.class "translate-y-[calc((var(--error-row)-1)*18px+16px+1px)]"
                                , cssVars
                                    [ ( "--error-row", String.fromInt row )
                                    , ( "--error-col", String.fromInt col )
                                    ]
                                ]
                                []
                        )
                ]
            , H.div
                [ HA.class "flex flex-row gap-[1ch]" ]
                [ UI.button
                    [ HA.disabled <| not hasTextChanged || Result.isErr parseResult
                    , parseResult
                        |> Result.toMaybe
                        |> HA.attributeMaybe
                            (\strategy ->
                                HE.onClick <|
                                    AskToSetFightStrategy ( strategy, fightStrategyText )
                            )
                    ]
                    [ H.text "[Save]" ]
                , UI.button
                    [ HA.disabled <| not hasTextChanged
                    , HE.onClick <| SetFightStrategyText player.fightStrategyText
                    ]
                    [ H.text "[Reset to saved]" ]
                ]
            ]
        , H.div [ HA.class "flex flex-col gap-4 max-w-[50ch]" ]
            (H.div []
                [ H.text "Info:"
                , helpBtn
                ]
                :: (if Result.isOk parseResult then
                        [ H.p []
                            [ H.text "Your strategy is "
                            , H.span [ HA.class "text-green-100" ] [ H.text "valid." ]
                            ]
                        ]

                    else
                        [ H.p []
                            [ H.text "Your strategy is "
                            , H.span
                                [ HA.class "text-yellow" ]
                                [ H.text "not finished yet." ]
                            ]
                        , H.p []
                            [ H.text "See the yellow indicator on the left and the notes below to figure out where the problem is." ]
                        , H.p []
                            [ H.text "If needed, ask on Discord in the "
                            , H.a
                                [ HA.href discordFightStrategiesChannelInviteLink
                                , HA.target "_blank"
                                , HA.class "text-green-100 whitespace-pre"
                                , TW.mod "hover" "text-yellow"
                                ]
                                [ H.text "#fight-strategies" ]
                            , H.text " channel."
                            ]
                        , H.p []
                            [ H.text <|
                                if String.isEmpty (String.trim fightStrategyText) then
                                    "Start with:"

                                else
                                    "At line "
                                        ++ String.fromInt firstDeadEndRow
                                        ++ ", column "
                                        ++ String.fromInt firstDeadEndColumn
                                        ++ ", there should be"
                                        ++ (if List.length deadEnds > 1 then
                                                " one of:"

                                            else
                                                ":"
                                           )
                            ]
                        , H.ul []
                            (deadEnds
                                |> List.sortBy deadEndCategorization
                                |> List.fastConcatMap viewDeadEnd
                            )
                        ]
                   )
                ++ (if List.isEmpty warnings then
                        []

                    else
                        [ H.p [ HA.class "text-green-300" ]
                            [ H.text "Warnings:" ]
                        , H.ul []
                            (List.map viewWarning warnings)
                        ]
                   )
            )
        ]
    ]


newsItemView : Time.Zone -> News.Item -> Html FrontendMsg
newsItemView zone { date, title, text } =
    H.div []
        [ H.h3
            [ HA.class "text-green-100 font-bold" ]
            [ H.text title ]
        , H.time
            [ HA.class "text-green-300" ]
            [ date
                |> News.formatDate zone
                |> H.text
            ]
        , News.formatText "max-w-[70ch]" text
        ]


newsView : Time.Zone -> List (Html FrontendMsg)
newsView zone =
    [ pageTitleView "News"
    , H.div [ HA.class "flex flex-col gap-15" ]
        (List.map (newsItemView zone) News.items)
    ]


fightView : Maybe Fight.Info -> PlayerData -> CPlayer -> List (Html FrontendMsg)
fightView maybeFight _ player =
    case maybeFight of
        Nothing ->
            contentUnavailableView "Fight was `Nothing` in fightView"

        Just fight ->
            let
                youAreAttacker =
                    case fight.attacker of
                        OpponentType.Player { name } ->
                            name == player.name

                        OpponentType.Npc _ ->
                            False

                perceptionLevel =
                    Perception.level
                        { perception = player.special.perception
                        , hasAwarenessPerk = Perk.rank Perk.Awareness player.perks > 0
                        }
            in
            [ pageTitleView "Fight"
            , H.div [ HA.class "flex flex-col gap-4 items-start" ]
                [ H.div []
                    [ H.text <|
                        "Attacker: "
                            ++ Fight.opponentName fight.attacker
                            ++ (if youAreAttacker then
                                    " (you)"

                                else
                                    ""
                               )
                    ]
                , H.div []
                    [ H.text <|
                        "Target: "
                            ++ Fight.opponentName fight.target
                            ++ (if youAreAttacker then
                                    ""

                                else
                                    " (you)"
                               )
                    ]
                , Data.Fight.View.view perceptionLevel fight player.name
                , UI.button
                    [ HE.onClick <| GoToRoute (PlayerRoute Route.Ladder) ]
                    [ H.text "[Back]" ]
                ]
            ]


worldInfoView : WorldInfo -> Html FrontendMsg
worldInfoView data =
    H.ul []
        [ H.li []
            [ H.text "Name: "
            , H.span [ HA.class "text-green-100" ] [ H.text data.name ]
            ]
        , H.li []
            [ H.text "Players: "
            , H.span [ HA.class "text-green-100" ] [ H.text (String.fromInt data.playersCount) ]
            ]
        , H.li []
            [ H.text "Tick frequency: "
            , H.span [ HA.class "text-green-100" ]
                [ case data.tickPerIntervalCurve of
                    Tick.Linear n ->
                        H.text <| String.fromInt n ++ " ticks every " ++ Time.intervalToString data.tickFrequency

                    Tick.QuarterAndRest { quarter, rest } ->
                        H.text <|
                            String.fromInt quarter
                                ++ " ticks every "
                                ++ Time.intervalToString data.tickFrequency
                                ++ " until "
                                ++ String.fromInt (Tick.limit // 4)
                                ++ " ticks are reached, then "
                                ++ String.fromInt rest
                ]
            ]
        , H.li []
            [ H.text "Vendor restock frequency: "
            , H.span [ HA.class "text-green-100" ]
                [ H.text <| "every " ++ Time.intervalToString data.vendorRestockFrequency ]
            ]
        ]


aboutWorldView : PlayerData -> CPlayer -> List (Html FrontendMsg)
aboutWorldView data _ =
    [ pageTitleView <| "About world: " ++ data.worldName
    , H.div [ HA.class "p-[2ch]" ]
        [ worldInfoView
            { name = data.worldName
            , description = data.description
            , startedAt = data.startedAt
            , tickFrequency = data.tickFrequency
            , tickPerIntervalCurve = data.tickPerIntervalCurve
            , vendorRestockFrequency = data.vendorRestockFrequency
            , playersCount = List.length data.otherPlayers + 1
            }
        ]
    ]


ladderView : PlayerData -> CPlayer -> List (Html FrontendMsg)
ladderView data loggedInPlayer =
    let
        players : List COtherPlayer
        players =
            WorldData.allPlayers data
    in
    [ pageTitleView "Ladder"
    , playerLadderTableView players loggedInPlayer
    ]


playerLadderTableView : List COtherPlayer -> CPlayer -> Html FrontendMsg
playerLadderTableView players loggedInPlayer =
    H.table
        []
        [ H.thead []
            [ H.tr []
                [ H.th
                    [ HA.class "text-right"
                    , HA.title "Rank"
                    ]
                    [ H.text "#" ]
                , H.th [] [ H.text "Fight" ]
                , H.th [] [ H.text "Name" ]
                , H.th [ HA.title "Health status" ] [ H.text "Status" ]
                , H.th [ HA.class "text-right" ] [ H.text "Lvl" ]
                , H.th
                    [ HA.class "text-right"
                    , HA.title "Wins"
                    ]
                    [ H.text "W" ]
                , H.th
                    [ HA.class "text-right"
                    , HA.title "Losses"
                    ]
                    [ H.text "L" ]
                ]
            ]
        , H.tbody []
            (players
                |> List.indexedMap
                    (\i player ->
                        let
                            isYou =
                                loggedInPlayer.name == player.name

                            cantFight : String -> Html FrontendMsg
                            cantFight message =
                                H.td
                                    [ HA.class "text-green-300 cursor-not-allowed"
                                    , HA.classList [ ( "bg-green-800", isYou ) ]
                                    , HA.title message
                                    ]
                                    [ H.text "-" ]
                        in
                        H.tr
                            [ HA.classList [ ( "text-green-100", isYou ) ]
                            ]
                            [ H.td
                                [ HA.class "text-right"
                                , HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title "Rank"
                                ]
                                [ H.text <| String.fromInt <| i + 1 ]
                            , if loggedInPlayer.name == player.name then
                                cantFight "Hey, that's you!"

                              else if loggedInPlayer.hp == 0 then
                                cantFight "Can't fight: you're dead!"

                              else if HealthStatus.isDead player.healthStatus then
                                cantFight "Can't fight this person: they're dead!"

                              else if loggedInPlayer.ticks <= 0 then
                                cantFight "Can't fight: you have no ticks!"

                              else
                                H.td
                                    [ HE.onClick <| AskToFight player.name
                                    , HA.class "cursor-pointer bg-green-800 text-green-100"
                                    , HA.classList [ ( "bg-green-800", isYou ) ]
                                    , TW.mod "hover" "text-yellow"
                                    ]
                                    [ H.text "Fight" ]
                            , H.td
                                [ HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title "Name"
                                ]
                                [ H.text player.name ]
                            , H.td
                                [ HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title <|
                                    if loggedInPlayer.special.perception <= 1 then
                                        "Health status. Your perception is so low you genuinely can't say whether they're even alive or dead."

                                    else
                                        "Health status"
                                ]
                                [ H.text <| HealthStatus.label player.healthStatus ]
                            , H.td
                                [ HA.class "text-right"
                                , HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title "Level"
                                ]
                                [ H.text <| String.fromInt player.level ]
                            , H.td
                                [ HA.class "text-right"
                                , HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title "Wins"
                                ]
                                [ H.text <| String.fromInt player.wins ]
                            , H.td
                                [ HA.class "text-right"
                                , HA.classList [ ( "bg-green-800", isYou ) ]
                                , HA.title "Losses"
                                ]
                                [ H.text <| String.fromInt player.losses ]
                            ]
                    )
            )
        ]


adminLadderTableView : List SPlayer -> Html FrontendMsg
adminLadderTableView players =
    H.table []
        [ H.thead []
            [ H.tr []
                [ H.th
                    [ HA.class "ladder-rank"
                    , HA.title "Rank"
                    ]
                    [ H.text "#" ]
                , H.th [ HA.class "ladder-name" ] [ H.text "Name" ]
                , H.th
                    [ HA.class "ladder-status"
                    , HA.title "Health status"
                    ]
                    [ H.text "Status" ]
                , H.th [ HA.class "ladder-lvl" ] [ H.text "Lvl" ]
                , H.th
                    [ HA.class "ladder-wins"
                    , HA.title "Wins"
                    ]
                    [ H.text "W" ]
                , H.th
                    [ HA.class "ladder-losses"
                    , HA.title "Losses"
                    ]
                    [ H.text "L" ]
                ]
            ]
        , H.tbody []
            (players
                |> List.indexedMap
                    (\i player ->
                        H.tr
                            []
                            [ H.td
                                [ HA.class "ladder-rank"
                                , HA.title "Rank"
                                ]
                                [ H.text <| String.fromInt <| i + 1 ]
                            , H.td
                                [ HA.class "ladder-name"
                                , HA.title "Name"
                                ]
                                [ H.text player.name ]
                            , H.td
                                [ HA.class "ladder-status"
                                , HA.title "Health status"
                                ]
                                [ player
                                    |> HealthStatus.check Perception.Perfect
                                    |> HealthStatus.label
                                    |> H.text
                                ]
                            , H.td
                                [ HA.class "ladder-lvl"
                                , HA.title "Level"
                                ]
                                [ H.text <| String.fromInt <| Xp.currentLevel player.xp ]
                            , H.td
                                [ HA.class "ladder-wins"
                                , HA.title "Wins"
                                ]
                                [ H.text <| String.fromInt player.wins ]
                            , H.td
                                [ HA.class "ladder-losses"
                                , HA.title "Losses"
                                ]
                                [ H.text <| String.fromInt player.losses ]
                            ]
                    )
            )
        ]


contentUnavailableToLoggedOutView : List (Html FrontendMsg)
contentUnavailableToLoggedOutView =
    contentUnavailableView "you're not logged in"


contentUnavailableDueToQuests : List (Html FrontendMsg)
contentUnavailableDueToQuests =
    contentUnavailableView "this vendor is not available at this stage of the world"


contentUnavailableDueToWrongLocation : List (Html FrontendMsg)
contentUnavailableDueToWrongLocation =
    contentUnavailableView "this vendor does not reside at this location"


contentUnavailableWhenNotInTownView : List (Html FrontendMsg)
contentUnavailableWhenNotInTownView =
    contentUnavailableView "you're not in a town or another important location"


contentUnavailableToNonAdminView : List (Html FrontendMsg)
contentUnavailableToNonAdminView =
    contentUnavailableView "you're not an admin"


contentUnavailableToNonCreatedView : List (Html FrontendMsg)
contentUnavailableToNonCreatedView =
    contentUnavailableView "you haven't created your character yet"


contentUnavailableView : String -> List (Html FrontendMsg)
contentUnavailableView reason =
    [ H.text <|
        "Content unavailable ("
            ++ reason
            ++ "). This is most likely a bug. We should have redirected you someplace else. Could you report this to the developers please?"
    , UI.button
        [ HE.onClick <| GoToRoute News ]
        [ H.text "[Back]" ]
    ]


loadingNavView : Html FrontendMsg
loadingNavView =
    H.div []
        [ H.text "Loading..."
        , H.span
            [ HA.class "loading-cursor"
            , HA.class "inline-block w-[1ch] h-4 -mb-0.5 ml-0.5"
            ]
            []
        ]


alertMessageView : Maybe String -> Html FrontendMsg
alertMessageView maybeMessage =
    maybeMessage
        |> H.viewMaybe
            (\message ->
                H.div
                    [ HA.class "text-yellow" ]
                    [ H.text message ]
            )


loginFormView : List World.Name -> Auth Plaintext -> Html FrontendMsg
loginFormView worlds auth =
    let
        input attrs children =
            UI.input
                (HA.class "text-green-100 w-[18ch] font-extraBold"
                    :: TW.mod "focus" "bg-green-900"
                    :: attrs
                )
                children
    in
    H.form
        [ HA.class "w-[20ch]"
        , HE.onSubmit Login
        ]
        [ input
            [ HA.value auth.name
            , HA.placeholder "Username_______________"
            , HE.onInput SetAuthName
            ]
            []
        , input
            [ HA.type_ "password"
            , HA.value <| Auth.unwrap auth.password
            , HA.placeholder "Password_______________"
            , HE.onInput SetAuthPassword
            ]
            []
        , H.div
            [ HA.class "mt-5" ]
            [ H.text "World: " ]
        , H.div
            [ HA.class "select-wrapper"
            , HA.class "grid items-center relative w-[20ch] rounded cursor-pointer bg-green-200 mt-2  text-black"
            , TW.mod "after" "justify-self-end -translate-y-0.5 rotate-180 px-2 text-black"
            ]
            [ H.select
                [ HE.onChange SetAuthWorld
                , HA.class "select"
                , HA.class "peer appearance-none bg-transparent border-0 m-0 py-1 pl-2 pr-8 w-full z-[1] outline-none"
                ]
                (worlds
                    |> List.sortBy
                        (\worldName ->
                            if worldName == Logic.mainWorldName then
                                0

                            else
                                1
                        )
                    |> List.map
                        (\worldName ->
                            H.option
                                [ HA.value worldName
                                , HA.selected (auth.worldName == worldName)
                                ]
                                [ H.text worldName ]
                        )
                )
            , H.span
                [ TW.mod "peer-focus" "absolute inset-[-1px] border-2 border-green-100 rounded-[inherit]" ]
                []
            ]
        , H.div
            [ HA.class "mt-4 flex justify-between" ]
            [ UI.button
                [ HE.onClickPreventDefault Login ]
                [ H.text "[ Login ]" ]
            , UI.button
                [ HE.onClickPreventDefault Register ]
                [ H.text "[ Register ]" ]
            ]
        ]


type LinkType
    = LinkOut String
    | LinkIn
        { route : Route
        , isActive : Route -> Bool
        }
    | LinkMsg FrontendMsg


linkView : Route -> Link -> Html FrontendMsg
linkView currentRoute { label, type_, tooltip, disabled, dimmed, highlighted } =
    let
        ( tag, linkAttrs ) =
            case type_ of
                LinkOut http ->
                    ( H.a
                    , [ HA.href http
                      , HA.target "_blank"
                      , HA.attributeMaybe HA.title tooltip
                      , HA.attributeIf highlighted <| HA.class "active"
                      ]
                    )

                LinkIn { route, isActive } ->
                    ( UI.button
                    , [ HE.onClick <| GoToRoute route
                      , HA.attributeMaybe HA.title tooltip
                      , HA.attributeIf (isActive currentRoute || highlighted) <| HA.class "active"
                      , HA.disabled disabled
                      ]
                    )

                LinkMsg msg ->
                    ( UI.button
                    , [ HE.onClick msg
                      , HA.attributeMaybe HA.title tooltip
                      , HA.attributeIf highlighted <| HA.class "active"
                      , HA.disabled disabled
                      ]
                    )
    in
    tag
        (HA.class "link"
            :: HA.classList [ ( "dimmed", dimmed ) ]
            :: linkAttrs
        )
        [ H.span
            [ HA.class "link-left-bracket" ]
            [ H.text "[" ]
        , H.span
            [ HA.class "link-label" ]
            [ H.text label ]
        , H.span
            [ HA.class "link-right-bracket" ]
            [ H.text "]" ]
        ]


type alias Link =
    { label : String
    , type_ : LinkType
    , tooltip : Maybe String
    , disabled : Bool
    , dimmed : Bool
    , highlighted : Bool
    }


linkOut : String -> String -> Maybe String -> Bool -> Link
linkOut label url tooltip disabled =
    Link label (LinkOut url) tooltip disabled False False


linkIn : String -> Route -> Maybe String -> Bool -> Link
linkIn label route tooltip disabled =
    Link label
        (LinkIn
            { route = route
            , isActive = (==) route
            }
        )
        tooltip
        disabled
        False
        False


linkInFull : String -> Route -> (Route -> Bool) -> Maybe String -> Bool -> Bool -> Bool -> Link
linkInFull label route isActive tooltip disabled dimmed highlighted =
    Link label
        (LinkIn
            { route = route
            , isActive = isActive
            }
        )
        tooltip
        disabled
        dimmed
        highlighted


linkMsg : String -> FrontendMsg -> Maybe String -> Bool -> Link
linkMsg label msg tooltip disabled =
    Link label (LinkMsg msg) tooltip disabled False False


loggedInLinksView : Player CPlayer -> Route -> Html FrontendMsg
loggedInLinksView player currentRoute =
    let
        links =
            case player of
                NeedsCharCreated _ ->
                    [ linkIn "New Char" (PlayerRoute Route.CharCreation) Nothing False
                    , linkMsg "Logout" Logout Nothing False
                    ]

                Player p ->
                    let
                        tickHealPercentage =
                            Logic.tickHealPercentage
                                { special = p.special
                                , addedSkillPercentages = p.addedSkillPercentages
                                , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing p.perks
                                }

                        hpHealed =
                            round <| toFloat tickHealPercentage / 100 * toFloat p.maxHp

                        ( healTooltip, healDisabled ) =
                            if p.hp >= p.maxHp then
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick. You are at full HP!"
                                , True
                                )

                            else if p.ticks < 1 then
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick. You have no ticks left!"
                                , True
                                )

                            else
                                ( Just <| "Heal your HP by " ++ String.fromInt tickHealPercentage ++ " % of your max HP (" ++ String.fromInt hpHealed ++ " HP). Cost: 1 tick"
                                , False
                                )

                        ( wanderTooltip, wanderDisabled ) =
                            if p.hp <= 0 then
                                ( Just "Find something to fight. Cost: 1 tick. You are dead!"
                                , True
                                )

                            else if p.ticks < 1 then
                                ( Just "Find something to fight. Cost: 1 tick. You have no ticks left!"
                                , True
                                )

                            else
                                ( Just "Find something to fight. Cost: 1 tick"
                                , False
                                )

                        isInTown : Bool
                        isInTown =
                            Location.location p.location /= Nothing

                        unreadMessages : Int
                        unreadMessages =
                            p.messages
                                |> Dict.filter (always (not << .hasBeenRead))
                                |> Dict.size
                    in
                    [ linkMsg "Heal" AskToHeal healTooltip healDisabled
                    , linkMsg "Refresh" Refresh Nothing False
                    , linkIn "Character" (PlayerRoute Route.Character) Nothing False
                    , linkIn "Inventory" (PlayerRoute Route.Inventory) Nothing False
                    , linkIn "Map" Map Nothing False
                    , linkIn "Ladder" (PlayerRoute Route.Ladder) Nothing False
                    , if isInTown then
                        linkIn "Town" (PlayerRoute Route.TownMainSquare) Nothing False

                      else
                        linkMsg "Wander" AskToWander wanderTooltip wanderDisabled
                    , linkIn "Settings"
                        (PlayerRoute Route.SettingsFightStrategy)
                        Nothing
                        False
                    , linkInFull "Messages"
                        (PlayerRoute Route.Messages)
                        Route.isMessagesRelatedRoute
                        (if unreadMessages > 0 then
                            Just "You have unread messages!"

                         else
                            Nothing
                        )
                        False
                        (unreadMessages == 0)
                        (unreadMessages > 0)
                    , linkIn "World" (PlayerRoute Route.AboutWorld) Nothing False
                    , linkMsg "Worlds" AskForWorldsAndGoToWorldsRoute Nothing False
                    , linkMsg "Logout" Logout Nothing False
                    ]
    in
    H.div []
        (List.map (linkView currentRoute) links)


adminLinksView : Route -> Html FrontendMsg
adminLinksView currentRoute =
    let
        links =
            [ linkMsg "Refresh" Refresh Nothing False
            , linkIn "Model" (AdminRoute AdminBackendModelEditor) Nothing False
            , linkIn "Worlds" (AdminRoute AdminWorldsList) Nothing False
            , linkMsg "Logout" Logout Nothing False
            ]
    in
    H.div []
        (List.map (linkView currentRoute) links)


loggedOutLinksView : Route -> Html FrontendMsg
loggedOutLinksView currentRoute =
    H.div []
        ([ linkMsg "Refresh" Refresh Nothing False
         , linkIn "Map" Map Nothing False
         , linkIn "Worlds" WorldsList Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


commonLinksView : Route -> Html FrontendMsg
commonLinksView currentRoute =
    H.div []
        ([ linkIn "News" News Nothing False
         , linkIn "About" About Nothing False
         , linkOut "Discord" "https://discord.gg/SxymXxvehS" Nothing False
         , linkOut "Twitter" "https://twitter.com/NuAshworld" Nothing False
         , linkOut "GitHub" "https://github.com/Janiczek/nu-ashworld" Nothing False
         , linkOut "Reddit" "https://www.reddit.com/r/NuAshworld/" Nothing False
         , linkOut "Donate" "https://github.com/sponsors/Janiczek" Nothing False
         ]
            |> List.map (linkView currentRoute)
        )


adminWorldsListView : String -> Bool -> AdminData -> List (Html FrontendMsg)
adminWorldsListView newWorldName newWorldFast data =
    [ pageTitleView "Admin :: Worlds"
    , H.div []
        [ H.table []
            [ H.thead []
                [ H.tr []
                    [ H.th [] [ H.text "World" ]
                    , H.th [] [ H.text "Actions" ]
                    ]
                ]
            , H.tbody []
                (data.worlds
                    |> Dict.keys
                    |> List.map
                        (\worldName ->
                            H.tr [ HA.class "world" ]
                                [ H.td [] [ H.text worldName ]
                                , H.td []
                                    [ UI.button
                                        [ HE.onClick (GoToRoute (AdminRoute (Route.AdminWorldActivity worldName))) ]
                                        [ H.text "[Activity]" ]
                                    , UI.button
                                        [ HE.onClick (GoToRoute (AdminRoute (Route.AdminWorldHiscores worldName))) ]
                                        [ H.text "[Hiscores]" ]
                                    ]
                                ]
                        )
                )
            ]
        ]
    , H.div []
        [ UI.input
            [ HE.onInput SetAdminNewWorldName
            , HA.placeholder "New world name"
            , HA.value newWorldName
            ]
            []
        , UI.checkbox
            { isOn = newWorldFast
            , label = "Fast?"
            , toggle = SetAdminNewWorldFast
            }
        , UI.button
            [ HE.onClick AskToCreateNewWorld
            , HA.disabled (Dict.member newWorldName data.worlds)
            ]
            [ H.text "[Create]" ]
        ]
    ]


adminWorldActivityView : List ( PlayerName, World.Name, String ) -> World.Name -> AdminData -> List (Html FrontendMsg)
adminWorldActivityView lastTenToBackendMsgs worldName data =
    case Dict.get worldName data.worlds of
        Nothing ->
            contentUnavailableView <|
                "World '"
                    ++ worldName
                    ++ "' not found"

        Just _ ->
            [ pageTitleView <| "Admin :: World: " ++ worldName ++ " - Activity"
            , H.h3 [] [ H.text "Last 10 messages" ]
            , H.table []
                (H.thead []
                    [ H.tr []
                        [ H.th [] [ H.text "World" ]
                        , H.th [] [ H.text "Player" ]
                        , H.th [] [ H.text "Msg" ]
                        ]
                    ]
                    :: List.map
                        (\( playerName, msgWorldName, msg ) ->
                            H.tr []
                                [ H.td [] [ H.text msgWorldName ]
                                , H.td [] [ H.text playerName ]
                                , H.td [] [ H.text msg ]
                                ]
                        )
                        lastTenToBackendMsgs
                )
            , adminMapView worldName data
            ]


adminFusionEditorView : FusionBackendModel -> List (Html FrontendMsg)
adminFusionEditorView fusionBackendModel =
    let
        viewEditor value =
            H.div []
                [ UI.button
                    [ HE.onClick LoadFusionBackendModel ]
                    [ H.text "[Reload model]" ]
                , -- TODO switch to Fusion.Editor.view sometime later
                  Fusion.Editor.value
                    { editMsg = FusionEdit
                    , queryMsg = FusionQuery
                    , type_ = Just Fusion.Generated.TypeDict.Types.type_BackendModel
                    , typeDict = Fusion.Generated.TypeDict.typeDict
                    }
                    value
                ]
    in
    [ pageTitleView "Admin :: Model"
    , case fusionBackendModel of
        FNotLoaded ->
            UI.button
                [ HE.onClick LoadFusionBackendModel ]
                [ H.text "[Load model]" ]

        FOriginalOnly value ->
            H.div [ HA.class "flex flex-col gap-2" ]
                [ viewEditor value
                ]

        FEdited { original, edited } ->
            H.div [ HA.class "flex flex-col gap-2" ]
                [ H.div [ HA.class "flex flex-row gap-2" ]
                    [ UI.button
                        [ HE.onClick ResetFusionBackendModel ]
                        [ H.text "Reset" ]
                    , UI.button
                        [ HE.onClick PersistFusionBackendModel ]
                        [ H.text "Persist" ]
                    ]
                , viewEditor edited
                ]
    ]


adminWorldHiscoresView : World.Name -> AdminData -> List (Html FrontendMsg)
adminWorldHiscoresView worldName data =
    case Dict.get worldName data.worlds of
        Nothing ->
            contentUnavailableView <|
                "World '"
                    ++ worldName
                    ++ "' not found"

        Just world ->
            let
                players : List SPlayer
                players =
                    world.players
                        |> Dict.values
                        |> List.filterMap Player.getPlayerData
                        |> List.filter (\p -> p.worldName == worldName)
                        |> Ladder.sort

                maxBy : (SPlayer -> Int) -> ( PlayerName, Int )
                maxBy fn =
                    players
                        |> List.sortBy (negate << fn)
                        |> List.head
                        |> Maybe.map (\p -> ( p.name, fn p ))
                        |> Maybe.withDefault ( "nobody???", 0 )

                viewMaxBy : ( String, SPlayer -> Int ) -> Html FrontendMsg
                viewMaxBy ( what, fn ) =
                    let
                        ( winner, amount ) =
                            maxBy fn
                    in
                    H.li []
                        [ H.text <|
                            what
                                ++ ": "
                                ++ winner
                                ++ " ("
                                ++ String.fromInt amount
                                ++ ")"
                        ]
            in
            [ pageTitleView <| "Admin :: World: " ++ worldName ++ " - Hiscores"
            , H.div []
                [ H.ul []
                    (List.map viewMaxBy
                        [ ( "Most money", .caps )
                        , ( "Most items value"
                          , \p ->
                                p.caps
                                    + (p.items
                                        |> Dict.values
                                        |> List.map (\{ count, kind } -> ItemKind.baseValue kind * count)
                                        |> List.sum
                                      )
                          )
                        , ( "Most books (why)"
                          , \p ->
                                p.items
                                    |> Dict.values
                                    |> List.filter (\{ kind } -> List.member ItemType.Book (ItemKind.types kind))
                                    |> List.map .count
                                    |> List.sum
                          )
                        , ( "Most skill %"
                          , \p ->
                                Skill.all
                                    |> List.map (Skill.get p.special p.addedSkillPercentages)
                                    |> List.sum
                          )
                        , ( "Most perks"
                          , \p ->
                                p.perks
                                    |> SeqDict.values
                                    |> List.sum
                          )
                        ]
                    )
                , adminLadderTableView players
                ]
            ]


playerInfoView : Player CPlayer -> Html FrontendMsg
playerInfoView player =
    player
        |> Player.getPlayerData
        |> H.viewMaybe createdPlayerInfoView


createdPlayerInfoView : CPlayer -> Html FrontendMsg
createdPlayerInfoView player =
    H.div
        [ HA.class "grid grid-cols-2" ]
        [ H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]" ]
            [ H.text "Name:" ]
        , H.div
            [ HA.class "col-start-2 text-green-100" ]
            [ H.text player.name ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]"
            , HA.title "Hitpoints"
            ]
            [ H.text "HP:" ]
        , H.div
            [ HA.class "col-start-2" ]
            [ "{HP}/{MAXHP}"
                |> String.replace "{HP}" (String.fromInt player.hp)
                |> String.replace "{MAXHP}" (String.fromInt player.maxHp)
                |> H.text
            ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]"
            , HA.title "Experience points"
            ]
            [ H.text "XP:" ]
        , H.div [ HA.class "col-start-2" ]
            [ H.span [] [ H.text <| String.fromInt player.xp ]
            , H.span
                [ HA.class "text-green-300" ]
                [ H.text <| "/" ++ String.fromInt (Xp.nextLevelXp player.xp) ]
            ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]" ]
            [ H.text "Level:" ]
        , H.div
            [ HA.class "col-start-2" ]
            [ H.text <| String.fromInt <| Xp.currentLevel player.xp ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]"
            , HA.title "Wins/Losses"
            ]
            [ H.text "W/L:" ]
        , H.div
            [ HA.class "col-start-2" ]
            [ "{WINS}/{LOSSES}"
                |> String.replace "{WINS}" (String.fromInt player.wins)
                |> String.replace "{LOSSES}" (String.fromInt player.losses)
                |> H.text
            ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]" ]
            [ H.text "Caps:" ]
        , H.div
            [ HA.class "col-start-2" ]
            [ "${CAPS}"
                |> String.replace "{CAPS}" (String.fromInt player.caps)
                |> H.text
            ]
        , H.div
            [ HA.class "col-start-1 text-right text-green-300 mr-[1ch]"
            , HA.title "Ticks"
            ]
            [ H.text "Ticks:" ]
        , H.div
            [ HA.class "col-start-2" ]
            [ H.text <| String.fromInt player.ticks ]
        ]


logoView : Model -> Html msg
logoView model =
    H.div [ HA.class "flex flex-col items-end" ]
        [ H.img
            [ HA.src "/images/logo-black-small.png"
            , HA.alt "NuAshworld Logo"
            , HA.title "NuAshworld - go to homepage"
            , HA.class
                (if isPlayer model || isAdmin model then
                    "filter-logo-active"

                 else
                    "filter-logo-inactive"
                )
            , HA.width 190
            , HA.height 36
            ]
            []
        , H.div
            [ HA.class "text-green-300"
            , HA.title "Game version"
            ]
            [ H.text Version.version ]
        ]


discordFightStrategiesChannelInviteLink : String
discordFightStrategiesChannelInviteLink =
    "https://discord.gg/9NuCZs3YZa"
