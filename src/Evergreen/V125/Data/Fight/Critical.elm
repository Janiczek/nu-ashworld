module Evergreen.V125.Data.Fight.Critical exposing (..)


type Effect
    = Knockout
    | Knockdown
    | CrippledLeftLeg
    | CrippledRightLeg
    | CrippledLeftArm
    | CrippledRightArm
    | Blinded
    | Death
    | BypassArmor
    | LoseNextTurn


type Message
    = PlayerMessage
        { you : String
        , them : String
        }
    | OtherMessage String
