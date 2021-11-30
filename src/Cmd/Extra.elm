module Cmd.Extra exposing (andThen)


andThen : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThen fn ( model, oldCmd ) =
    let
        ( newModel, newCmd ) =
            fn model
    in
    ( newModel
    , Cmd.batch [ oldCmd, newCmd ]
    )
