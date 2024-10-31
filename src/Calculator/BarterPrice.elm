module Calculator.BarterPrice exposing (main)

import Browser
import Data.Item.Kind as ItemKind
import Data.Map.Location as Location
import Data.Vendor.Shop as Shop exposing (Shop)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Logic
import Tailwind as TW
import UI


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { playerBarterInput : String
    , vendorBarter : Int
    , basePriceInput : String
    , hasMasterTraderPerk : Bool
    , discountPctInput : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { playerBarterInput = "50"
      , vendorBarter = 100
      , basePriceInput = "250"
      , hasMasterTraderPerk = False
      , discountPctInput = "0"
      }
    , Cmd.none
    )


type Msg
    = SetPlayerBarterInput String
    | SetVendorBarter Int
    | SetBasePriceInput String
    | SetMasterTraderPerk Bool
    | SetDiscountPctInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPlayerBarterInput string ->
            ( { model | playerBarterInput = string }, Cmd.none )

        SetVendorBarter int ->
            ( { model | vendorBarter = int }, Cmd.none )

        SetBasePriceInput string ->
            ( { model | basePriceInput = string }, Cmd.none )

        SetMasterTraderPerk bool ->
            ( { model | hasMasterTraderPerk = bool }, Cmd.none )

        SetDiscountPctInput string ->
            ( { model | discountPctInput = string }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        maybePrice : Maybe Int
        maybePrice =
            Maybe.map3
                (\playerBarterSkill basePrice discountPct ->
                    Logic.price
                        { baseValue = basePrice
                        , playerBarterSkill = playerBarterSkill
                        , traderBarterSkill = model.vendorBarter
                        , hasMasterTraderPerk = model.hasMasterTraderPerk
                        , discountPct = discountPct
                        }
                )
                (String.toInt model.playerBarterInput)
                (String.toInt model.basePriceInput)
                (String.toInt model.discountPctInput)

        itemView : ItemKind.Kind -> Html Msg
        itemView kind =
            let
                basePrice =
                    String.fromInt <| ItemKind.baseValue kind
            in
            H.li
                [ HE.onClick <| SetBasePriceInput basePrice
                , HA.class "cursor-pointer"
                , TW.mod "hover" "bg-green-800 text-green-100"
                , TW.mod "active" "text-yellow"
                ]
                [H.text <| ItemKind.name kind ++ " "
                , H.span
                    [ HA.class "text-green-100" ]
                    [ H.text <| "($" ++ basePrice ++ ")" ]
                ]

        vendorView : Shop -> Html Msg
        vendorView shop =
            H.li
                [ HE.onClick <| SetVendorBarter <| Shop.barterSkill shop
                , HA.class "cursor-pointer"
                , TW.mod "hover" "bg-green-800 text-green-100"
                , TW.mod "active" "text-yellow"
                ]
                [ H.text <| Shop.personName shop ++ " "
                , H.span [ HA.class "text-green-300" ] [ H.text <| "(" ++ Location.name (Shop.location shop) ++ ", skill " ]
                , H.span [ HA.class "text-green-100" ] [ H.text <| String.fromInt (Shop.barterSkill shop) ++ "%" ]
                , H.span [ HA.class "text-green-300" ] [ H.text ")" ]
                ]
    in
    { title = "Barter Price Calculator - NuAshworld"
    , body =
        [ H.div [ HA.class "flex flex-col gap-2 p-4" ]
            [ H.h1
                [ HA.class "text-lg font-bold mb-10" ]
                [ H.text "Barter Price Calculator" ]
            , H.div [ HA.class "grid grid-cols-[repeat(3,minmax(auto,1fr))] gap-2 flex-1" ]
                [ H.div [ HA.class "flex flex-col gap-2 mt-14" ]
                    [ H.div []
                        [ H.div [] [ H.text "Your Barter skill %: " ]
                        , UI.input
                            [ HA.value model.playerBarterInput
                            , HE.onInput SetPlayerBarterInput
                            , HA.type_ "number"
                            , HA.class "border py-1 px-2 border-green-300 text-green-100"
                            ]
                            []
                        ]
                    , H.div []
                        [ H.div [] [ H.text "Vendor's Barter skill %: " ]
                        , UI.input
                            [ HA.value <| String.fromInt model.vendorBarter
                            , HA.type_ "number"
                            , HA.disabled True
                            , HA.title "Set via the vendor list."
                            , HA.class "border py-1 px-2 border-green-300 text-green-300"
                            ]
                            []
                        ]
                    , H.div []
                        [ H.div [] [ H.text "Item base price: " ]
                        , UI.input
                            [ HA.value model.basePriceInput
                            , HE.onInput SetBasePriceInput
                            , HA.type_ "number"
                            , HA.class "border py-1 px-2 border-green-300 text-green-100"
                            ]
                            []
                        ]
                    , H.div []
                        [ H.div [] [ H.text "Discount % (eg. from quests):" ]
                        , UI.input
                            [ HA.value model.discountPctInput
                            , HE.onInput SetDiscountPctInput
                            , HA.type_ "number"
                            , HA.class "border py-1 px-2 border-green-300 text-green-100"
                            ]
                            []
                        ]
                    , H.div [ HA.class "text-left" ]
                        [ UI.checkbox
                            { label = "Do you have the Master Trader perk?"
                            , isOn = model.hasMasterTraderPerk
                            , toggle = SetMasterTraderPerk
                            }
                        ]
                    , H.div []
                        [ H.span
                            [ HA.class "text-yellow text-wrap" ]
                            [ H.text "Shop will sell for: " ]
                        , case maybePrice of
                            Nothing ->
                                H.text
                                    "Error, check your inputs. Only use numbers, no symbols."

                            Just price ->
                                H.span [ HA.class "text-green-100" ] [ H.text <| "$" ++ String.fromInt price ]
                        ]
                    ]
                , H.div [ HA.class "flex flex-col gap-2" ]
                    [ UI.bold "Items"
                    , H.p [] [ H.text "Click on an item to use its base price." ]
                    , H.ul [] (List.map itemView ItemKind.all)
                    ]
                , H.div [ HA.class "flex flex-col gap-2" ]
                    [ UI.bold "Vendor"
                    , H.p [] [ H.text "Click on a vendor to use their barter skill %." ]
                    , H.ul [] (List.map vendorView Shop.all)
                    ]
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
