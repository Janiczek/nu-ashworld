module Cmd.Extra exposing (andThen, withCmd)


andThen : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThen fn ( model, oldCmd ) =
    let
        ( newModel, newCmd ) =
            fn model
    in
    ( newModel
    , Cmd.batch [ oldCmd, newCmd ]
    )


withCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
withCmd newCmd ( model, oldCmd ) =
    ( model
    , Cmd.batch [ newCmd, oldCmd ]
    )
