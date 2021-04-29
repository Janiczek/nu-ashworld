module Data.Message exposing
    ( Message
    , Type(..)
    , content
    , decoder
    , encode
    , fullDate
    , new
    , summary
    )

import Data.Fight as Fight exposing (FightInfo, FightResult(..))
import Data.Fight.View
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special.Perception exposing (PerceptionLevel)
import DateFormat
import Html exposing (Attribute, Html)
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Markdown
import Time exposing (Posix)


type alias Message =
    { type_ : Type
    , hasBeenRead : Bool
    , date : Posix
    }


type Type
    = Welcome
    | YouAdvancedLevel
        { -- perkAvailable : Bool
          -- skillPointsAvailable : Bool
          newLevel : Int
        }
    | YouWereAttacked
        { attacker : PlayerName
        , fightInfo : FightInfo
        }


encode : Message -> JE.Value
encode message =
    JE.object
        [ ( "type", encodeType message.type_ )
        , ( "hasBeenRead", JE.bool message.hasBeenRead )
        , ( "date", Iso8601.encode message.date )
        ]


decoder : Decoder Message
decoder =
    JD.succeed Message
        |> JD.andMap (JD.field "type" typeDecoder)
        |> JD.andMap (JD.field "hasBeenRead" JD.bool)
        |> JD.andMap (JD.field "date" Iso8601.decoder)


encodeType : Type -> JE.Value
encodeType type_ =
    case type_ of
        Welcome ->
            JE.object [ ( "type", JE.string "Welcome" ) ]

        YouAdvancedLevel r ->
            JE.object
                [ ( "type", JE.string "YouAdvancedLevel" )
                , ( "newLevel", JE.int r.newLevel )
                ]

        YouWereAttacked r ->
            JE.object
                [ ( "type", JE.string "YouWereAttacked" )
                , ( "attacker", JE.string r.attacker )
                , ( "fightInfo", Fight.encodeFightInfo r.fightInfo )
                ]


typeDecoder : Decoder Type
typeDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Welcome" ->
                        JD.succeed Welcome

                    "YouAdvancedLevel" ->
                        JD.field "newLevel" JD.int
                            |> JD.map (\newLevel -> YouAdvancedLevel { newLevel = newLevel })

                    "YouWereAttacked" ->
                        JD.map2
                            (\attacker fightInfo ->
                                YouWereAttacked
                                    { attacker = attacker
                                    , fightInfo = fightInfo
                                    }
                            )
                            (JD.field "attacker" JD.string)
                            (JD.field "fightInfo" Fight.fightInfoDecoder)

                    _ ->
                        JD.fail <| "Unknown Log Type: '" ++ type_ ++ "'"
            )


new : Posix -> Type -> Message
new date type_ =
    { type_ = type_
    , hasBeenRead = False
    , date = date
    }


summary : Message -> String
summary message =
    case message.type_ of
        Welcome ->
            "Welcome!"

        YouAdvancedLevel r ->
            "You advanced level! (" ++ String.fromInt r.newLevel ++ ")"

        YouWereAttacked r ->
            case r.fightInfo.result of
                AttackerWon _ ->
                    "You were attacked by " ++ r.attacker ++ " and lost"

                TargetWon _ ->
                    "You were attacked by " ++ r.attacker ++ " and won"

                TargetAlreadyDead ->
                    "You were attacked by " ++ r.attacker ++ " but were already dead"

                BothDead ->
                    "You were attacked by " ++ r.attacker ++ " and both died"

                NobodyDead ->
                    "You were attacked by " ++ r.attacker ++ " and both stayed alive"


content : List (Attribute msg) -> PerceptionLevel -> Message -> Html msg
content attributes perceptionLevel message =
    case message.type_ of
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
