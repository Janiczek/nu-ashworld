module Data.Item.Type exposing (Type(..), isAmmo, isWeapon, name)


type Type
    = Consumable
    | Armor
    | UnarmedWeapon
    | MeleeWeapon
    | ThrownWeapon
    | SmallGun
    | BigGun
    | EnergyWeapon
    | Book
    | Misc
    | Ammo


isWeapon : Type -> Bool
isWeapon type_ =
    case type_ of
        Consumable ->
            False

        Armor ->
            False

        UnarmedWeapon ->
            True

        MeleeWeapon ->
            True

        ThrownWeapon ->
            True

        SmallGun ->
            True

        BigGun ->
            True

        EnergyWeapon ->
            True

        Book ->
            False

        Misc ->
            False

        Ammo ->
            False


isAmmo : Type -> Bool
isAmmo type_ =
    case type_ of
        Ammo ->
            True

        Consumable ->
            False

        Armor ->
            False

        UnarmedWeapon ->
            False

        MeleeWeapon ->
            False

        ThrownWeapon ->
            False

        SmallGun ->
            False

        BigGun ->
            False

        EnergyWeapon ->
            False

        Book ->
            False

        Misc ->
            False


name : Type -> String
name type__ =
    case type__ of
        Consumable ->
            "Consumable"

        Book ->
            "Book"

        Armor ->
            "Armor"

        Misc ->
            "Miscellaneous"

        UnarmedWeapon ->
            "Unarmed Weapon"

        MeleeWeapon ->
            "Melee Weapon"

        ThrownWeapon ->
            "Thrown Weapon"

        SmallGun ->
            "Small Gun"

        BigGun ->
            "Big Gun"

        EnergyWeapon ->
            "Energy Weapon"

        Ammo ->
            "Ammo"
