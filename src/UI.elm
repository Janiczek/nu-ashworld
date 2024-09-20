module UI exposing (button, input, textarea, tooltipAnchor)

import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Tailwind as TW


button : List (Attribute msg) -> List (Html msg) -> Html msg
button attrs content =
    H.button
        (HA.class "uppercase cursor-pointer text-green-200"
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


tooltipAnchor : Attribute msg
tooltipAnchor =
    HA.class "underline decoration-dashed decoration-green-300"
