module Data.Item.KindTest exposing (suite)

import Data.Enemy as Enemy
import Data.Item.Kind as ItemKind
import Data.Map as Map
import Data.Map.BigChunk as BigChunk
import Data.Map.SmallChunk as SmallChunk
import Data.Quest as Quest
import Data.Vendor.Shop as Shop
import Expect
import Fuzz exposing (Fuzzer)
import SeqSet exposing (SeqSet)
import Test exposing (Test)
import TestHelpers


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
                        |> List.concatMap
                            (\shop ->
                                shop
                                    |> Shop.initialSpec
                                    |> .stock
                                    |> List.map (\spec -> spec.uniqueKey.kind)
                            )
                        |> SeqSet.fromList

                availableInQuestRewardShopSpecs : SeqSet ItemKind.Kind
                availableInQuestRewardShopSpecs =
                    Quest.all
                        |> List.concatMap
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
                                        )
                            )
                        |> SeqSet.fromList

                availableInPersonalQuestRewards : SeqSet ItemKind.Kind
                availableInPersonalQuestRewards =
                    Quest.all
                        |> List.concatMap
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
                                        )
                            )
                        |> SeqSet.fromList

                reachableEnemies : List Enemy.Type
                reachableEnemies =
                    Map.allTileCoords
                        |> List.map SmallChunk.forCoords
                        |> List.concatMap Enemy.forSmallChunk

                availableInEnemyDrops : SeqSet ItemKind.Kind
                availableInEnemyDrops =
                    reachableEnemies
                        |> List.concatMap
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
