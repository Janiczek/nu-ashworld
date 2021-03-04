module Evergreen.V22.Data.Auth exposing (..)


type Plaintext
    = Plaintext


type Password a
    = Password String


type alias Auth a =
    { name : String
    , password : Password a
    }


type Verified
    = Verified


type Hashed
    = Hashed


unwrap : Password a -> String
unwrap (Password password_) =
    password_
