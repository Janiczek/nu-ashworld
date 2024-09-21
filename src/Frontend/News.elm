module Frontend.News exposing (Item, formatDate, formatText, items)

import DateFormat
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HAE
import Markdown.Block
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import Tailwind as TW
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

Check out this [link](https://google.com)!

Some list:

- one
- second
- 3!

~janiczek
"""
      }
    ]


formatText : String -> String -> Html a
formatText class markdown =
    markdown
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "")
        |> Result.andThen (Markdown.Renderer.render renderer)
        |> Result.withDefault [ H.text "Failed to parse Markdown" ]
        |> H.div [ HA.class ("flex flex-col gap-4 mt-4 " ++ class) ]


renderer : Markdown.Renderer.Renderer (Html a)
renderer =
    { defaultHtmlRenderer
        | link =
            \{ title, destination } children ->
                H.a
                    [ HA.class "text-orange relative no-underline"
                    , TW.mod "after" "absolute content-[''] bg-orange-transparent inset-x-[-3px] bottom-[-2px] h-1 transition-all duration-[250ms]"
                    , TW.mod "hover:after" "bottom-0 h-full"
                    , HA.href destination
                    , HAE.attributeMaybe HA.title title
                    ]
                    children
        , unorderedList =
            \list ->
                list
                    |> List.map
                        (\(Markdown.Block.ListItem _ children) ->
                            H.li []
                                (H.span [ HA.class "text-green-300 pl-[1ch]" ] [ H.text "- " ]
                                    :: children
                                )
                        )
                    |> H.ul [ HA.class "flex flex-col" ]
    }


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
