module IntersectionObserver exposing (Intersection, view)

import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD exposing (Decoder)
import Json.Encode


view : String -> (Intersection -> Decoder msg) -> List (Attribute msg) -> List (Html msg) -> Html msg
view observedSelector toMsg attrs content =
    H.node "x-intersection-observer"
        (HA.attribute "target-selector" observedSelector
            :: HE.on "targetintersection"
                (intersectionDecoder
                    |> JD.andThen
                        (\intersection ->
                            JD.at [ "detail", "element" ] (toMsg intersection)
                        )
                )
            :: attrs
        )
        content


type alias Intersection =
    { isIntersecting : Bool
    , element : Json.Encode.Value
    }


intersectionDecoder : Decoder Intersection
intersectionDecoder =
    JD.field "detail" <|
        JD.map2 Intersection
            (JD.field "isIntersecting" JD.bool)
            (JD.field "element" JD.value)
