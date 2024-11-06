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
import UI


type alias Item =
    { date : Int -- UNIX: date +%s
    , title : String
    , text : String
    }


items : List Item
items =
    [ { date = 1730886199
      , title = "TODOs before release"
      , text =
            """
Hey all! The game is still in a pre-release state, so don't get attached to any
characters you create, as the game will sometimes need to get reset as I work on
stuff. It's really close to release though, so keep an eye out for the
announcement!

Current TODOs:

- quest completion flair text

Next up: 

- quests UX + test them end-to-end
- end of game

Later: 

- item descriptions 
- weapons - show strength requirement somewhere (item description)
- don't forget to say something about K9 and Skynet Aim
- tooltips around edge of screen - floating-ui.js?
- music in the bg (opt-in)

- Steam webview wrapper
- guest mode - no login required, Ladder fights, quests and marketplace disabled, but you can wander (PvM fights) and use shops

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
        | paragraph =
            \children ->
                H.span [] children
        , link =
            \{ title, destination } children ->
                H.a
                    [ HA.class "text-yellow relative no-underline"
                    , TW.mod "after" "absolute content-[''] bg-yellow-transparent inset-x-[-3px] bottom-[-2px] h-1 transition-all duration-[250ms]"
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
                            H.li [] children
                        )
                    |> UI.ul [ HA.class "flex flex-col" ]
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
