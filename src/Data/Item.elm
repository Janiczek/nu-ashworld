typeName : Type -> String
typeName type__ =
    case type__ of
        Food ->
            "Food"

        Book ->
            "Book"

        Armor ->
            "Armor"

        Misc ->
            "Miscellaneous"

        SmallGun ->
            "Small Gun"

        Ammo ->
            "Ammo"
