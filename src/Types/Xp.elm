module Types.Xp exposing (Level, Xp, nextLevelXp, xpToLevel, xpUntilNextLevel)

import List.Extra


type alias Xp =
    Int


type alias Level =
    Int


xpForLevel : Level -> Xp
xpForLevel level =
    level * (level - 1) // 2 * 1000


levelCap : Level
levelCap =
    99


xpTable : List ( Level, Xp )
xpTable =
    List.range 1 levelCap
        |> List.map (\lvl -> ( lvl, xpForLevel lvl ))


xpToLevel : Xp -> Level
xpToLevel xp =
    -- it's easiest to find just one level above the current one and subtract one
    xpTable
        |> List.Extra.dropWhile (\( lvl, xp_ ) -> xp_ <= xp)
        |> List.head
        |> Maybe.map (Tuple.first >> (\lvl -> lvl - 1))
        |> Maybe.withDefault levelCap


nextLevelXp : Xp -> Xp
nextLevelXp currentXp =
    currentXp
        |> xpToLevel
        |> (+) 1
        |> xpForLevel


xpUntilNextLevel : Xp -> Xp
xpUntilNextLevel currentXp =
    let
        currentLevel =
            xpToLevel currentXp

        nextLevel =
            currentLevel + 1

        nextXp =
            xpForLevel nextLevel
    in
    nextXp - currentXp
