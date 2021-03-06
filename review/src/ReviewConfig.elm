module ReviewConfig exposing (config)

import NoLeftPizza
import NoSlowConcat
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    [ NoUnused.CustomTypeConstructors.rule []
        |> Rule.ignoreErrorsForFiles
            [ "src/Data/Map/Location.elm"
            , "src/Data/Auth.elm"
            ]
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
        -- fastConcat
        |> Rule.ignoreErrorsForFiles [ "src/List/ExtraExtra.elm" ]
    , NoUnused.Modules.rule
        |> Rule.ignoreErrorsForFiles [ "src/Env.elm" ]
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    , NoSlowConcat.rule
    , NoLeftPizza.rule NoLeftPizza.Redundant
    ]
        |> List.map (Rule.ignoreErrorsForDirectories [ "src/Evergreen" ])
