module Data.Fight.OpponentType exposing
    ( OpponentType(..)
    , PlayerOpponent
    , codec
    )

import Codec exposing (Codec)
import Data.Enemy.Type as EnemyType exposing (EnemyType)
import Data.Player.PlayerName exposing (PlayerName)


type OpponentType
    = Npc EnemyType
    | Player PlayerOpponent


type alias PlayerOpponent =
    { name : PlayerName
    , xp : Int
    }


codec : Codec OpponentType
codec =
    Codec.custom
        (\npcEncoder playerEncoder value ->
            case value of
                Npc arg0 ->
                    npcEncoder arg0

                Player arg0 ->
                    playerEncoder arg0
        )
        |> Codec.variant1 "Npc" Npc EnemyType.codec
        |> Codec.variant1 "Player" Player playerOpponentCodec
        |> Codec.buildCustom


playerOpponentCodec : Codec PlayerOpponent
playerOpponentCodec =
    Codec.object PlayerOpponent
        |> Codec.field "name" .name Codec.string
        |> Codec.field "xp" .xp Codec.int
        |> Codec.buildObject
