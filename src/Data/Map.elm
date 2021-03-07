module Data.Map exposing
    ( PxCoords
    , TileCoords
    , TileNum
    , TileVisibility(..)
    , columns
    , neighbours
    , rows
    , test
    , tileCenterPx
    , tileSize
    , tileSizeFloat
    , tileSrc
    , tilesCount
    , toTileCoords
    , toTileNum
    , touchedTiles
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


sign : number -> number
sign n =
    case compare n 0 of
        LT ->
            -1

        EQ ->
            0

        GT ->
            1


symFloor : Float -> Int
symFloor n =
    sign (round n) * floor (abs n)


symCeiling : Float -> Int
symCeiling n =
    sign (round n) * ceiling (abs n)


ceilingToMultipleOf : Float -> Float -> Float
ceilingToMultipleOf d n =
    d * toFloat (symCeiling (n / d))


floorToMultipleOf : Float -> Float -> Float
floorToMultipleOf d n =
    d * toFloat (symFloor (n / d))


touchedTiles : Float -> PxCoords -> PxCoords -> Set TileCoords
touchedTiles tileSizePx (( fromPxX, fromPxY ) as fromPx) ( toPxX, toPxY ) =
    let
        fromTile : TileCoords
        fromTile =
            ( floor <| fromPxX / tileSizePx
            , floor <| fromPxY / tileSizePx
            )

        ( fromTileX, fromTileY ) =
            fromTile

        toTile : TileCoords
        toTile =
            ( floor <| toPxX / tileSizePx
            , floor <| toPxY / tileSizePx
            )
    in
    if fromTile == toTile then
        Set.singleton fromTile

    else
        let
            moveToTileEdge : Bool -> Float -> Float
            moveToTileEdge goNegative current =
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

            movePx : Order -> PxCoords -> PxCoords
            movePx xVsY_ ( pxX, pxY ) =
                case xVsY_ of
                    LT ->
                        let
                            newX =
                                moveX pxX
                        in
                        ( newX
                        , pxY + (newX - pxX) * moveYForUnitOfX
                        )

                    EQ ->
                        let
                            newX =
                                moveX pxX

                            newY =
                                moveY pxY
                        in
                        ( newX, newY )

                    GT ->
                        let
                            newY =
                                moveY pxY
                        in
                        ( pxX + (newY - pxY) * moveXForUnitOfY
                        , newY
                        )

            moveX : Float -> Float
            moveX =
                moveToTileEdge rayDirXNegative

            moveY : Float -> Float
            moveY =
                moveToTileEdge rayDirYNegative

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

            ( initRayLengthX, initRayLengthY ) =
                ( abs <| (moveX fromPxX - fromPxX) * rayUnitStepSizeX
                , abs <| (moveY fromPxY - fromPxY) * rayUnitStepSizeY
                )

            initXVsY : Order
            initXVsY =
                compare initRayLengthX initRayLengthY

            firstStepPx : PxCoords
            firstStepPx =
                movePx initXVsY ( fromPxX, fromPxY )

            moveALittle : Bool -> Float -> Float
            moveALittle negative coord =
                if negative then
                    coord - 1

                else
                    coord + 1

            tileForPx : PxCoords -> TileCoords
            tileForPx ( x, y ) =
                ( symFloor <| moveALittle rayDirXNegative x / tileSizePx
                , symFloor <| moveALittle rayDirYNegative y / tileSizePx
                )

            firstStepTile : TileCoords
            firstStepTile =
                tileForPx firstStepPx

            go : PxCoords -> TileCoords -> Set TileCoords -> Set TileCoords
            go ( currentX, currentY ) ( x, y ) seenTiles =
                if ( x, y ) == toTile then
                    seenTiles

                else
                    let
                        ( rayLengthX, rayLengthY ) =
                            ( abs <| (moveX currentX - currentX) * rayUnitStepSizeX
                            , abs <| (moveY currentY - currentY) * rayUnitStepSizeY
                            )

                        xVsY : Order
                        xVsY =
                            compare rayLengthX rayLengthY

                        newPx : ( Float, Float )
                        newPx =
                            movePx xVsY ( currentX, currentY )

                        (( newX, newY ) as newTile) =
                            tileForPx newPx

                        newTiles : Set TileCoords
                        newTiles =
                            Set.insert newTile seenTiles
                    in
                    go newPx newTile newTiles
        in
        go firstStepPx firstStepTile (Set.fromList [ fromTile, firstStepTile ])


test : TileCoords -> ()
test coords =
    let
        _ =
            List.range 0 (columns - 1)
                |> List.concatMap
                    (\x ->
                        List.range 0 (rows - 1)
                            |> List.map
                                (\y ->
                                    let
                                        _ =
                                            Debug.log "starting" ( x, y )
                                    in
                                    let
                                        _ =
                                            ( x
                                            , y
                                            , touchedTiles
                                                tileSizeFloat
                                                (tileCenterPx coords)
                                                (tileCenterPx ( x, y ))
                                            )
                                    in
                                    let
                                        _ =
                                            Debug.log "done" ( x, y )
                                    in
                                    ()
                                )
                    )
    in
    ()
