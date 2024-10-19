module Evergreen.V104.Data.Item exposing (..)


type Kind
    = Fruit
    | HealingPowder
    | Stimpak
    | BigBookOfScience
    | DeansElectronics
    | FirstAidBook
    | GunsAndBullets
    | ScoutHandbook
    | Robes
    | LeatherJacket
    | LeatherArmor
    | MetalArmor


type alias Id =
    Int


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }
