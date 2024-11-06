module Frontend.Guide exposing (images, tableOfContents, view)

import Data.FightStrategy
import Data.FightStrategy.Named
import Frontend.Links as Links
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Attributes.Extra as HAE
import List.ExtraExtra as List
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import String.Extra
import Tailwind as TW
import UI


markdown : String
markdown =
    """
<div data-guide-section="Introduction">

### Introduction

**NuAshworld** is a post-apocalyptic **MMO browser game** set in the wasteland world of Fallout 2. As one of the few survivors, you'll need to navigate this harsh world, fight monsters and other players alike, complete quests and in doing so **change the wasteland for everybody**, and build your character's skills, abilities, equipment and climb the social ladder.

You're starting out in the relatively safe and remote village of **Arroyo**, but your search for power will lead you all across the wasteland. The **end goal** of each game world (think "season" in other games) is to somehow **get to the Enclave base** far out in the ocean and end their vertibird-ridden tyranny over the Southwest of what was once the United States of America.

This will take collective effort, and of course it's a dog-eat-dog world out there - other players will not make this any easier for you. How do you gather enough goodwill to form alliances and stand up to the evil?

![Map with all the locations](/images/map_locations.webp)

Here's a fairly complete list of things you can do in the game:

</div>

<div data-guide-section="Create your character">

### Create your character

Filling your details and clicking the `[SIGN\u{00A0}UP]` button will lead you to the New Character screen.

![New Character](/images/guide/new_char.webp)

</div>

<div data-guide-section="Fight">

### Fight

Once you've created your character, you'll see the **Ladder**. Here you can fight other players and can see their stats.

Depending on your **Perception Level** you'll be able to learn more about them before the fight (such as their exact current HP).

![Ladder](/images/guide/ladder.webp)

Clicking the **Fight** button will initiate the fight. Fights are fully automated; you can influence their outcome by equipping different weapons and armor and by writing your own **Fight Strategy** in the `[SETTINGS]` (more below).

Winning PVP fights gives you:

- **XP** based on the damage you dealt and the ratio of your vs their level (fighting a weaker player will give you less XP)
- **Caps** - between 50% and 100% of their currently held caps, based on the ratio of the damage you dealt and their max HP (fighting a fully healed player will give you all their caps)

![PVP fight (part 1)](/images/guide/pvp_fight_1.webp)
![PVP fight (part 2)](/images/guide/pvp_fight_2.webp)

You can also **wander** the wasteland and fight random creatures when not in town. (You'll see either `[TOWN]` or `[WANDER]` in the left menu. Go to `[MAP]` if you need to leave the town.)

**Winning fights** with players gives you **XP** and a portion of their **caps**; winning fights with random creatures gives you XP, caps and the ocassional **item drop**.

</div>

<div data-guide-section="Write a fight strategy">

### Write a fight strategy

A fight strategy decides what your character does in a fight. Open `[SETTINGS]` to write your own or pick a preset. It can look like:

```
{FIGHT_STRATEGY}
```

You can discuss and share strategies on the NuAshworld [Discord]({DISCORD}).

</div>

<div data-guide-section="Heal yourself">

### Heal yourself

Healing happens automatically over time as you gain ticks (in most worlds, this happens every hour on the hour).

You can also heal yourself:

- by consuming certain items like **Fruit** or **Stimpak** from the `[INVENTORY]`

- or by **using a tick** using the `[HEAL]` button in the left menu

- or automatically **during fight**, by specifying that in your fight strategy. 

![Heal in inventory](/images/guide/inventory.webp)

</div>

<div data-guide-section="Move on the map">

### Move on the map

The `[MAP]` page allows you to travel the wasteland.

Some places are more dangerous than others, though in the current state of the game, random encounters are not yet a thing so you'll only be affected if you `[WANDER]` while in these areas. Having a high **Perception** will help you learn how dangerous an area is.

Travelling also allows you to reach different towns and locations, each with unique quests and shops.

If you somehow get your hands on a **car**, you'll be able to move on the map much faster, at the expense of certain power sources like the **microfusion cells**.

![Map with all the locations](/images/map_locations.webp)

</div>

<div data-guide-section="Refuel your car">

### Refuel your car

Once you own a car, on the `[INVENTORY]` screen you'll be able to refuel it.

![Refuel your car](/images/guide/car_refuel.webp)

</div>

<div data-guide-section="Complete quests">

### Complete quests

When inside a `[TOWN]` you can participate in quests.

Quests in NuAshworld are **global**: instead of every player progressing quests independently, all players progress quests together by using their ticks/h.

You **receive XP** for each given tick, and if you reach a certain threshold, you'll be eligible to receive a **personal reward** once the quest is completed, even if you don't participate in it at the moment of completion.

Quests can have **global rewards** like a new vendor opening a shop at a location, a discount being given, a new quest being unlocked or new better items having chance of being sold at a shop.

Quests do have **requirements**: either skill-based, or you need to "pay" with an item or a specific amount of caps (bottle caps are the game's currency). You only need to meet these requirements once to be able to start and stop participating in the quest later.

Some quests are **exclusive with each other**: they're a different way of resolving a specific situation. Note this might prevent everybody from certain quest progressions and rewards! Choose wisely, and act fast.

![Town square](/images/guide/town_square.webp)

</div>

<div data-guide-section="Trade with NPC vendors">

### Trade with NPC vendors

In `[TOWN]` you can also **barter** with shopkeepers. They restock every tick (in most worlds this means every hour on the hour).

The value of items is determined by your and the vendor's **Barter skill**.

![Barter](/images/guide/barter.webp)

</div>

<div data-guide-section="Level up skills">

### Level up skills

Every time you level up, you gain **skill points** to spend on your skills. Do this on the `[CHARACTER]` page.

Skill percentages are useful in different ways: as quest requirements, for calculating a chance to hit with a weapon, etc.

Above certain percentages the upgrades will cost more skill points per %.

![Character skills](/images/guide/char_skills.webp)

</div>

<div data-guide-section="Choose perks">

### Choose perks

Every three levels (or four with the **Skilled** trait) you get to choose a **perk** on the `[CHARACTER]` page. Perks give you bonuses across all areas of the gameplay - choose wisely!

![Choose a perk](/images/guide/perk.webp)

</div>

<div data-guide-section="Equip armor and weapons">

### Equip armor and weapons

Once you've looted some armor or weapon from a won fight, bought it from a shop or got it as a quest reward, you can **equip it** in the `[INVENTORY]` screen.

![Inventory](/images/guide/inventory.webp)

Note that weapons have a varying **Strength requirement**. Failure to meet it will result in a **penalty** to your **chance to hit**.

</div>

<div data-guide-section="Preferring ammo">

### Preferring ammo

Different ammo behaves differently against armored and unarmored targets. You might want to **prefer certain ammo types** in your loadout.

If you do, that ammo type **will be used first** in fights. Once it's gone your character will automatically switch to another compatible ammo type for the weapon. If there's no ammo left they'll try to fight with their fists.

</div>

<div data-guide-section="Read books">

### Read books

You can read books from the `[INVENTORY]` by using them. This will cost you some ticks (as reading books takes time), and will make you better at a specific skill.

Eg. reading the **Guns and Bullets** book will make you better with Small Guns. Reading the **Scout Handbook** will improve your Outdoorsman skill.

The **max skill %** you can get to with books is **91%**.

</div>

<div data-guide-section="Read messages">

### Read messages

Ocassionally the game will send you a **message**: when somebody attacks you, when you level up, etc.

Read these on the `[MESSAGES]` page.

![Messages](/images/guide/messages.webp)

</div>

<div data-guide-section="Planned features">

## Planned features

- Quests:
  - Tug of war between exclusive quests
- Player marketplace
- Critical misses
- Better UX
  - A congratulation toast about a level-up
  - Realtime toasts about being attacked by somebody
- More NPC enemies
- More items (weapons, ammo, armor)
- Fight Strategy: walk away (gain some distance)
- Clans
  - Use GECK to create a clan base anywhere on the map
- Map movement
    - Random encounters
    - Only able to move on the map when alive
    - Outdoorsman: chance to skip random encounters
    - Special encounters
- Steal skill to give % chance of looting items from players
- (opt-in) Background music
- (opt-in) Sound effects

</div>
"""
        |> String.replace "{FIGHT_STRATEGY}"
            (Data.FightStrategy.Named.guideExample
                |> Data.FightStrategy.toString
            )
        |> String.replace "{DISCORD}" Links.discord


