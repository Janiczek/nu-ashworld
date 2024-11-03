module Data.Item.KindTest exposing (suite)

import Data.Enemy as Enemy
import Data.Enemy.Type exposing (EnemyType)
import Data.Item.Kind as ItemKind
import Data.Map as Map
import Data.Map.SmallChunk as SmallChunk
import Data.Quest as Quest
import Data.Vendor.Shop as Shop
import Expect
import List.ExtraExtra as List
import SeqDict
import SeqSet exposing (SeqSet)
import Test exposing (Test)


suite : Test
suite =
    Test.describe "Data.Item.Kind"
        [ allObtainable
        ]


allObtainable : Test
allObtainable =
    Test.test "All items are obtainable via shops, PVM drops or quests" <|
        \() ->
            let
                availableInBaseShopSpecs : SeqSet ItemKind.Kind
                availableInBaseShopSpecs =
                    Shop.all
                        |> List.fastConcatMap
                            (\shop ->
                                shop
                                    |> Shop.initialSpec
                                    |> .stock
                                    |> SeqDict.keys
                                    |> List.map .kind
                            )
                        |> SeqSet.fromList

                availableInQuestRewardShopSpecs : SeqSet ItemKind.Kind
                availableInQuestRewardShopSpecs =
                    Quest.all
                        |> List.fastConcatMap
                            (\quest ->
                                quest
                                    |> Quest.globalRewards
                                    |> List.filterMap
                                        (\reward ->
                                            case reward of
                                                Quest.NewItemsInStock { what } ->
                                                    Just what

                                                Quest.Discount _ ->
                                                    Nothing

                                                Quest.VendorAvailable _ ->
                                                    Nothing

                                                Quest.EndTheGame ->
                                                    Nothing
                                        )
                            )
                        |> SeqSet.fromList

                availableInPersonalQuestRewards : SeqSet ItemKind.Kind
                availableInPersonalQuestRewards =
                    Quest.all
                        |> List.fastConcatMap
                            (\quest ->
                                quest
                                    |> Quest.playerRewards
                                    |> List.filterMap
                                        (\reward ->
                                            case reward of
                                                Quest.ItemReward { what } ->
                                                    Just what

                                                Quest.SkillUpgrade _ ->
                                                    Nothing

                                                Quest.PerkReward _ ->
                                                    Nothing

                                                Quest.CarReward ->
                                                    Nothing

                                                Quest.CapsReward _ ->
                                                    Nothing

                                                Quest.TravelToEnclaveReward ->
                                                    Nothing
                                        )
                            )
                        |> SeqSet.fromList

                reachableEnemies : List EnemyType
                reachableEnemies =
                    Map.allTileCoords
                        |> List.map SmallChunk.forCoords
                        |> List.fastConcatMap Enemy.forSmallChunk

                availableInEnemyDrops : SeqSet ItemKind.Kind
                availableInEnemyDrops =
                    reachableEnemies
                        |> List.fastConcatMap
                            (\enemy ->
                                enemy
                                    |> Enemy.dropSpec
                                    |> .items
                                    |> List.map (\( _, item ) -> item.uniqueKey.kind)
                            )
                        |> SeqSet.fromList

                allAvailableItems : SeqSet ItemKind.Kind
                allAvailableItems =
                    List.foldl
                        SeqSet.union
                        SeqSet.empty
                        [ availableInBaseShopSpecs
                        , availableInQuestRewardShopSpecs
                        , availableInPersonalQuestRewards
                        , availableInEnemyDrops
                        ]

                notReachable : List ItemKind.Kind
                notReachable =
                    ItemKind.all
                        |> List.filter (\kind -> not (SeqSet.member kind allAvailableItems))
            in
            notReachable
                |> Expect.equalLists []
