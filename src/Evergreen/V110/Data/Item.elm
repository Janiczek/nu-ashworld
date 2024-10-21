module Evergreen.V110.Data.Item exposing (..)

import Evergreen.V110.Data.Item.Kind


type alias Id =
    Int


type alias Item =
    { id : Id
    , kind : Evergreen.V110.Data.Item.Kind.Kind
    , count : Int
    }


type alias UniqueKey =
    { kind : Evergreen.V110.Data.Item.Kind.Kind
    }
