module Data.Fight.DamageType exposing (DamageType(..), all, label)


type DamageType
    = NormalDamage
    | Fire
    | Explosion
    | Laser
    | Plasma
    | Electrical
    | EMP


all : List DamageType
all =
    [ NormalDamage
    , Fire
    , Explosion
    , Laser
    , Plasma
    , Electrical
    , EMP
    ]


label : DamageType -> String
label damageType =
    case damageType of
        NormalDamage ->
            "Normal"

        Fire ->
            "Fire"

        Explosion ->
            "Explosion"

        Laser ->
            "Laser"

        Plasma ->
            "Plasma"

        Electrical ->
            "Electrical"

        EMP ->
            "EMP"
