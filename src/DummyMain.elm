module DummyMain exposing (main)

import Backend
import Frontend
import Html


main =
    Html.div []
        (Html.text (Debug.toString Backend.app)
            :: Frontend.aboutView
        )
