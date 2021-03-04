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
    [ { date = 1614637525
      , title = "Plans before alpha"
      , text = """
I've just added a tick system (one tick at the start of every hour) which should heal you and give you Action Points. Let's hope it's not too broken :)

I want to talk about my plans a bit. Some of my immediate plans are:

* [NEW CHAR] finish the screen
* [FIGHT] dice-rolling instead of 50/50 win chance
* [ECONOMY] source of caps and items: random encounters / quests (simplified)

More broadly, I'd like the game to have these mechanics:

* when you lose, the other player gets all the caps you currently have with you
* thus, there is the need for having a stash / vault (hehe) to hide your caps
* I'm thinking that there might be some NPC in every town that will hold on to stuff for you, for a fee (per day?)
* these wouldn't be connected: if you keep 500 caps in Den and go to Redding, you won't be able to pick up the 500 caps there
* thus, there will (probably) be a period of danger where you need to move caps from one town to another
* perhaps even hidden stashes (anywhere on the map, or in locations given by random encounters?)
* these would have a chance to be found out by other players / NPC raiders / whoever

But I need to somehow trim that down to a small prototype to test the idea out.

~janiczek
"""
      }
    , { date = 1614543901
      , title = "Discord"
      , text = """
Development is chugging along; I've also created a [Discord](https://discord.gg/HUmwvnv4xV) server for NuAshworld. Looking forward to seeing you there!

~janiczek
"""
      }
    , { date = 1614377234
      , title = "New beginnings!"
      , text =
            """
Hello everybody! I just want to announce that I'm starting to work on this game again.

You can watch the development plans on NuAshworld's [Trello](https://trello.com/b/WevjfFrt/nuashworld) and the game development itself on [GitHub](https://github.com/Janiczek/nu-ashworld-lamdera).

I want to stay close to finding the fun in the game -- closing in on the mechanics, not getting stuck on unimportant things. We'll see how that goes :)

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
