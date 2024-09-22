module UI exposing
    ( bold
    , button
    , checkboxButton
    , checkboxLabel
    , input
    , liBullet
    , textarea
    )

import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Tailwind as TW


button : List (Attribute msg) -> List (Html msg) -> Html msg
button attrs content =
    H.button
        (HA.class "uppercase whitespace-pre cursor-pointer text-green-200 select-none"
            :: TW.mod "disabled" "text-green-300"
            :: TW.mod "hover" "text-green-100 outline-green-100"
            :: TW.mod "active" "text-green-100 outline-green-100"
            :: attrs
        )
        content


input : List (Attribute msg) -> List (Html msg) -> Html msg
input attrs content =
    H.input
        (HA.class "bg-transparent"
            :: TW.mod "focus" "outline-none"
            :: attrs
        )
        content


textarea : List (Attribute msg) -> List (Html msg) -> Html msg
textarea attrs content =
    H.textarea
        (HA.class "bg-transparent"
            :: TW.mod "focus" "outline-none"
            :: attrs
        )
        content


bold : String -> Html msg
bold text =
    H.span
        [ HA.class "font-bold" ]
        [ H.text text ]


liBullet : Html msg
liBullet =
    H.span
        [ HA.class "text-green-300 pl-[1ch]" ]
        [ H.text "- " ]


checkboxLabel : Bool -> String
checkboxLabel isOn =
    if isOn then
        "[X]"

    else
        -- Space the width of one 'X' (in the font PixelOperator)
        "[\u{2007}]"


checkboxButton :
    { label : String
    , isOn : Bool
    , toggle : Bool -> msg
    }
    -> Html msg
checkboxButton { label, isOn, toggle } =
    H.button
        [ HE.onClick (toggle (not isOn))
        , HA.class "cursor-pointer text-green-200 select-none"
        , TW.mod "hover" "text-green-100 bg-green-800"
        , TW.mod "active" "text-orange"
        ]
        [ H.text <| checkboxLabel isOn ++ " " ++ label ]
