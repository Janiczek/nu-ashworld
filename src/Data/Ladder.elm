module Data.Ladder exposing (sort, sortMixed)

import Data.Player as Player exposing (COtherPlayer, CPlayer)


sort : List { p | xp : Int } -> List { p | xp : Int }
sort players =
    -- TODO tie-breakers? W/L ratio? caps?
    players
        |> List.sortBy (negate << .xp)


sortMixed :
    { player : CPlayer
    , playerRank : Int
    , otherPlayers : List COtherPlayer
    }
    -> List COtherPlayer
sortMixed { player, playerRank, otherPlayers } =
    ( playerRank - 1, 0, Player.clientToClientOther player )
        :: List.indexedMap (\i p -> ( i, 1, p )) otherPlayers
        |> List.sortBy (\( i, isP, _ ) -> ( i, isP ))
        |> List.map (\( _, _, p ) -> p)
