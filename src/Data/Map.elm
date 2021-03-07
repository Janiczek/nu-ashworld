module Data.Map exposing
    ( Coords
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
    , toCoords
    , toTileNum
    , touchedTiles
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


tileCenterPx : Coords -> ( Float, Float )
tileCenterPx ( x, y ) =
    ( tileSizeFloat * (toFloat x + 0.5)
    , tileSizeFloat * (toFloat y + 0.5)
    )


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


sign : number -> number
sign n =
    case compare n 0 of
        LT ->
            -1

        EQ ->
            0

        GT ->
            1


symFloor : Float -> Float
symFloor n =
    sign n * toFloat (floor (abs n))


symCeiling : Float -> Float
symCeiling n =
    sign n * toFloat (ceiling (abs n))


ceilingToMultipleOf : Float -> Float -> Float
ceilingToMultipleOf d n =
    d * symCeiling (n / d)


floorToMultipleOf : Float -> Float -> Float
floorToMultipleOf d n =
    d * symFloor (n / d)


touchedTiles : Float -> ( Float, Float ) -> ( Float, Float ) -> Set Coords
touchedTiles tileSizePx ( fromPxX, fromPxY ) ( toPxX, toPxY ) =
    let
        fromTile : Coords
        fromTile =
            ( floor <| fromPxX / tileSizePx
            , floor <| fromPxY / tileSizePx
            )

        ( fromTileX, fromTileY ) =
            fromTile

        toTile : Coords
        toTile =
            ( floor <| toPxX / tileSizePx
            , floor <| toPxY / tileSizePx
            )
    in
    if fromTile == toTile then
        Set.singleton fromTile

    else
        let
            moveTilePx : Bool -> Float -> Float
            moveTilePx goNegative current =
                let
                    fn =
                        if goNegative then
                            floorToMultipleOf tileSizePx

                        else
                            ceilingToMultipleOf tileSizePx

                    potentiallyNew =
                        fn current
                in
                if current == potentiallyNew then
                    if goNegative then
                        potentiallyNew - tileSizePx

                    else
                        potentiallyNew + tileSizePx

                else
                    potentiallyNew

            moveX : Float -> Float
            moveX =
                moveTilePx rayDirXNegative

            moveY : Float -> Float
            moveY =
                moveTilePx rayDirYNegative

            normalize : ( Float, Float ) -> ( Float, Float )
            normalize ( x, y ) =
                let
                    length =
                        sqrt (x ^ 2 + y ^ 2)
                in
                ( x / length
                , y / length
                )

            ( rayDirX, rayDirY ) =
                normalize
                    ( toPxX - fromPxX
                    , toPxY - fromPxY
                    )

            ( moveYForUnitOfX, moveXForUnitOfY ) =
                ( rayDirY / rayDirX
                , rayDirX / rayDirY
                )

            ( rayUnitStepSizeX, rayUnitStepSizeY ) =
                ( abs <| 1 / rayDirX
                , abs <| 1 / rayDirY
                )

            rayDirXNegative : Bool
            rayDirXNegative =
                rayDirX < 0

            rayDirYNegative : Bool
            rayDirYNegative =
                rayDirY < 0

            stepX : Int
            stepX =
                if rayDirXNegative then
                    -1

                else
                    1

            stepY : Int
            stepY =
                if rayDirYNegative then
                    -1

                else
                    1

            ( initRayLengthX, initRayLengthY ) =
                ( abs <| (moveX fromPxX - fromPxX) * rayUnitStepSizeX
                , abs <| (moveY fromPxY - fromPxY) * rayUnitStepSizeY
                )

            firstStepGoX : Bool
            firstStepGoX =
                initRayLengthX < initRayLengthY

            firstStepPx : ( Float, Float )
            firstStepPx =
                if firstStepGoX then
                    let
                        newX =
                            moveX fromPxX
                    in
                    ( newX
                    , fromPxY + (newX - fromPxX) * moveYForUnitOfX
                    )

                else
                    let
                        newY =
                            moveY fromPxY
                    in
                    ( fromPxX + (newY - fromPxY) * moveXForUnitOfY
                    , newY
                    )

            firstStepTile : Coords
            firstStepTile =
                if firstStepGoX then
                    ( fromTileX + stepX, fromTileY )

                else
                    ( fromTileX, fromTileY + stepY )

            go : ( Float, Float ) -> Coords -> Set Coords -> Set Coords
            go ( currentX, currentY ) ( x, y ) touched =
                if ( x, y ) == toTile then
                    touched

                else
                    let
                        ( rayLengthX, rayLengthY ) =
                            ( abs <| (moveX currentX - currentX) * rayUnitStepSizeX
                            , abs <| (moveY currentY - currentY) * rayUnitStepSizeY
                            )

                        goX : Bool
                        goX =
                            rayLengthX < rayLengthY

                        ( newX, newY ) =
                            if goX then
                                ( x + stepX, y )

                            else
                                ( x, y + stepY )

                        newTouched : Set Coords
                        newTouched =
                            Set.insert ( newX, newY ) touched

                        newPx : ( Float, Float )
                        newPx =
                            if goX then
                                let
                                    newX_ =
                                        moveX currentX
                                in
                                ( newX_
                                , currentY + (newX_ - currentX) * moveYForUnitOfX
                                )

                            else
                                let
                                    newY_ =
                                        moveY currentY
                                in
                                ( currentX + (newY_ - currentY) * moveXForUnitOfY
                                , newY_
                                )
                    in
                    go newPx ( newX, newY ) newTouched
        in
        go firstStepPx firstStepTile (Set.fromList [ fromTile, firstStepTile ])
