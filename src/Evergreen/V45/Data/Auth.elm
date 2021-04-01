module Evergreen.V45.Data.Auth exposing (..)

type Verified
    = Verified


type Password a
    = Password String


type Plaintext
    = Plaintext


type alias Auth a = 
    { name : String
    , password : (Password a)
    }


type Hashed
    = Hashed