module Data.Auth exposing
    ( Auth
    , HasAuth
    , Hashed
    , Password(..)
    , Plaintext
    , Verified
    , adminPasswordChecksOut
    , encode
    , encodePassword
    , hash
    , init
    , isAdminName
    , isEmpty
    , promote
    , setPlaintextPassword
    , unwrap
    , verifiedDecoder
    , verifiedPasswordDecoder
    , verify
    )

import Env
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
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


encode : Auth a -> JE.Value
encode auth =
    JE.object
        [ ( "name", JE.string auth.name )
        , ( "password", encodePassword auth.password )
        , ( "worldName", JE.string auth.worldName )
        ]


encodePassword : Password a -> JE.Value
encodePassword password =
    JE.string <| unwrap password


verifiedDecoder : Decoder (Auth Verified)
verifiedDecoder =
    JD.succeed Auth
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" verifiedPasswordDecoder)
        |> JD.andMap (JD.field "worldName" JD.string)


verifiedPasswordDecoder : Decoder (Password Verified)
verifiedPasswordDecoder =
    JD.map Password JD.string


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


{-| Only use this when you have a good reason, eg. registering,
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
