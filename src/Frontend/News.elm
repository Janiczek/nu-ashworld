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
    [ { date = 1729411797
      , title = "TODOs before release"
      , text =
            """
Current:

- use critical effects

Next up:

- critical misses
- quests UX + test them end-to-end

Ideas floating around:

- More enemies?
- Weapon/ammo part of item loot of enemies?
- Fight Strategy: walk away
- make movement on the map challenging (random encounters, fights you can't skip, have to be alive to move...)
- critical effect - lose consciousness -> regain consciousness in fight (cost 1/2 of max AP)
- steal skill gives you % chance of looting a random item from a player's inventory in PVP after defeating them

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
                            H.li [] (UI.liBullet :: children)
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
