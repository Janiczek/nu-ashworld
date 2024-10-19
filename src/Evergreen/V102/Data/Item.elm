module Evergreen.V102.Data.Item exposing (..)


type alias Id =
    Int


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


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }
