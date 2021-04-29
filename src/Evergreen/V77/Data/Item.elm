module Evergreen.V77.Data.Item exposing (..)


type alias Id =
    Int


type Kind
    = Stimpak
    | BigBookOfScience
    | DeansElectronics
    | FirstAidBook
    | GunsAndBullets
    | ScoutHandbook


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }
