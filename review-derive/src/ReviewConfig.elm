module ReviewConfig exposing (config)

import Derive
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    [ Derive.rule True []
    ]
        |> List.map (Rule.ignoreErrorsForDirectories [ "src/Evergreen" ])
