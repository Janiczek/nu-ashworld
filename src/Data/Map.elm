module Data.Map exposing
    ( PxCoords
    , TileCoords
    , TileNum
    , allTileCoords
    , columns
    , encodeCoords
    , neighbours
    , rows
    , tileCenterPx
    , tileSize
    , tileSizeFloat
    , toTileCoords
    , toTileNum
    )

import Json.Encode as JE
import Set exposing (Set)


type alias TileNum =
    Int


type alias TileCoords =
    ( Int, Int )


type alias PxCoords =
    ( Float, Float )


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


neighbours : TileCoords -> Set TileCoords
neighbours ( x, y ) =
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


encodeCoords : TileCoords -> JE.Value
encodeCoords ( x, y ) =
    JE.list JE.int [ x, y ]


allTileCoords : List TileCoords
allTileCoords =
    let
        columns_ =
            List.range 0 (columns - 1)

        rows_ =
            List.range 0 (rows - 1)
    in
    columns_ |> List.concatMap (\x -> rows_ |> List.map (\y -> ( x, y )))
