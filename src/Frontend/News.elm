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
    [ { date = 1620348829
      , title = "Critical hits"
      , text = """
The game now properly tracks **critical hits**. You'll find that both you and
your enemies have a chance of hitting each other extra hard (**damage
multiplier** 1.5x to 4x depending on chance and whether you have some of the
critical-enhancing perks).

As always, it has generated a bunch of TODOs for me to go through - mainly
status effects like crippled legs, knockback / knockout, blindness etc. - well,
one day maybe they'll come! :)

I've been given feedback by ~djetelina that it would be nice to have
changelogs. So, here goes!

Changelog:
* fights now correctly name body parts. So, no more ants with arms.
* **critical hits**: ocassionally damage is multiplied. You'll see which hit was
critical in the fight log.
* fixed damage formula: damage resistance is not affected by armor-ignoring
attacks (those don't exist yet anyways!)
* new perk: **Better Criticals**. Upgrades your critical hits' effects -- but not
chance for a critical happening. Reqs: lvl 9, luck 6, perception 6, agility 4
* new perk: **More Criticals**. Max 3 ranks, each rank gives you 5% extra chance to
score a critical hit. Reqs: lvl 6, luck 6
* new perk: **Slayer**. All non-miss unarmed/melee hits are upgraded to criticals.
Reqs: lvl 24, agility 8, strength 8, unarmed 80%
* trait **Heavy Handed** now has its critical hit effect debuff implemented. Note
this debuff is larger (-30) than the buff given by Better Criticals (+20).
* new trait: **Finesse**. Critical chance increased by 10%, but all damage is
reduced by 30%.
* map tooltip now correctly pluralizes ticks, so no more "1 ticks".
* fixed bug where damage in a fight could sometimes be negative (healing you)

~janiczek
"""
      }
    , { date = 1620065638
      , title = "Armor!"
      , text = """
I have added a few kinds of **armor** to the game and a few new merchants that
can sell it. You can equip it in the Inventory screen - it should make you a
bit more durable in the battle.

As a reminder, vendors change their stock every tick (so, every hour). May the
odds be ever in your favour :)

Oh and we now have **Healing Powder** (Hakunin in **Arroyo** sells a bunch of
it) in an attempt to balance the healing in this damn game a bit.

~janiczek
"""
      }
    , { date = 1619718120
      , title = "Books, more perks, and a new merchant"
      , text = """
I've been **adding more perks,** prioritizing those unlocked at level 3 (I have
enough time to do those at lvl 6/9/12/... - you guys don't level up that fast
;) ). One of them is related to
[books!](https://fallout.fandom.com/wiki/Fallout_2_skill_books) Which means, I
went and also implemented books. If you go look in the **Klamath** or **Den**
stores (yeah, there's now a vendor in Den!), you might get lucky and find one
of them.

The books will give you up to 10% to their respective skills, capping somewhere
around 91%. After that, the book for that particular skill is useless to you.

Note that using a book requires some ticks, related to your Intelligence
attribute.

Oh and I've also slowed the game again. We now know 60x is too fast! (Duh.)

~janiczek
"""
      }
    , { date = 1619693804
      , title = "Perks and a fast testing round"
      , text = """
Perks can now be added from within the **Character** screen (if you have perks
available - usually every 3 levels). Take them for a spin!

I'm also making the game run a bit faster for a limited time, to let folks test
it and give me some feedback before I make a bigger marketing push :)

So, enjoy a game tick every minute!

~janiczek
"""
      }
    , { date = 1619480881
      , title = "PvM fights"
      , text = """
You can now fight some NPC enemies and get those sweet caps flowing into the
economy!

When you move out of any town, you'll see that the **[Town]** link in
your menu changes to a **[Wander]** one. Clicking it will find you a NPC to fight
for the price of **one tick,** similarly to the PvP fights.

Go forth and save up for those stimpaks! And don't forget, if you fight another
player, you get all their caps (or they yours). Should get much more exciting now!

~janiczek
"""
      }
    , { date = 1618787348
      , title = "Skills and traits"
      , text = """
I've just revamped the **character creation screen** and added some initial
**traits** and support for **tagged skills** there. On each level-up you'll get
**skill points** to upgrade your skills with. This should all result in more
interesting characters and meta.

Since I'm resetting the ladder instead of
attempting a complicated migration, you can try the new features out with new
characters! :)

I also have a basic **perk** support implemented under the hood, but the "pick
a perk" screen is still TODO. 

Next up, the PvM encounters that should pump some caps into the economy,
finally!

~janiczek
"""
      }
    , { date = 1618521323
      , title = "Beginnings of economy"
      , text = """
A big change just landed in NuAshworld:

* you now have an **inventory** (visible on the Character page), and
* there is now a **store** in Klamath where you'll be able to barter with the
one and only [Maida Buckner](https://fallout.fandom.com/wiki/Maida_Buckner).

The stores will, in general, restock periodically each tick.

Note that this feature makes use of the **Charisma attribute**, since Charisma
affects your Barter skill, and that affects the prices you'll be getting when
trading with NPCs.

There is currently only one item available in the game:
the healing item
[Stimpak](https://fallout.fandom.com/wiki/Stimpak_%28Fallout%29).

A caveat: it doesn't currently do anything yet (this is a huge update as it
is!), but later you'll be able to:

* use it to **heal yourself manually** (thus saving ticks), and
* **set automatic rules for your fights** ("heal whenever my HP drops below
30%" and so on).

For trade to be truly useful, I'll have to add **NPC fights** as the next
thing, so that you can farm some caps.

Stay tuned, good stuff coming soon!

~janiczek
"""
      }
    , { date = 1617309687
      , title = "Fight system"
      , text = """
Fights should, now that I've
[implemented](https://twitter.com/janiczek/status/1377043815043846149) the
unarmed version of Fallout 2 combat algorithm and raised the XP rewards, be
interesting and rewarding enough that getting to a level 2 shouldn't be too
much of a problem :) At least, that would be the case if you had an option to
heal instantly. It's planned, read more below!

What's planned for the immediate future:

* Fast healing (Pip-boy rest-until-healed that would cost you ticks)
* Skill system (train your Unarmed skill for better damage etc.)
* PvM random encounters to train on
* Inventory system, items, drops
* Non-unarmed combat (melee, guns, ammo)

And more long-term plans:

* Perks / traits
* Quests
* Town NPCs (barter vendors, quest givers)

P.S.: I've created a Twitter account
[@NuAshworld](https://twitter.com/NuAshworld) where I share screenshots from
development. Follow me!

~janiczek
"""
      }
    , { date = 1614637525
      , title = "Plans before alpha"
      , text = """
I've just added a tick system (one tick at the start of every hour) which
should heal you and give you ticks to use for movement, fights, etc. Let's hope
it's not too broken :)

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
