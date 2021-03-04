module NoSlowConcat exposing (rule)

{-| Make sure we use Gwi.List.fastConcat and Gwi.List.fastConcatMap instead of
List.concat and List.concatMap.

To be used with <https://package.elm-lang.org/packages/jfmengels/elm-review/latest/>

TODO theoretically we could have an automatic fix:

  - replace (Node.range fn) with "List.fastConcat"
  - somehow make sure Gwi.List is imported as List


# Rule

@docs rule

-}

import Elm.Syntax.Expression exposing (Expression(..))
import Elm.Syntax.Node as Node exposing (Node)
import Review.Rule as Rule exposing (Error, Rule)


{-| Make sure we use Gwi.List.fastConcat and Gwi.List.fastConcatMap instead of
List.concat and List.concatMap.
If you want to use this rule, add it to `config : List Rule` in `review/ReviewConfig.elm`
-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "FastConcatFunctionsUsed" ()
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


expressionVisitor : Node Expression -> List (Error {})
expressionVisitor node =
    case Node.value node of
        Application (fn :: _) ->
            case Node.value fn of
                FunctionOrValue [ "List" ] "concat" ->
                    [ Rule.error
                        { message = "Slow List.concat function used"
                        , details =
                            [ "Please use Gwi.List.fastConcat instead!"
                            , "Preferably `import Gwi.List as List` and then `List.fastConcat`"
                            ]
                        }
                        (Node.range node)
                    ]

                FunctionOrValue [ "List" ] "concatMap" ->
                    [ Rule.error
                        { message = "Slow List.concatMap function used"
                        , details =
                            [ "Please use Gwi.List.fastConcatMap instead!"
                            , "Preferably `import Gwi.List as List` and then `List.fastConcatMap`"
                            ]
                        }
                        (Node.range node)
                    ]

                _ ->
                    []

        _ ->
            []
