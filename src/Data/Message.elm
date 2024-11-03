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
import Data.Special.Perception exposing (PerceptionLevel)
import DateFormat
import Html exposing (Attribute, Html)
import Markdown
import Time exposing (Posix)
import Time.ExtraExtra as Time


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
        (\welcomeEncoder youAdvancedLevelEncoder youWereAttackedEncoder youAttackedEncoder value ->
            case value of
                Welcome ->
                    welcomeEncoder

                YouAdvancedLevel arg0 ->
                    youAdvancedLevelEncoder arg0

                YouWereAttacked arg0 ->
                    youWereAttackedEncoder arg0

                YouAttacked arg0 ->
                    youAttackedEncoder arg0
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


content : List (Attribute msg) -> PerceptionLevel -> Message -> Html msg
content attributes perceptionLevel message =
    case message.content of
        Welcome ->
            Markdown.toHtml attributes
                "Welcome to NuAshworld! You know, war... war never changes."

        YouAdvancedLevel r ->
            Markdown.toHtml attributes <|
                """Congratulations, you advanced a level! 

Your current level is """
                    ++ String.fromInt r.newLevel
                    ++ "."

        YouWereAttacked r ->
            Html.div attributes
                [ Data.Fight.View.view
                    perceptionLevel
                    r.fightInfo
                    (Fight.opponentName r.fightInfo.target)
                ]

        YouAttacked r ->
            Html.div attributes
                [ Data.Fight.View.view
                    perceptionLevel
                    r.fightInfo
                    (Fight.opponentName r.fightInfo.attacker)
                ]


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
