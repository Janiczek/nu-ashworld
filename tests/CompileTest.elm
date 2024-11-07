module CompileTest exposing (compileTest)

import Backend
import Expect
import Frontend
import Test exposing (Test)


compileTest : Test
compileTest =
    Test.describe "Does the game compile?"
        [ Test.test "Frontend compiles" <|
            \_ ->
                let
                    _ =
                        Frontend.app
                in
                Expect.pass
        , Test.test "Backend compiles" <|
            \_ ->
                let
                    _ =
                        Backend.app
                in
                Expect.pass
        ]
