module Data.Item exposing
    ( Effect(..)
    , Id
    , Item
    , Kind(..)
    , UniqueKey
    , armorClass
    , basePrice
    , create
    , damageResistance
    , damageThreshold
    , decoder
    , encode
    , findMergeableId
    , getUniqueKey
    , name
    , usageEffects
    )

import Data.Skill as Skill exposing (Skill)
import Dict exposing (Dict)
import Dict.Extra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE



-- TODO weight : Kind -> Int


type alias Item =
    { id : Id
    , kind : Kind
    , count : Int
    }


type alias Id =
    Int


type Kind
    = Stimpak
    | BigBookOfScience
    | DeansElectronics
    | FirstAidBook
    | GunsAndBullets
    | ScoutHandbook
    | Robes
    | LeatherJacket
    | LeatherArmor
    | MetalArmor


type Effect
    = Heal Int
    | RemoveAfterUse
    | BookRemoveTicks
    | BookAddSkillPercent Skill


basePrice : Kind -> Int
basePrice kind =
    case kind of
        Stimpak ->
            175

        BigBookOfScience ->
            400

        DeansElectronics ->
            130

        FirstAidBook ->
            175

        GunsAndBullets ->
            425

        ScoutHandbook ->
            200

        Robes ->
            90

        LeatherJacket ->
            250

        LeatherArmor ->
            700

        MetalArmor ->
            1100


armorClass : Kind -> Int
armorClass kind =
    case kind of
        Robes ->
            5

        LeatherJacket ->
            8

        LeatherArmor ->
            15

        MetalArmor ->
            10

        _ ->
            0


damageThreshold : Kind -> Int
damageThreshold kind =
    case kind of
        Robes ->
            0

        LeatherJacket ->
            0

        LeatherArmor ->
            2

        MetalArmor ->
            4

        _ ->
            0


damageResistance : Kind -> Int
damageResistance kind =
    {- TODO this is for the normal damage type. TODO add all other kinds
       (laser, ...)
    -}
    case kind of
        Robes ->
            20

        LeatherJacket ->
            20

        LeatherArmor ->
            25

        MetalArmor ->
            30

        _ ->
            0


isArmor : Kind -> Bool
isArmor kind =
    case kind of
        Stimpak ->
            False

        BigBookOfScience ->
            False

        DeansElectronics ->
            False

        FirstAidBook ->
            False

        GunsAndBullets ->
            False

        ScoutHandbook ->
            False

        Robes ->
            True

        LeatherJacket ->
            True

        LeatherArmor ->
            True

        MetalArmor ->
            True


encode : Item -> JE.Value
encode item =
    JE.object
        [ ( "id", JE.int item.id )
        , ( "kind", encodeKind item.kind )
        , ( "count", JE.int item.count )
        ]


decoder : Decoder Item
decoder =
    JD.succeed Item
        |> JD.andMap (JD.field "id" JD.int)
        |> JD.andMap (JD.field "kind" kindDecoder)
        |> JD.andMap (JD.field "count" JD.int)


encodeKind : Kind -> JE.Value
encodeKind kind =
    case kind of
        Stimpak ->
            JE.string "stimpak"

        BigBookOfScience ->
            JE.string "big-book-of-science"

        DeansElectronics ->
            JE.string "deans-electronics"

        FirstAidBook ->
            JE.string "first-aid-book"

        GunsAndBullets ->
            JE.string "guns-and-bullets"

        ScoutHandbook ->
            JE.string "scout-handbook"

        Robes ->
            JE.string "robes"

        LeatherJacket ->
            JE.string "leather-jacket"

        LeatherArmor ->
            JE.string "leather-armor"

        MetalArmor ->
            JE.string "metal-armor"


kindDecoder : Decoder Kind
kindDecoder =
    JD.string
        |> JD.andThen
            (\kind ->
                case kind of
                    "stimpak" ->
                        JD.succeed Stimpak

                    "big-book-of-science" ->
                        JD.succeed BigBookOfScience

                    "deans-electronics" ->
                        JD.succeed DeansElectronics

                    "first-aid-book" ->
                        JD.succeed FirstAidBook

                    "guns-and-bullets" ->
                        JD.succeed GunsAndBullets

                    "scout-handbook" ->
                        JD.succeed ScoutHandbook

                    "robes" ->
                        JD.succeed Robes

                    "leather-jacket" ->
                        JD.succeed LeatherJacket

                    "leather-armor" ->
                        JD.succeed LeatherArmor

                    "metal-armor" ->
                        JD.succeed MetalArmor

                    _ ->
                        JD.fail <| "Unknown item kind: '" ++ kind ++ "'"
            )


name : Kind -> String
name kind =
    case kind of
        Stimpak ->
            "Stimpak"

        BigBookOfScience ->
            "Big Book of Science"

        DeansElectronics ->
            "Dean's Electronics"

        FirstAidBook ->
            "First Aid Book"

        GunsAndBullets ->
            "Guns and Bullets"

        ScoutHandbook ->
            "Scout Handbook"

        Robes ->
            "Robes"

        LeatherJacket ->
            "Leather Jacket"

        LeatherArmor ->
            "Leather Armor"

        MetalArmor ->
            "Metal Armor"


create :
    { lastId : Int
    , uniqueKey : UniqueKey
    , count : Int
    }
    -> ( Item, Int )
create { lastId, uniqueKey, count } =
    let
        newLastId : Int
        newLastId =
            lastId + 1

        item : Item
        item =
            { id = newLastId
            , kind = uniqueKey.kind
            , count = count
            }
    in
    ( item, newLastId )


{-| This identifies item. Right now this is just the item Kind (eg.
HuntingRifle) but later when we add Mods, UniqueKey will also contain them and
so you will be able to differentiate between (HuntingRifle, []) and
(HuntingRifle, [HuntingRifleUpgrade]) or
(HuntingRifle, [HasAmmo (24, Ammo223FMJ)]) or something.

This hopefully will prevent bugs like player with upgraded weapon buying a
non-upgraded one and it becoming automatically (wrongly) upgraded too.

-}
type alias UniqueKey =
    { kind : Kind }


getUniqueKey : Item -> UniqueKey
getUniqueKey item =
    { kind = item.kind }


findMergeableId : Item -> Dict Id Item -> Maybe Id
findMergeableId item items =
    let
        uniqueKey : UniqueKey
        uniqueKey =
            getUniqueKey item
    in
    items
        |> Dict.find (\_ item_ -> getUniqueKey item_ == uniqueKey)
        |> Maybe.map Tuple.first


usageEffects : Kind -> List Effect
usageEffects kind =
    case kind of
        Stimpak ->
            [ Heal 30
            , RemoveAfterUse
            ]

        BigBookOfScience ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Science
            ]

        DeansElectronics ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Repair
            ]

        FirstAidBook ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.FirstAid
            ]

        GunsAndBullets ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.SmallGuns
            ]

        ScoutHandbook ->
            [ RemoveAfterUse
            , BookRemoveTicks
            , BookAddSkillPercent Skill.Outdoorsman
            ]

        Robes ->
            []

        LeatherJacket ->
            []

        LeatherArmor ->
            []

        MetalArmor ->
            []
