module Evergreen.V137.Data.Item exposing (..)

import Evergreen.V137.Data.Item.Kind


type alias Id =
    Int


type alias Item =
    { id : Id
    , kind : Evergreen.V137.Data.Item.Kind.Kind
    , count : Int
    }


type alias UniqueKey =
    { kind : Evergreen.V137.Data.Item.Kind.Kind
    }
