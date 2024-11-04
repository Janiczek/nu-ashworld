module Data.Map exposing
    ( PxCoords
    , TileCoords
    , allTileCoords
    , columns
    , neighbours
    , rows
    , tileCenterPx
    , tileCoordsCodec
    , tileSize
    , tileSizeFloat
    )

import Codec exposing (Codec)
import List.ExtraExtra as List
import Set exposing (Set)


type alias TileCoords =
    ( Int, Int )


type alias PxCoords =
    ( Float, Float )


tileCoordsCodec : Codec TileCoords
tileCoordsCodec =
    Codec.tuple Codec.int Codec.int


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


allTileCoords : List TileCoords
allTileCoords =
    let
        columns_ =
            List.range 0 (columns - 1)

        rows_ =
            List.range 0 (rows - 1)
    in
    columns_ |> List.fastConcatMap (\x -> rows_ |> List.map (\y -> ( x, y )))
