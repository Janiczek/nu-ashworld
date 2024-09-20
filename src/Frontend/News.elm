module Frontend.News exposing (Item, formatDate, formatText, items)

import DateFormat
import Html exposing (Html)
import Html.Attributes as HA
import Markdown
import Time


type alias Item =
    { date : Int -- UNIX: date +%s
    , title : String
    , text : String
    }


items : List Item
items =
    [ { date = 1614377234
      , title = "Hello!"
      , text =
            """
This is a test news post. I'll have to **flesh this out.**

~janiczek
"""
      }
    ]


formatText : String -> String -> Html a
formatText class markdown =
    Markdown.toHtml
        [ HA.class class ]
        markdown


formatDate : Time.Zone -> Int -> String
formatDate zone time =
    (time * 1000)
        |> Time.millisToPosix
        |> DateFormat.format dateFormat zone


dateFormat : List DateFormat.Token
dateFormat =
    [ DateFormat.yearNumber
    , DateFormat.text "-"
    , DateFormat.monthFixed
    , DateFormat.text "-"
    , DateFormat.dayOfMonthFixed
    , DateFormat.text ", "
    , DateFormat.hourMilitaryFixed
    , DateFormat.text ":"
    , DateFormat.minuteFixed
    ]
