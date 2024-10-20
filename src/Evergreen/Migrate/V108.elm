module Evergreen.Migrate.V108 exposing (..)

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

import Evergreen.V105.Types
import Evergreen.V108.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V105.Types.FrontendModel -> ModelMigration Evergreen.V108.Types.FrontendModel Evergreen.V108.Types.FrontendMsg
frontendModel _ =
    ModelReset


backendModel : Evergreen.V105.Types.BackendModel -> ModelMigration Evergreen.V108.Types.BackendModel Evergreen.V108.Types.BackendMsg
backendModel _ =
    ModelReset


frontendMsg : Evergreen.V105.Types.FrontendMsg -> MsgMigration Evergreen.V108.Types.FrontendMsg Evergreen.V108.Types.FrontendMsg
frontendMsg _ =
    MsgUnchanged


toBackend : Evergreen.V105.Types.ToBackend -> MsgMigration Evergreen.V108.Types.ToBackend Evergreen.V108.Types.BackendMsg
toBackend _ =
    MsgUnchanged


backendMsg : Evergreen.V105.Types.BackendMsg -> MsgMigration Evergreen.V108.Types.BackendMsg Evergreen.V108.Types.BackendMsg
backendMsg _ =
    MsgUnchanged


toFrontend : Evergreen.V105.Types.ToFrontend -> MsgMigration Evergreen.V108.Types.ToFrontend Evergreen.V108.Types.FrontendMsg
toFrontend _ =
    MsgOldValueIgnored
