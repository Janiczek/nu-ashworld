module Data.FightStrategy.Help exposing
    ( Markup(..)
    , Reference(..)
    , help
    , referenceDescription
    , referenceText
    , referenceTitle
    )

import Parser as P exposing (Parser)


help : List Markup
help =
    """
[STRATEGY]
  - [COMMAND]
  - if [CONDITION] then [STRATEGY] else [STRATEGY]


[COMMAND]                           [VALUE]
  - attack randomly                   - my HP
  - attack ([ATTACK])                 - my max HP
  - heal ([ITEM])                     - my AP
  - heal with anything                - my level
  - move forward                      - their level
  - run away                          - number of available [ITEM]
  - do whatever                       - number of available healing items
  - skip turn                         - number of available ammo
                                      - number of used [ITEM]
                                      - number of used healing items
[CONDITION]                           - number of used ammo
  - opponent is player                - chance to hit ([ATTACK])
  - opponent is NPC                   - range needed ([ATTACK])
  - [VALUE] [OPERATOR] [VALUE]        - distance
  - ([CONDITION] or [CONDITION])      - [NUMBER]
  - ([CONDITION] and [CONDITION])


[OPERATOR]                          [ATTACK]             [AIM]
  - <   (less than)                   - unarmed            - head
  - <=  (less than or equal)          - unarmed, [AIM]     - eyes
  - ==  (equals)                      - melee              - torso
  - !=  (doesn't equal)               - melee, [AIM]       - groin
  - >=  (greater than or equal)       - throw              - left arm
  - >   (greater than)                - shoot              - right arm
                                      - shoot, [AIM]       - left leg
                                      - burst              - right leg
"""
        |> P.run parser
        |> Result.withDefault [ Text "BUG: couldn't parse the syntax help!" ]


type Markup
    = Text String
    | Reference Reference


type Reference
    = Strategy
    | Command
    | Condition
    | Attack
    | Aim
    | Item
    | Value
    | Operator
    | Number


allReferences : List Reference
allReferences =
    [ Strategy
    , Command
    , Condition
    , Attack
    , Aim
    , Item
    , Value
    , Operator
    , Number
    ]


referenceText : Reference -> String
referenceText ref =
    case ref of
        Strategy ->
            "[STRATEGY]"

        Command ->
            "[COMMAND]"

        Condition ->
            "[CONDITION]"

        Attack ->
            "[ATTACK]"

        Aim ->
            "[AIM]"

        Item ->
            "[ITEM]"

        Value ->
            "[VALUE]"

        Operator ->
            "[OPERATOR]"

        Number ->
            "[NUMBER]"


parser : Parser (List Markup)
parser =
    P.loop []
        (\revMarkups ->
            P.oneOf
                [ markup
                    |> P.map (\markup_ -> P.Loop (markup_ :: revMarkups))
                , P.succeed ()
                    |> P.map (\_ -> P.Done (List.reverse revMarkups))
                ]
        )


markup : Parser Markup
markup =
    P.oneOf
        [ P.map Reference reference
        , P.map Text text
        ]


text : Parser String
text =
    P.chompUntilEndOr "["
        |> P.getChompedString
        |> P.andThen
            (\string ->
                if String.isEmpty string then
                    P.problem "empty string"

                else
                    P.succeed string
            )


reference : Parser Reference
reference =
    allReferences
        |> List.map (\ref -> P.map (\_ -> ref) (P.keyword (referenceText ref)))
        |> P.oneOf


referenceDescription : Reference -> String
referenceDescription ref =
    case ref of
        Strategy ->
            """The entrypoint to your fight strategy.

Examples:
- do whatever
- if distance > 1
    then move forward
    else do whatever"""

        Command ->
            """The end result of applying your strategy to your current situation.

The 'do whatever' command is a shortcut for 'if distance > 1 then move forward else attack randomly'.

Examples:
- heal (Stimpak)
- heal with anything
- attack (head)
- attack randomly
- move forward
- run away
"""

        Condition ->
            """Examples:
- distance > 1
- my AP == 2
- my HP < 300
- chance to hit (eyes) >= 80
- opponent is player"""

        Attack ->
            """Various types of attacks are available, depending on your equipped weapon.

Examples:
- unarmed
- unarmed, head
- melee
- melee, eyes
- throw
- throw, left leg
- shoot
- shoot, groin
- burst
"""

        Aim ->
            """Different aimed shots have a different chance-to-hit penalty, with an accompanying damage multiplier. More risk, more reward!

Example usage:

- inside [VALUE]:
    chance to hit (shoot, torso)

- inside [ATTACK]:
    attack (throw, head)"""

        Item ->
            """Examples:
- Stimpak
- Fruit
- Metal Armor"""

        Value ->
            """Examples:
- my HP
- chance to hit (left leg)
- number of available healing items
- number of available Stimpak
- number of used ammo
- my level
- their level

Note that **their level** will only work on players, for NPCs it will always return 1.
"""

        Operator ->
            """Example usage:
- distance > 1
- my HP <= 80
- my AP == 3"""

        Number ->
            """Can be positive or negative integers (no decimal point).

Examples:
- 42
- -10"""


referenceTitle : Reference -> String
referenceTitle ref =
    case ref of
        Strategy ->
            "Strategy"

        Command ->
            "Command"

        Condition ->
            "Condition"

        Attack ->
            "Attack"

        Aim ->
            "Aim"

        Item ->
            "Item"

        Value ->
            "Value"

        Operator ->
            "Operator"

        Number ->
            "Number"
