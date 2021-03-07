module Data.Map exposing
    ( PxCoords
    , TileCoords
    , TileNum
    , TileVisibility(..)
    , columns
    , neighbours
    , rows
    , tileCenterPx
    , tileSize
    , tileSizeFloat
    , tileSrc
    , tilesCount
    , toTileCoords
    , toTileNum
    )

import Set exposing (Set)


type alias TileNum =
    Int


type alias TileCoords =
    ( Int, Int )


type alias PxCoords =
    ( Float, Float )


type TileVisibility
    = Known
    | Distant
    | Unknown


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


neighbours : TileNum -> Set TileNum
neighbours tileNum =
    let
        neighbours_ : TileCoords -> Set TileCoords
        neighbours_ ( x, y ) =
            let
                left : Bool
                left =
                    x > 0

                top : Bool
                top =
                    y > 0

                right : Bool
                right =
                    x < columns - 1

                bottom : Bool
                bottom =
                    y < rows - 1
            in
            [ if left && top then
                Just ( x - 1, y - 1 )

              else
                Nothing
            , if top then
                Just ( x, y - 1 )

              else
                Nothing
            , if right && top then
                Just ( x + 1, y - 1 )

              else
                Nothing
            , if left then
                Just ( x - 1, y )

              else
                Nothing
            , if right then
                Just ( x + 1, y )

              else
                Nothing
            , if left && bottom then
                Just ( x - 1, y + 1 )

              else
                Nothing
            , if bottom then
                Just ( x, y + 1 )

              else
                Nothing
            , if right && bottom then
                Just ( x + 1, y + 1 )

              else
                Nothing
            ]
                |> List.filterMap identity
                |> Set.fromList
    in
    tileNum
        |> toTileCoords
        |> neighbours_
        |> Set.map toTileNum
