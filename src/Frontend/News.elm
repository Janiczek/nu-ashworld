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
    [ { date = 0
      , title = "TODO"
      , text = """
Changelog: 

* Quests!!

* items are now **sorted by type** (food, books, armor, ...) on the inventory page

* new perk: **Gecko Skinning**: each gecko kill has a guaranteed drop of gecko skin. Given as a reward for a quest.

* new item: **Meat Jerky** (value $30, heals 40 HP)
* new item: **Beer** (value $200, can't currently be used)
* new item: **BB Gun** (value $3500, small gun, uses BB ammo, can't currently be used)
* new item: **BB Ammo** (value $20, ammo, can't currently be used)

* new enemy: **Silver Gecko**
* new enemy: **Tough Silver Gecko**
* new enemy: **Golden Gecko**
* new enemy: **Tough Golden Gecko**
* new enemy: **Fire Gecko**
* new enemy: **Tough Fire Gecko**

TODO:

* TODO make some vendors sell meat jerky
* TODO new enemy: silver gecko
* TODO make geckos drop the skins if attacker has the perk
* TODO new item: silver gecko skin
* TODO new item: golden gecko skin
* TODO new item: fire gecko skin
* TODO on each tick, progress the quests
* TODO validate startProgressing
* TODO handle quest complete (global rewards)
* TODO handle quest complete (player rewards)
* TODO global rewards - track them in backend model?
* TODO global rewards - use them?
* TODO write more details to the news about the geckos

~janiczek
"""
      }
    , { date = 1638276029
      , title = "Worlds, fix for a vendor bug"
      , text = """
A big release in preparation for my talk about NuAshworld at NDC Oslo 2021 :)

You can now play on different worlds with different tick speed settings.

* For reference, the default speed on the "main" world is 2-4 ticks (depending
on whether you have above or below 50 ticks) per hour.
* The world for NDC Oslo will run at 1-2 ticks per second.
* Depending on how that one goes, I'll create a public "blitz round" world
after the conference.

A bug was fixed related to being in the middle of a trade while the vendor
restocks.

Pages in the game now each have their URL.

(Vendor restock frequency is separate from the tick frequency; 1x per hour on
the main world, 1x per minute for the NDC Oslo world.)

~janiczek
"""
      }
    , { date = 1626037313
      , title = "Fight strategy editor now more lenient toward whitespace"
      , text = """
While experimenting with the editor I found I'd like it to allow me to write eg.

```
if    ((opponent is player
    and my AP < 4)
    and my HP < 100)
then do whatever
else attack (eyes)
```

In other words, newlines all over the place. And that's now possible!

~janiczek
"""
      }
    , { date = 1626033582
      , title = "Fight strategy editor"
      , text = """
You can now write your own fight strategies in the **editor** on the Settings page.

You can learn what's possible from the **examples** above the editor or via the **syntax cheatsheet** page. The info bar on the right of the editor should lead you through writing your strategies.

There is a [#fight-strategies](https://discord.gg/9NuCZs3YZa) channel on the Discord where you can ask for help or share your own creations.

~janiczek
"""
      }
    , { date = 1625920050
      , title = "Fixes for fight strategies"
      , text = """
Running two players with the YOLO strategy has uncovered a few bugs, so here
are the fixes for them:

* Items in inventory with 0x count can't be used anymore

* Items used during fight get removed correctly: they don't show up as 0x in
the inventory after the fight

* Exact HP after healing during fight is only shown to you if it was you
healing yourself, or if you have enough PerceptionLevel to see the opponent's
exact HP.

* It was possible to craft strategies such that the fight would never end.
We've now enforced a limit of 1000 actions - after that, both players give up
the fight and nobody wins.

* If falling back to a backup strategy in case action from your strategy cannot
be used, we now correctly let the rest of your turn play back instead of
cutting it after the fallback action.

* Action 'Heal' isn't needlessly taken if you have full HP.

~janiczek
"""
      }
    , { date = 1625880726
      , title = "Fight strategies!"
      , text = """
You can now choose between different **fight strategies** on the **Settings
page** and actually **heal** during fights!

I'll probably implement an editor to let you write your own strategies before I
dive back into quests.

~janiczek
"""
      }
    , { date = 1623181215
      , title = "Your attacks are logged now, fights have a stats section"
      , text = """
A little procrastination patch while I chip away at quests:

* **each fight has a stats section** with hit rate, damage dealt, critical hit
chance, average damage, max hit for both you and your opponent.

* **your PvP attacks are now logged** into your messages. You can look at your
fights later if you want.

This will probably later evolve into some filtering/tab system for the
messages, and/or a checkbox in settings to disable this recording behaviour,
but... we'll get there when we get there.

Re quests: I have them all listed, the XP rewards roughly distributed, now just
to fill the rest of the data (description, requirements, item rewards, global
and private permanent buff rewards, etc.) and plug it into the code. Please be
patient with me :)

~janiczek
"""
      }
    , { date = 1622292832
      , title = "XP and caps nerf in PvP fights"
      , text = """
We're experimenting with balancing the fights. The way things worked until now
is that

* XP gained from a won fight was **10xp x damage dealt** (HP taken)

* winner took **all the caps** the loser had on them

In this update, we're changing that to:

* XP gained is the above formula **scaled by (loser level / winner level)**.
Thus if a player with a level 20 kills a player with a level 6, they will only
get **6/20** as much of the XP. This works in the other way too! The weaker
player will get **20/6** as much XP if they manage to kill the stronger player.

* caps gained are **scaled between 50% and 100%** of the full amount based on
the percentage of max HP taken during that fight. Formula:
**loser caps x (50% + 0.5 x damage dealt / max HP)**.
Example: Loser (with 34/80 HP) has 1234 caps on them. Winner kills them and
gets 879 caps. But if the loser was at full HP (80/80), the winner would get
all of the 1234 caps.

Other changes:

* the Messages link in menu is now dimmed if you have no unread messages
* the Messages link in menu is now highlighted even if you're in a specific message

~janiczek
"""
      }
    , { date = 1621718718
      , title = "About page + Patreons + endgame!"
      , text = """
I've finally filled in the **About page**, because I needed somewhere to thank
my Patreons :)

Thanks again, **djetelina**!

To be a bit enigmatic: in my almost-a-week of not working on the game some
thoughts have crystallized on **how I want the endgame to look.** It also
nicely circumvents my fear of writing quests being too time consuming. The
solution is also a mechanic I haven't yet seen in any game I've played, so I'm
very interested in how well will it work.

Stay tuned!

~janiczek
"""
      }
    , { date = 1621370196
      , title = "Map chunks and enemies randomization"
      , text = """
I've separated the map into [five
regions](https://twitter.com/NuAshworld/status/1394754684129267718) of
increasing difficulty:

1. Arroyo, Klamath, Den
2. Modoc, Vault City, Gecko
3. New Reno, Broken Hills, Redding, Raiders
4. NCR, Vault 13, Vault 15, Military Base
5. San Francisco, Navarro, Enclave

Rest of the changelog:

* **The enemies are now generated based on which chunk you're in!** So hopefully no
angry brahmins killing newbies next to the first town :)

* **Added towns**: Raiders, Navarro, Vault 13, Vault 15 (no vendor in any of
them yet - you can see from them being transparent on the map)

We'll need to add more enemies so that there is more variety, but maybe I'll
prioritize melee weapons first. Who knows?

~ janiczek
"""
      }
    , { date = 1621248342
      , title = "Inventory total value"
      , text = """
A quick little change today - the inventory screen now shows the total value of your items.

~janiczek
"""
      }
    , { date = 1621111128
      , title = "One more thing..."
      , text = """
Out of sheer procrastination I've implemented the help descriptions for SPECIAL
attributes, skills and traits.

~janiczek
"""
      }
    , { date = 1621102934
      , title = "PvM drops and Brahmins"
      , text = """
Today's update will be short and sweet: **enemies can drop items** and
**Brahmins** were added as new enemies, along with two harder variants of Radscorpions.

Since right now all enemies spawn everywhere, those radscorpions will probably
give you a bit of trouble. **The next patch** should be about restricting them to
certain areas, so that players can naturally progress from low-level areas to
higher-level areas as they see fit.

Changelog:

* Discord invite link was updated to point to the #welcome channel
* Item added: **Fruit** (heals 15 HP, base value $10)
* New enemies: **Brahmins**. Variants are: Brahmin, Angry Brahmin, Weak Brahmin, Wild Brahmin.
* New enemies: two **black** variants of **Radscorpions**.
* Enemies can now drop items: expect fruit, healing powder and an ocassional stimpak for now.

~janiczek
"""
      }
    , { date = 1620669882
      , title = "More perks and UI improvements"
      , text = """
I have went through most of the perks in the original game and "ported" the
applicable ones to NuAshworld. Most other perks that are still missing are
waiting for non-unarmed combat, actual weapons etc. to be implemented.

There is one big bug fixed: the armor class in fights was computed from the
attacker, not from the defending party! This is now fixed, so your hard-earned
metal armor will now finally be useful to you ;)

And the unused Action Points from your turns in fights get converted to bonus
Armor Class for the next turn - again bringing us closer to what's in Fallout.
See also the **HtH Evade** perk that upgrades this behaviour and makes your
Unarmed skill much more useful.

Changelog:

* fixed bug: **Max HP** in Character Screen now shows the proper value instead of one calculated for level 1.
* UI improvement: **Tick heal** in Character Screen now shows the specific HP value healed in addition to the percentage of max HP.
* UI improvement: **Perk selection screen** now shows perk descriptions on hover.
* UI improvement: **Character screen** now shows perk descriptions on hover.

* new perk: **Action Boy**: gives you +1 Action Point per rank (for use in fights etc). Max rank: 2. Reqs: lvl 12, Agility >= 5
* new perk: **Adrenaline Rush**: gives you +1 Strength whenever your HP drops below 50%. Max rank: 1. Reqs: lvl 6, Strength < 10
* new perk: **Bonus HtH Attacks**: all your unarmed attacks consume 1 less AP (so, 2 instead of 3 for normal attacks and 3 instead of 4 for aimed attacks). Max rank: 1. Reqs: lvl 15, Agility >= 6
* new perk: **Dodger**: gives you +5 to Armor Class. Max rank: 1. Reqs: lvl 9, Agility >= 6
* new perk: **Fortune Finder**: all caps NPC drops are doubled. Max rank: 1. Reqs: lvl 6, Luck >= 8
* new perk: **Gambler**: gives you +20% to Gambling. Max rank: 1. Reqs: lvl 6, Gambling >= 50%
* new perk: **HtH Evade**: each Action Point unused in your fight turn gets converted to 2 Armor Class instead of 1. You also gain 1/12 of your Unarmed skill as additional Armor Class. Max rank: 1. Reqs: lvl 12, Unarmed >= 75%
* new perk: **Lifegiver**: gives you +4 HP per level per rank. Max rank: 2. Reqs: lvl 12, Endurance >= 4
* new perk: **Living Anatomy**: gives you +10% to Doctor and +5 damage to any attack that lands. Max rank: 1. Reqs: lvl 12, Doctor >= 60%
* new perk: **Master Thief**: gives you +15% to Lockpick and Steal. Max rank: 1. Reqs: lvl 12, Lockpick >= 50%, Steal >= 50%
* new perk: **Medic**: gives you +10% to First Aid and Doctor. Max rank: 1. Reqs: lvl 12, First Aid >= 40% or Doctor >= 40%
* new perk: **Mr. Fixit**: gives you +10% to Repair and Science. Max rank: 1. Reqs: lvl 12, Science >= 40% or Repair >= 40%
* new perk: **Negotiator**: gives you +10% to Speech and Barter. Max rank: 1. Reqs: lvl 6, Barter >= 50%, Speech >= 50%
* new perk: **Pathfinder**: your tick cost for map movement is reduced by 25% per rank. Max rank: 2. Reqs: lvl 6, Endurance >= 6, Outdoorsman >= 40%
* new perk: **Ranger**: gives you +15% to Outdoorsman. Max rank: 1. Reqs: lvl 6, Perception >= 6
* new perk: **Salesman**: gives you +20% to Barter. Max rank: 1. Reqs: lvl 6, Barter >= 50%
* new perk: **Speaker**: gives you +20% to Speech. Max rank: 1. Reqs: lvl 9, Speech >= 50%
* new perk: **Speaker**: gives you +20% to Speech. Max rank: 1. Reqs: lvl 9, Speech >= 50%
* new perk: **Swift Learner**: gives you 5% more XP per rank. Max rank: 3. Reqs: lvl 3, Intelligence >= 4
* new perk: **Thief**: gives you +10% to Sneak, Lockpick, Steal and Traps. Max rank: 1. Reqs: lvl 3
* new perk: **Toughness**: gives you +10 to Damage Resistance per rank. Max rank: 3. Reqs: lvl 3, Endurance >= 6, Luck >= 6

~ janiczek
"""
      }
    , { date = 1620348829
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
