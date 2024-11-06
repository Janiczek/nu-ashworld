module Data.Message exposing
    ( Content(..)
    , Id
    , Message
    , codec
    , content
    , fullDate
    , isFightMessage
    , new
    , newRead
    , summary
    )

import Codec exposing (Codec)
import Data.Fight as Fight
import Data.Fight.View
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest exposing (Quest)
import Data.Special.Perception exposing (PerceptionLevel)
import DateFormat
import Frontend.Links as Links
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HA
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import Tailwind as TW
import Time exposing (Posix)
import Time.ExtraExtra as Time
import UI


type alias Id =
    Int


type alias Message =
    { id : Id
    , content : Content
    , hasBeenRead : Bool
    , date : Posix
    }


type Content
    = Welcome
    | YouAdvancedLevel
        { -- perkAvailable : Bool
          -- skillPointsAvailable : Bool
          newLevel : Int
        }
    | YouWereAttacked
        { attacker : PlayerName
        , fightInfo : Fight.Info
        }
    | YouAttacked
        { target : PlayerName
        , fightInfo : Fight.Info
        }
    | YouCompletedAQuest
        { quest : Quest
        , xpReward : Int
        , playerReward : Maybe (List Quest.PlayerReward)
        , globalRewards : List Quest.GlobalReward
        }


isFightMessage : Content -> Bool
isFightMessage content_ =
    case content_ of
        Welcome ->
            False

        YouAdvancedLevel _ ->
            False

        YouWereAttacked _ ->
            True

        YouAttacked _ ->
            True

        YouCompletedAQuest _ ->
            False


codec : Codec Message
codec =
    Codec.object Message
        |> Codec.field "id" .id Codec.int
        |> Codec.field "content" .content contentCodec
        |> Codec.field "hasBeenRead" .hasBeenRead Codec.bool
        |> Codec.field "date" .date Time.posixCodec
        |> Codec.buildObject


