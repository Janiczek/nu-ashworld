module Calculator.BarterPrice exposing (main)

import Browser
import Data.Item as Item
import Data.Vendor as Vendor
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Logic


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
    , vendorBarterInput : String
    , basePriceInput : String
    , hasMasterTraderPerk : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { playerBarterInput = "50"
      , vendorBarterInput = "100"
      , basePriceInput = "250"
      , hasMasterTraderPerk = False
      }
    , Cmd.none
    )


type Msg
    = SetPlayerBarterInput String
    | SetVendorBarterInput String
    | SetBasePriceInput String
    | SetMasterTraderPerk Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetPlayerBarterInput string ->
            ( { model | playerBarterInput = string }, Cmd.none )

        SetVendorBarterInput string ->
            ( { model | vendorBarterInput = string }, Cmd.none )

        SetBasePriceInput string ->
            ( { model | basePriceInput = string }, Cmd.none )

        SetMasterTraderPerk bool ->
            ( { model | hasMasterTraderPerk = bool }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        maybePrice : Maybe Int
        maybePrice =
            Maybe.map3
                (\playerBarterSkill vendorBarterSkill basePrice ->
                    Logic.price
                        { baseValue = basePrice
                        , playerBarterSkill = playerBarterSkill
                        , traderBarterSkill = vendorBarterSkill
                        , hasMasterTraderPerk = model.hasMasterTraderPerk
                        }
                )
                (String.toInt model.playerBarterInput)
                (String.toInt model.vendorBarterInput)
                (String.toInt model.basePriceInput)

        itemView : Item.Kind -> Html Msg
        itemView kind =
            let
                basePrice =
                    String.fromInt <| Item.baseValue kind
            in
            H.li
                [ HE.onClick <| SetBasePriceInput basePrice ]
                [ H.text <| Item.name kind ++ " ($" ++ basePrice ++ ")" ]

        vendorView : Vendor.Name -> Html Msg
        vendorView vendor =
            H.li
                [ HE.onClick <| SetVendorBarterInput <| String.fromInt <| Vendor.barterSkill vendor ]
                [ H.text <| Vendor.name vendor ]
    in
    { title = "Barter Price Calculator - NuAshworld"
    , body =
        [ H.node "style" [] [ H.text style ]
        , H.h1 [] [ H.text "Barter Price Calculator" ]
        , H.h2 [] [ H.text "NuAshworld" ]
        , H.div [ HA.id "columns" ]
            [ H.div [ HA.class "column" ]
                [ H.div []
                    [ H.div [] [ H.text "Your Barter skill %: " ]
                    , H.input
                        [ HA.value model.playerBarterInput
                        , HE.onInput SetPlayerBarterInput
                        , HA.type_ "number"
                        ]
                        []
                    ]
                , H.div []
                    [ H.div [] [ H.text "Vendor's Barter skill %: " ]
                    , H.input
                        [ HA.value model.vendorBarterInput
                        , HE.onInput SetVendorBarterInput
                        , HA.type_ "number"
                        ]
                        []
                    ]
                , H.div []
                    [ H.div [] [ H.text "Item base price: " ]
                    , H.input
                        [ HA.value model.basePriceInput
                        , HE.onInput SetBasePriceInput
                        , HA.type_ "number"
                        ]
                        []
                    ]
                , H.div
                    [ HE.onClick <| SetMasterTraderPerk <| not model.hasMasterTraderPerk ]
                    [ H.input
                        [ HA.type_ "checkbox"
                        , HA.checked model.hasMasterTraderPerk
                        ]
                        []
                    , H.text "Do you have the Master Trader perk?"
                    ]
                , H.div [ HA.id "final-price" ]
                    [ H.span
                        [ HA.class "text-yellow" ]
                        [ H.text "Final price: " ]
                    , H.text <|
                        case maybePrice of
                            Nothing ->
                                "Error, check your inputs. Only use numbers, no symbols."

                            Just price ->
                                String.fromInt price
                    ]
                ]
            , H.div [ HA.class "column" ]
                [ H.h3 [] [ H.text "Items" ]
                , H.p [] [ H.text "Click on an item to use its base price." ]
                , H.ul [] (List.map itemView Item.all)
                ]
            , H.div [ HA.class "column" ]
                [ H.h3 [] [ H.text "Vendor" ]
                , H.p [] [ H.text "Click on a vendor to use their barter skill %." ]
                , H.ul [] (List.map vendorView Vendor.all)
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


style : String
style =
    """
body {
    margin: 20px;
}
#columns {
    gap: 10px;
    display: flex;
    flex-direction: row;
    align-items: stretch;
    justify-content: stretch;
}

.column {
    flex: 1;
    background-color: #ddd;
    padding: 20px;
}

#final-price {
    margin-top: 20px;
}
"""
