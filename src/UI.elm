module UI exposing
    ( bold
    , button
    , checkbox
    , checkboxLabel
    , highContrastButton
    , input
    , textarea
    , ul
    , withMaybeTooltip
    , withTooltip
    )

import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Tailwind as TW


button : List (Attribute msg) -> List (Html msg) -> Html msg
button attrs content =
    H.button
        (HA.class "whitespace-pre cursor-pointer text-green-200 select-none"
            :: TW.mod "disabled" "text-green-300 cursor-not-allowed"
            :: TW.mod "hover" "text-green-100"
            :: TW.mod "[&:not([disabled]):hover]" "bg-green-800"
            :: TW.mod "active" "text-yellow"
            :: attrs
        )
        content


highContrastButton : List (Attribute msg) -> List (Html msg) -> Html msg
highContrastButton attrs content =
    H.button
        (HA.class "whitespace-pre cursor-pointer text-green-200 select-none"
            :: TW.mod "disabled" "text-green-300 cursor-not-allowed"
            :: TW.mod "hover" "text-green-100"
            :: TW.mod "[&:not([disabled]):hover]" "bg-green-300"
            :: TW.mod "active" "text-yellow"
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


checkboxLabel : Bool -> String
checkboxLabel isOn =
    if isOn then
        "[X]"

    else
        -- Space the width of one 'X' (in the font PixelOperator)
        "[\u{2007}]"


checkbox :
    { label : String
    , isOn : Bool
    , toggle : Bool -> msg
    }
    -> Html msg
checkbox { label, isOn, toggle } =
    H.button
        [ HE.onClick (toggle (not isOn))
        , HA.class "cursor-pointer text-green-200 select-none"
        , TW.mod "hover" "text-green-100 bg-green-800"
        , TW.mod "active" "text-yellow"
        ]
        [ H.div [ HA.class "flex flex-row gap-[1ch] text-left" ]
            [ H.span [] [ H.text <| checkboxLabel isOn ]
            , H.text label
            ]
        ]


ul : List (Attribute msg) -> List (Html msg) -> Html msg
ul attrs content =
    H.ul (HA.class "list-outside ps-[4ch]" :: attrs) content


withTooltip : String -> Html msg -> Html msg
withTooltip tooltipText element =
    H.div [ HA.class "relative" ]
        [ H.div [ HA.class "peer/tooltip contents" ] [ element ]
        , H.div
            [ HA.class "bg-green-200 text-green-900 px-[2ch] py-4 mt-4 absolute z-[3] left-1/2 -translate-x-1/2 hidden w-max max-w-[26ch] pointer-events-none"
            , TW.mod "peer-hover/tooltip" "block"
            ]
            [ H.text tooltipText ]
        ]


withMaybeTooltip : Maybe String -> Html msg -> Html msg
withMaybeTooltip maybeTooltipText element =
    case maybeTooltipText of
        Nothing ->
            element

        Just tooltipText ->
            withTooltip tooltipText element