contentCodec : Codec Content
contentCodec =
    Codec.custom
        (\welcomeEncoder youAdvancedLevelEncoder youWereAttackedEncoder youAttackedEncoder youCompletedAQuestEncoder value ->
            case value of
                Welcome ->
                    welcomeEncoder

                YouAdvancedLevel arg0 ->
                    youAdvancedLevelEncoder arg0

                YouWereAttacked arg0 ->
                    youWereAttackedEncoder arg0

                YouAttacked arg0 ->
                    youAttackedEncoder arg0

                YouCompletedAQuest arg0 ->
                    youCompletedAQuestEncoder arg0
        )
        |> Codec.variant0 "Welcome" Welcome
        |> Codec.variant1
            "YouAdvancedLevel"
            YouAdvancedLevel
            (Codec.object (\newLevel -> { newLevel = newLevel })
                |> Codec.field "newLevel" .newLevel Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "YouWereAttacked"
            YouWereAttacked
            (Codec.object (\attacker fightInfo -> { attacker = attacker, fightInfo = fightInfo })
                |> Codec.field "attacker" .attacker Codec.string
                |> Codec.field "fightInfo" .fightInfo Fight.infoCodec
                |> Codec.buildObject
            )
        |> Codec.variant1
            "YouAttacked"
            YouAttacked
            (Codec.object (\target fightInfo -> { target = target, fightInfo = fightInfo })
                |> Codec.field "target" .target Codec.string
                |> Codec.field "fightInfo" .fightInfo Fight.infoCodec
                |> Codec.buildObject
            )
        |> Codec.variant1
            "YouCompletedAQuest"
            YouCompletedAQuest
            (Codec.object
                (\quest xpReward playerReward globalRewards ->
                    { quest = quest
                    , xpReward = xpReward
                    , playerReward = playerReward
                    , globalRewards = globalRewards
                    }
                )
                |> Codec.field "quest" .quest Quest.codec
                |> Codec.field "xpReward" .xpReward Codec.int
                |> Codec.field "playerReward" .playerReward (Codec.nullable (Codec.list Quest.playerRewardCodec))
                |> Codec.field "globalRewards" .globalRewards (Codec.list Quest.globalRewardCodec)
                |> Codec.buildObject
            )
        |> Codec.buildCustom


new : Id -> Posix -> Content -> Message
new lastMessageId date content_ =
    { id = lastMessageId + 1
    , content = content_
    , hasBeenRead = False
    , date = date
    }


newRead : Id -> Posix -> Content -> Message
newRead lastMessageId date content_ =
    { id = lastMessageId + 1
    , content = content_
    , hasBeenRead = True
    , date = date
    }


summary : Message -> String
summary message =
    case message.content of
        Welcome ->
            "Welcome!"

        YouAdvancedLevel r ->
            "You advanced level! (" ++ String.fromInt r.newLevel ++ ")"

        YouWereAttacked r ->
            case r.fightInfo.result of
                Fight.AttackerWon _ ->
                    "You were attacked by " ++ r.attacker ++ " and lost"

                Fight.TargetWon _ ->
                    "You were attacked by " ++ r.attacker ++ " and won"

                Fight.TargetAlreadyDead ->
                    "You were attacked by " ++ r.attacker ++ " but were already dead"

                Fight.BothDead ->
                    "You were attacked by " ++ r.attacker ++ " and both died"

                Fight.NobodyDead ->
                    "You were attacked by " ++ r.attacker ++ " and both stayed alive"

                Fight.NobodyDeadGivenUp ->
                    "You were attacked by " ++ r.attacker ++ " but nobody was able to kill the other"

        YouAttacked r ->
            case r.fightInfo.result of
                Fight.AttackerWon _ ->
                    "You attacked " ++ r.target ++ " and won"

                Fight.TargetWon _ ->
                    "You attacked " ++ r.target ++ " and lost"

                Fight.TargetAlreadyDead ->
                    "You attacked " ++ r.target ++ " but they were already dead"

                Fight.BothDead ->
                    "You attacked " ++ r.target ++ " and both died"

                Fight.NobodyDead ->
                    "You attacked " ++ r.target ++ " and both stayed alive"

                Fight.NobodyDeadGivenUp ->
                    "You attacked " ++ r.target ++ " but nobody was able to kill the other"

        YouCompletedAQuest r ->
            "You completed the quest: " ++ Quest.title r.quest


content : List (Attribute msg) -> PerceptionLevel -> Message -> Html msg
content attributes perceptionLevel message =
    case message.content of
        Welcome ->
            """Welcome to NuAshworld! You know, war... war never changes.
                
In lieu of a tutorial, here are some goals to get you started:

- Open your `[CHARACTER]` sheet and use your **skill points** to improve your skills.
- Pick a weak player on the `[LADDER]` and **fight them**.
- `[HEAL]` yourself, using a tick.
- Enter a `[TOWN]`, check out some of the **quests** and visit a **shop**.
- If you've bought a weapon, open your `[INVENTORY]` and try equipping it.
- Go out of the town on the `[MAP]` and then `[WANDER]` to find some monster to kill.
- Open the `[SETTINGS]`, check out the **fight strategies** and try to write your own.
- Join the [Discord]({DISCORD}) and say hi!


Check out the [Guide](/guide) for more information!

Most of all, have fun roaming the wasteland!

~janiczek
"""
                |> String.replace "{DISCORD}" Links.discord
                |> renderMarkdown attributes

        YouAdvancedLevel r ->
            renderMarkdown attributes <|
                """Congratulations, you advanced a level! 

Your current level is """
                    ++ String.fromInt r.newLevel
                    ++ "."

        YouWereAttacked r ->
            H.div attributes
                [ Data.Fight.View.view
                    perceptionLevel
                    r.fightInfo
                    (Fight.opponentName r.fightInfo.target)
                ]

        YouAttacked r ->
            H.div attributes
                [ Data.Fight.View.view
                    perceptionLevel
                    r.fightInfo
                    (Fight.opponentName r.fightInfo.attacker)
                ]

        YouCompletedAQuest r ->
            [ Just ("You completed the quest: " ++ Quest.title r.quest)
            , Just ("You earned " ++ String.fromInt r.xpReward ++ " XP.")
            , Maybe.map
                (\rewards ->
                    String.join "\n"
                        [ "Your rewards:"
                        , String.join "\n" (List.map Quest.playerRewardTitle rewards)
                        ]
                )
                r.playerReward
            , if List.isEmpty r.globalRewards then
                Nothing

              else
                Just
                    (String.join "\n"
                        [ "Global effects:"
                        , String.join "\n" (List.map Quest.globalRewardTitle r.globalRewards)
                        ]
                    )
            ]
                |> List.filterMap identity
                |> String.join "\n\n"
                |> renderMarkdown attributes


renderMarkdown : List (Attribute msg) -> String -> Html msg
renderMarkdown attrs markdown =
    markdown
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "")
        |> Result.andThen (Markdown.Renderer.render markdownRenderer)
        |> Result.withDefault [ H.text "Failed to parse Markdown" ]
        |> H.div (HA.class "flex flex-col gap-4" :: attrs)


fullDate : Time.Zone -> Message -> String
fullDate zone message =
    DateFormat.format
        [ DateFormat.yearNumber
        , DateFormat.text "-"
        , DateFormat.monthFixed
        , DateFormat.text "-"
        , DateFormat.dayOfMonthFixed
        , DateFormat.text " "
        , DateFormat.hourMilitaryFixed
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.text ":"
        , DateFormat.secondFixed
        ]
        zone
        message.date


markdownRenderer : Markdown.Renderer.Renderer (Html a)
markdownRenderer =
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
        , strong = \children -> H.span [ HA.class "text-yellow" ] children
        , unorderedList =
            \list ->
                list
                    |> List.map
                        (\(Markdown.Block.ListItem _ children) ->
                            H.li [] children
                        )
                    |> UI.ul [ HA.class "flex flex-col gap-4" ]
        , codeSpan =
            \text ->
                H.span
                    [ HA.class "text-yellow font-bold" ]
                    [ H.text text ]
    }
