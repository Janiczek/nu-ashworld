module Evergreen.Migrate.V121 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import Evergreen.V120.Types
import Evergreen.V121.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V120.Types.FrontendModel -> ModelMigration Evergreen.V121.Types.FrontendModel Evergreen.V121.Types.FrontendMsg
frontendModel _ =
    ModelReset


backendModel : Evergreen.V120.Types.BackendModel -> ModelMigration Evergreen.V121.Types.BackendModel Evergreen.V121.Types.BackendMsg
backendModel _ =
    ModelReset


frontendMsg : Evergreen.V120.Types.FrontendMsg -> MsgMigration Evergreen.V121.Types.FrontendMsg Evergreen.V121.Types.FrontendMsg
frontendMsg _ =
    MsgOldValueIgnored


toBackend : Evergreen.V120.Types.ToBackend -> MsgMigration Evergreen.V121.Types.ToBackend Evergreen.V121.Types.BackendMsg
toBackend _ =
    MsgOldValueIgnored


backendMsg : Evergreen.V120.Types.BackendMsg -> MsgMigration Evergreen.V121.Types.BackendMsg Evergreen.V121.Types.BackendMsg
backendMsg _ =
    MsgOldValueIgnored


toFrontend : Evergreen.V120.Types.ToFrontend -> MsgMigration Evergreen.V121.Types.ToFrontend Evergreen.V121.Types.FrontendMsg
toFrontend _ =
    MsgOldValueIgnored
