module Evergreen.V83.Data.Item exposing (..)


type alias Id =
    Int


type Kind
    = HealingPowder
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