view : List (Html a)
view =
    markdown
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "")
        |> Result.andThen (Markdown.Renderer.render renderer)
        |> Result.withDefault [ H.text "Failed to parse Markdown" ]


images : List String
images =
    let
        imagesRenderer : Markdown.Renderer.Renderer (List String)
        imagesRenderer =
            { heading = \_ -> []
            , paragraph = \x -> List.fastConcat x
            , blockQuote = \_ -> []
            , html =
                Markdown.Html.oneOf
                    [ Markdown.Html.tag "div"
                        (\_ x -> List.fastConcat x)
                        |> Markdown.Html.withAttribute "data-guide-section"
                    ]
            , text = \_ -> []
            , codeSpan = \_ -> []
            , strong = \_ -> []
            , emphasis = \_ -> []
            , strikethrough = \_ -> []
            , hardLineBreak = []
            , link = \_ _ -> []
            , image = \{ src } -> [ src ]
            , unorderedList = \_ -> []
            , orderedList = \_ _ -> []
            , codeBlock = \_ -> []
            , thematicBreak = []
            , table = \_ -> []
            , tableHeader = \_ -> []
            , tableBody = \_ -> []
            , tableRow = \_ -> []
            , tableCell = \_ _ -> []
            , tableHeaderCell = \_ _ -> []
            }
    in
    markdown
        |> Markdown.Parser.parse
        |> Result.withDefault []
        |> Markdown.Renderer.render imagesRenderer
        |> Result.withDefault []
        |> List.fastConcat


tableOfContents : List String
tableOfContents =
    let
        tocRenderer : Markdown.Renderer.Renderer (List String)
        tocRenderer =
            { heading = \_ -> []
            , paragraph = \_ -> []
            , blockQuote = \_ -> []
            , html =
                Markdown.Html.oneOf
                    [ Markdown.Html.tag "div"
                        (\guideSection _ -> [ guideSection ])
                        |> Markdown.Html.withAttribute "data-guide-section"
                    ]
            , text = \_ -> []
            , codeSpan = \_ -> []
            , strong = \_ -> []
            , emphasis = \_ -> []
            , strikethrough = \_ -> []
            , hardLineBreak = []
            , link = \_ _ -> []
            , image = \_ -> []
            , unorderedList = \_ -> []
            , orderedList = \_ _ -> []
            , codeBlock = \_ -> []
            , thematicBreak = []
            , table = \_ -> []
            , tableHeader = \_ -> []
            , tableBody = \_ -> []
            , tableRow = \_ -> []
            , tableCell = \_ _ -> []
            , tableHeaderCell = \_ _ -> []
            }
    in
    markdown
        |> Markdown.Parser.parse
        |> Result.withDefault []
        |> Markdown.Renderer.render tocRenderer
        |> Result.withDefault []
        |> List.fastConcat


renderer : Markdown.Renderer.Renderer (Html a)
renderer =
    { defaultHtmlRenderer
        | paragraph =
            \children ->
                H.span [ HA.class "text-rg" ] children
        , heading =
            \{ level, children, rawText } ->
                let
                    ( element, class ) =
                        case level of
                            Markdown.Block.H2 ->
                                ( H.h2, Just "text-lg pt-8" )

                            Markdown.Block.H3 ->
                                ( H.h3, Just "text-md pt-8" )

                            _ ->
                                ( H.span, Nothing )
                in
                element
                    [ HA.class "font-bold"
                    , HAE.attributeMaybe HA.class class
                    , HA.id (String.Extra.dasherize rawText)
                    ]
                    children
        , image =
            \{ src, alt } ->
                H.a
                    [ HA.href src
                    , HA.target "_blank"
                    , HA.class "group relative"
                    ]
                    [ H.img
                        [ HA.src src
                        , HA.alt alt
                        , HA.class "border-4 border-green-800 transition-all duration-200 opacity-100 relative scale-100 absolute"
                        , TW.mod "group-hover" "opacity-75 border-green-300 scale-105 !z-[1]"
                        ]
                        []
                    ]
        , strong =
            \children ->
                H.span [ HA.class "text-rg text-yellow font-bold" ] children
        , link =
            \{ title, destination } children ->
                H.a
                    [ HA.class "text-yellow relative no-underline text-rg"
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
                            H.li [ HA.class "text-rg" ] children
                        )
                    |> UI.ul [ HA.class "flex flex-col" ]
        , codeSpan =
            \text ->
                H.span
                    [ HA.class "text-rg text-yellow font-bold" ]
                    [ H.text text ]
        , codeBlock =
            \{ body } ->
                H.pre
                    [ HA.class "ml-[4ch] text-green-200 bg-green-800 px-[2ch] py-4 w-fit" ]
                    [ H.text body ]
        , html =
            Markdown.Html.oneOf
                [ Markdown.Html.tag "div"
                    (\guideSection contents ->
                        H.div
                            [ HA.class "flex flex-col gap-4"
                            , HA.attribute "data-guide-section" guideSection
                            ]
                            contents
                    )
                    |> Markdown.Html.withAttribute "data-guide-section"
                ]
    }
