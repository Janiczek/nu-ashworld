module Evergreen.V132.Data.Item exposing (..)

import Evergreen.V132.Data.Item.Kind


type alias Id =
    Int


type alias Item =
    { id : Id
    , kind : Evergreen.V132.Data.Item.Kind.Kind
    , count : Int
    }


type alias UniqueKey =
    { kind : Evergreen.V132.Data.Item.Kind.Kind
    }
