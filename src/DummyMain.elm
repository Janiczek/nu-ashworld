module DummyMain exposing (main)

import Backend
import Frontend
import Html


main =
    Html.div
        (Html.text (String.fromInt Backend.maxAc)
            :: Frontend.aboutView
        )
