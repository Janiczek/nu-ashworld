module Data.Map exposing
    ( Coords
    , TileNum
    , TileVisibility(..)
    , columns
    , neighbours
    , rows
    , tileHeight
    , tileSrc
    , tileWidth
    , tilesCount
    , toCoords
    , toTileNum
    , updateVisibility
    )

import Set exposing (Set)


type alias TileNum =
    Int


type alias Coords =
    ( Int, Int )


type TileVisibility
    = Known
    | Distant
    | Unknown


updateVisibility : TileVisibility -> TileVisibility -> TileVisibility
updateVisibility t1 t2 =
    case ( t1, t2 ) of
        ( Known, _ ) ->
            Known

        ( _, Known ) ->
            Known

        ( Distant, _ ) ->
            Distant

        ( _, Distant ) ->
            Distant

        _ ->
            Unknown


tilesCount : Int
tilesCount =
    columns * rows


columns : Int
columns =
    28


rows : Int
rows =
    30


tileWidth : Int
tileWidth =
    50


tileHeight : Int
tileHeight =
    50


tileSrc : TileNum -> String
tileSrc tileNum =
    "images/map/tile_"
        ++ String.padLeft 3 '0' (String.fromInt tileNum)
        ++ ".png"


toCoords : TileNum -> Coords
toCoords tileNum =
    let
        x =
            tileNum |> remainderBy columns

        y =
            tileNum // columns
    in
    ( x, y )


toTileNum : Coords -> TileNum
toTileNum ( x, y ) =
    y * columns + x


neighbours : TileNum -> Set TileNum
neighbours tileNum =
    let
        neighbours_ : Coords -> Set Coords
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
        |> toCoords
        |> neighbours_
        |> Set.map toTileNum
