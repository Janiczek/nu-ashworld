module Data.Auth exposing
    ( Auth
    , HasAuth
    , Hashed
    , Password(..)
    , Plaintext
    , Verified
    , adminPasswordChecksOut
    , codec
    , hash
    , init
    , isAdminName
    , isEmpty
    , passwordCodec
    , promote
    , sanitizedCodec
    , selectDefaultWorld
    , setPlaintextPassword
    , unwrap
    , verify
    )

import Codec exposing (Codec)
import Data.WorldInfo exposing (WorldInfo)
import Env
import Logic
import Sha256


type alias Auth a =
    { name : String
    , password : Password a
    , worldName : String
    }


init : Auth a
init =
    { name = ""
    , password = Password ""
    , worldName = ""
    }


codec : Codec (Auth a)
codec =
    Codec.object
        (\name password worldName ->
            { name = name
            , password = password
            , worldName = worldName
            }
        )
        |> Codec.field "name" .name Codec.string
        |> Codec.field "password" .password passwordCodec
        |> Codec.field "worldName" .worldName Codec.string
        |> Codec.buildObject


sanitizedCodec : Codec (Auth a)
sanitizedCodec =
    Codec.object
        (\name worldName ->
            { name = name
            , password = Password "<omitted>"
            , worldName = worldName
            }
        )
        |> Codec.field "name" .name Codec.string
        |> Codec.field "worldName" .worldName Codec.string
        |> Codec.buildObject


passwordCodec : Codec (Password a)
passwordCodec =
    Codec.custom
        (\passwordEncoder value ->
            case value of
                Password arg0 ->
                    passwordEncoder arg0
        )
        |> Codec.variant1 "Password" Password Codec.string
        |> Codec.buildCustom


type Password a
    = Password String


type Plaintext
    = Plaintext


type Hashed
    = Hashed


{-| All verified passwords are hashed already.
(The transition to Verified can only be done from Hashed, not Plaintext)
-}
type Verified
    = Verified


type alias HasAuth a =
    { a
        | name : String
        , password : Password Verified
        , worldName : String
    }


setPlaintextPassword : String -> Auth a -> Auth Plaintext
setPlaintextPassword password_ auth =
    { name = auth.name
    , password = Password password_
    , worldName = auth.worldName
    }


hash : Auth Plaintext -> Auth Hashed
hash auth =
    let
        (Password password_) =
            auth.password
    in
    { name = auth.name
    , password = Password <| Sha256.sha256 password_
    , worldName = auth.worldName
    }


verify : Auth Hashed -> HasAuth a -> Bool
verify auth sourceOfTruth =
    (auth.name == sourceOfTruth.name)
        && (auth.worldName == sourceOfTruth.worldName)
        && verifyPassword auth.password sourceOfTruth.password


verifyPassword : Password Hashed -> Password Verified -> Bool
verifyPassword (Password tested) (Password correct) =
    tested == correct


{-| Only use this when you have a good reason, eg. signing up,
changing a password, etc.
-}
promote : Auth Hashed -> Auth Verified
promote auth =
    let
        (Password password_) =
            auth.password
    in
    { name = auth.name
    , password = Password password_
    , worldName = auth.worldName
    }


unwrap : Password a -> String
unwrap (Password password_) =
    password_


isEmpty : Password Hashed -> Bool
isEmpty (Password password_) =
    password_ == emptyHashedPassword


emptyHashedPassword : String
emptyHashedPassword =
    -- Sha256.sha256 ""
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"


{-| Choke on that :)
-}
adminPasswordChecksOut : Auth Hashed -> Bool
adminPasswordChecksOut { password } =
    unwrap password == Env.adminPasswordHash


isAdminName : Auth a -> Bool
isAdminName { name } =
    name == adminName


adminName : String
adminName =
    "admin"


selectDefaultWorld : List WorldInfo -> Auth a -> Auth a
selectDefaultWorld worlds auth =
    { auth
        | worldName =
            worlds
                |> List.sortBy
                    (\world ->
                        if world.name == Logic.mainWorldName then
                            0

                        else
                            1
                    )
                |> List.head
                |> Maybe.map .name
                |> Maybe.withDefault auth.worldName
    }
