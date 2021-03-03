module Data.Xp exposing
    ( Level
    , Xp
    , currentLevel
    , nextLevelXp
    , xpUntilNextLevel
    )

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


currentLevel : Xp -> Level
currentLevel xp =
    -- it's easiest to find just one level above the current one and subtract one
    xpTable
        |> List.Extra.dropWhile (\( lvl, xp_ ) -> xp_ <= xp)
        |> List.head
        |> Maybe.map (Tuple.first >> (\lvl -> lvl - 1))
        |> Maybe.withDefault levelCap


nextLevelXp : Xp -> Xp
nextLevelXp currentXp =
    currentXp
        |> currentLevel
        |> (+) 1
        |> xpForLevel


xpUntilNextLevel : Xp -> Xp
xpUntilNextLevel currentXp =
    let
        currentLevel_ =
            currentLevel currentXp

        nextLevel =
            currentLevel_ + 1

        nextXp =
            xpForLevel nextLevel
    in
    nextXp - currentXp
