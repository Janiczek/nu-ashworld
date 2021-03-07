module Data.Map exposing
    ( PxCoords
    , TileCoords
    , TileNum
    , allTiles
    , columns
    , distantTiles
    , height
    , rows
    , tileCenterPx
    , tileSize
    , tileSizeFloat
    , tileSrc
    , tilesCount
    , toTileCoords
    , toTileNum
    , width
    )

import Set exposing (Set)


type alias TileNum =
    Int


type alias TileCoords =
    ( Int, Int )


type alias PxCoords =
    ( Float, Float )


tilesCount : Int
tilesCount =
    columns * rows


columns : Int
columns =
    28


rows : Int
rows =
    30


tileSize : Int
tileSize =
    50


width : Int
width =
    tileSize * columns


height : Int
height =
    tileSize * rows


allTiles : Set TileNum
allTiles =
    List.range 0 (columns * rows - 1)
        |> Set.fromList


distantTiles : Set TileNum -> Set TileNum
distantTiles knownTiles =
    Set.diff allTiles knownTiles


tileSizeFloat : Float
tileSizeFloat =
    toFloat tileSize


tileCenterPx : TileCoords -> PxCoords
tileCenterPx ( x, y ) =
    ( tileSizeFloat * (toFloat x + 0.5)
    , tileSizeFloat * (toFloat y + 0.5)
    )


tileSrc : TileNum -> String
tileSrc tileNum =
    "images/map/tile_"
        ++ String.padLeft 3 '0' (String.fromInt tileNum)
        ++ ".png"


toTileCoords : TileNum -> TileCoords
toTileCoords tileNum =
    let
        x =
            tileNum |> remainderBy columns

        y =
            tileNum // columns
    in
    ( x, y )


toTileNum : TileCoords -> TileNum
toTileNum ( x, y ) =
    y * columns + x
