module Evergreen.V63.Data.Item exposing (..)


type alias Id =
    Int


type Kind
    = Stimpak


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }
