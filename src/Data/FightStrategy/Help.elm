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
  - attack ([SHOT TYPE])              - my AP                      
  - heal ([ITEM])                     - number of available [ITEM] 
  - move forward                      - number of used [ITEM]      
  - do whatever                       - opponent's level           
                                      - chance to hit ([SHOT TYPE])
                                      - distance                   
[CONDITION]                         
  - opponent is player              
  - opponent is NPC                 [SHOT TYPE]   
  - [VALUE] [OPERATOR] [NUMBER]       - unaimed   
  - ([CONDITION] or [CONDITION])      - head      
  - ([CONDITION] and [CONDITION])     - eyes      
                                      - torso     
                                      - groin     
[OPERATOR]                            - left arm  
  - <   (less than)                   - right arm 
  - <=  (less than or equal)          - left leg  
  - ==  (equals)                      - right leg 
  - !=  (doesn't equal)
  - >=  (greater than or equal)
  - >   (greater than)
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
    | ShotType
    | Item
    | Value
    | Operator
    | Number


allReferences : List Reference
allReferences =
    [ Strategy
    , Command
    , Condition
    , ShotType
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

        ShotType ->
            "[SHOT TYPE]"

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
- if distance > 0
    then move forward
    else do whatever"""

        Command ->
            """The end result of applying your strategy to your current situation.

Examples:
- heal (Stimpak)
- attack (head)
- attack randomly
- move forward"""

        Condition ->
            """Examples:
- distance > 0
- my AP == 2
- my HP < 300
- chance to hit (eyes) >= 80
- opponent is player"""

        ShotType ->
            """Different aimed shots have a different chance-to-hit penalty, with an accompanying damage multiplier. More risk, more reward!

Example usage:

- inside [VALUE]:
    chance to hit (torso)

- inside [COMMAND]:
    attack (torso)
"""

        Item ->
            """Examples:
- Stimpak
- Fruit
- Metal Armor"""

        Value ->
            """Examples:
- my HP
- chance to hit (left leg)
- number of available Stimpak"""

        Operator ->
            """Example usage:
- distance > 0
- my HP <= 80
- my AP == 3
"""

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

        ShotType ->
            "Shot Type"

        Item ->
            "Item"

        Value ->
            "Value"

        Operator ->
            "Operator"

        Number ->
            "Number"
