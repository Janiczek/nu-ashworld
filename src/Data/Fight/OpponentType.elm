module Data.Fight.OpponentType exposing
    ( OpponentType(..)
    , PlayerOpponent
    , decoder
    , encode
    )

import Data.Enemy as Enemy
import Data.Player.PlayerName exposing (PlayerName)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE


type OpponentType
    = Npc Enemy.Type
    | Player PlayerOpponent


type alias PlayerOpponent =
    { name : PlayerName
    , xp : Int
    }


decoder : Decoder OpponentType
decoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "npc" ->
                        JD.map Npc Enemy.typeDecoder

                    "player" ->
                        JD.map Player
                            (JD.succeed PlayerOpponent
                                |> JD.andMap (JD.field "name" JD.string)
                                |> JD.andMap
                                    (JD.maybe (JD.field "xp" JD.int)
                                        |> JD.map (Maybe.withDefault 1)
                                    )
                            )

                    _ ->
                        JD.fail <| "Unknown Opponent type: '" ++ type_ ++ "'"
            )


encode : OpponentType -> JE.Value
encode opponentType =
    case opponentType of
        Npc enemyType ->
            JE.object
                [ ( "type", JE.string "npc" )
                , ( "enemyType", Enemy.encodeType enemyType )
                ]

        Player { name, xp } ->
            JE.object
                [ ( "type", JE.string "player" )
                , ( "name", JE.string name )
                , ( "xp", JE.int xp )
                ]
