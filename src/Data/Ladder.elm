module Data.Ladder exposing (sort, sortMixed)

import Data.Player as Player exposing (COtherPlayer, CPlayer)
import Sort exposing (Sorter)


type alias Sortable p =
    { p | xp : Int, wins : Int, losses : Int, caps : Int }


sorter : Sorter (Sortable p)
sorter =
    let
        byXp : Sorter (Sortable p)
        byXp =
            Sort.reverse (Sort.by .xp Sort.increasing)

        byWinsLossesRatio : Sorter (Sortable p)
        byWinsLossesRatio =
            Sort.reverse (Sort.by (\{ wins, losses } -> toFloat wins / toFloat losses) Sort.increasing)

        byCaps : Sorter (Sortable p)
        byCaps =
            Sort.reverse (Sort.by .caps Sort.increasing)
    in
    byXp
        |> Sort.tiebreaker byWinsLossesRatio
        |> Sort.tiebreaker byCaps


sort : List (Sortable p) -> List (Sortable p)
sort players =
    Sort.list sorter players


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
