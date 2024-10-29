module LamderaRPC exposing (..)

import Dict exposing (Dict)
import Env
import Http exposing (..)
import Json.Decode as D
import Lamdera exposing (SessionId)
import Lamdera.Json as Json
import Lamdera.Wire3 as Wire3
import Task exposing (Task)
import Types exposing (BackendModel)



-- The Lamdera HTTP RPC abstraction


type RPCResult
    = ResultBytes (List Int)
    | ResultJson Json.Value
    | ResultString String
    | ResultRaw Int String (List HttpHeader) HttpBody


type alias RPCFailure =
    RPCResult


{-| Create a raw response with a `StatusCode`
-}
resultWith : StatusCode -> List HttpHeader -> HttpBody -> RPCResult
resultWith statusCode body =
    ResultRaw (statusToInt statusCode) (statusToString statusCode) body


failWith : StatusCode -> String -> RPCFailure
failWith statusCode stringBody =
    ResultRaw (statusToInt statusCode) (statusToString statusCode) [] (BodyString stringBody)


type alias Headers =
    Dict String String


type HttpBody
    = BodyBytes (List Int)
    | BodyJson Json.Value
    | BodyString String


bodyTypeToString : HttpBody -> String
bodyTypeToString body =
    case body of
        BodyBytes _ ->
            "Bytes"

        BodyJson _ ->
            "JSON"

        BodyString _ ->
            "Raw"


{-| Currently the only supported method is POST

The request URL can be inferred from the `endpoint` field in the request body, i.e. (hostname + "/\_r/" ++ req.endpoint)

-}
type alias HttpRequest =
    { sessionId : String
    , endpoint : String
    , requestId : String
    , headers : Dict String String
    , body : HttpBody
    }



-- @TODO future
-- type alias HttpResponse =
--     { version : String -- HTTP/1.1, HTTP/2, etc.
--     , statusCode : Int -- 200, 404, etc.
--     , statusText : String -- "OK", "Not Found", etc.
--     , headers : List HttpHeader -- List of (header, value) pairs, e.g. [ ("Content-Type", "application/json") ]
--     , body : Maybe HttpBody
--     }


type alias HttpHeader =
    ( String, String )


requestDecoder : D.Decoder HttpRequest
requestDecoder =
    D.map5 HttpRequest
        (Json.field "s" Json.decoderString)
        (Json.field "e" Json.decoderString)
        (Json.field "r" Json.decoderString)
        (Json.field "h" <| D.dict Json.decoderString)
        (D.oneOf
            [ Json.field "i" (Json.decoderList Json.decoderInt |> D.map BodyBytes)
            , Json.field "j" (Json.decoderValue |> D.map BodyJson)
            , Json.field "st" (Json.decoderString |> D.map BodyString)
            ]
        )


rawBody : Json.Value -> HttpBody
rawBody rawReq =
    case Json.decodeValue rawBodyDecoder rawReq of
        Ok body ->
            body

        Err err ->
            BodyString ""


rawBodyDecoder : D.Decoder HttpBody
rawBodyDecoder =
    -- Unlike the requestDecoder which optimistically tries to decode the body as JSON, this decoder
    -- will always decode to a raw string, unless we've got bytes.
    D.oneOf
        [ Json.field "i" (Json.decoderList Json.decoderInt |> D.map BodyBytes)
        , Json.field "j" (Json.decoderString |> D.map BodyString)
        , Json.field "st" (Json.decoderString |> D.map BodyString)
        ]


process :
    (String -> String -> Cmd msg)
    -> (Json.Value -> Cmd msg)
    -> Json.Value
    -> (Json.Value -> HttpRequest -> Types.BackendModel -> ( RPCResult, Types.BackendModel, Cmd msg ))
    -> { a | userModel : BackendModel }
    -> ( { a | userModel : BackendModel }, Cmd msg )
process log rpcOut rawReq handler model =
    case Json.decodeValue requestDecoder rawReq of
        Ok request ->
            let
                ( result, newUserModel, newCmds ) =
                    handler rawReq request model.userModel

                resolveRpc statusCodeInt statusText headers body =
                    rpcOut
                        (Json.object
                            [ ( "t", Json.string "qr" )
                            , ( "r", Json.string request.requestId )
                            , ( "c", Json.int statusCodeInt )
                            , ( "ct", Json.string statusText )
                            , ( "h", headers |> List.map (\( key, val ) -> ( key, Json.string val )) |> Json.object )
                            , body
                            ]
                        )
            in
            case result of
                ResultBytes intList ->
                    ( { model | userModel = newUserModel }
                    , Cmd.batch [ resolveRpc 200 "OK" [] ( "i", Json.list Json.int <| intList ), newCmds ]
                    )

                ResultJson value ->
                    ( { model | userModel = newUserModel }
                    , Cmd.batch [ resolveRpc 200 "OK" [] ( "v", value ), newCmds ]
                    )

                ResultString value ->
                    ( { model | userModel = newUserModel }
                    , Cmd.batch [ resolveRpc 200 "OK" [] ( "vs", Json.string value ), newCmds ]
                    )

                ResultRaw statusCode statusText headers httpBody ->
                    let
                        body =
                            case httpBody of
                                BodyBytes intList ->
                                    ( "i", Json.list Json.int <| intList )

                                BodyJson value ->
                                    ( "v", value )

                                BodyString value ->
                                    ( "vs", Json.string value )
                    in
                    ( model
                    , Cmd.batch [ resolveRpc statusCode statusText headers body, newCmds ]
                    )

        Err err ->
            ( model, log "rpcIn failed to decode requestJson" "" )


asTask :
    (a -> Wire3.Encoder)
    -> Wire3.Decoder b
    -> a
    -> String
    -> Task Http.Error b
asTask encoder decoder requestValue endpoint =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/_r/" ++ endpoint
        , body = Http.bytesBody "application/octet-stream" (Wire3.bytesEncode <| encoder requestValue)
        , resolver =
            case Env.mode of
                Env.Development ->
                    Http.stringResolver <|
                        customResolver
                            (\metadata text ->
                                Json.decodeString (Json.decoderList Json.decoderInt) text
                                    |> Result.mapError (\_ -> BadBody <| "Failed to decode JSON response to intList from " ++ endpoint)
                                    |> Result.andThen
                                        (Wire3.intListToBytes
                                            >> Wire3.bytesDecode decoder
                                            >> Result.fromMaybe (BadBody <| "Failed to decode intList wire response from " ++ endpoint)
                                        )
                            )

                _ ->
                    Http.bytesResolver <|
                        customResolver
                            (\metadata bytes ->
                                Wire3.bytesDecode decoder bytes
                                    |> Result.fromMaybe (BadBody <| "Failed to decode response from " ++ endpoint)
                            )
        , timeout = Just 15000
        }


asTaskJson :
    Json.Value
    -> String
    -> Task Http.Error Json.Value
asTaskJson json endpoint =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/_r/" ++ endpoint
        , body = Http.jsonBody json
        , resolver =
            Http.stringResolver <|
                customResolver
                    (\metadata text ->
                        Json.decodeString Json.decoderValue text
                            |> Result.mapError (\_ -> BadBody <| "Failed to decode response from " ++ endpoint)
                    )
        , timeout = Just 15000
        }


asTaskString :
    String
    -> String
    -> Task Http.Error String
asTaskString requestBody endpoint =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/_r/" ++ endpoint
        , body = Http.stringBody "text/plain" requestBody
        , resolver = Http.stringResolver <| customResolver (\metadata text -> Ok text)
        , timeout = Just 15000
        }


customResolver : (Http.Metadata -> responseType -> Result Http.Error b) -> Http.Response responseType -> Result Http.Error b
customResolver fn response =
    case response of
        BadUrl_ urlString ->
            Err <| BadUrl urlString

        Timeout_ ->
            Err <| Timeout

        NetworkError_ ->
            Err <| NetworkError

        BadStatus_ metadata body ->
            -- @TODO use metadata better here
            Err <| BadStatus metadata.statusCode

        GoodStatus_ metadata text ->
            fn metadata text


handleEndpointBytes :
    (SessionId -> BackendModel -> Headers -> input -> ( Result Http.Error output, BackendModel, Cmd msg ))
    -> Wire3.Decoder input
    -> (output -> Wire3.Encoder)
    -> HttpRequest
    -> BackendModel
    -> ( RPCResult, BackendModel, Cmd msg )
handleEndpointBytes fn decoder encoder args model =
    case args.body of
        BodyBytes intList ->
            case Wire3.bytesDecode decoder (Wire3.intListToBytes intList) of
                Just arg ->
                    case fn args.sessionId model args.headers arg of
                        ( response, newModel, newCmds ) ->
                            case response of
                                Ok value ->
                                    ( ResultBytes <| Wire3.intListFromBytes <| Wire3.bytesEncode <| encoder value, newModel, newCmds )

                                Err httpErr ->
                                    ( failWith StatusBadRequest <| httpErrorToString httpErr, newModel, newCmds )

                Nothing ->
                    ( failWith StatusBadRequest <| "Failed to decode arg for " ++ args.endpoint, model, Cmd.none )

        _ ->
            ( failWith StatusBadRequest <| "Bytes endpoint '" ++ args.endpoint ++ "' was given body type " ++ bodyTypeToString args.body
            , model
            , Cmd.none
            )


handleEndpoint :
    (SessionId -> BackendModel -> HttpRequest -> ( RPCResult, BackendModel, Cmd msg ))
    -> HttpRequest
    -> BackendModel
    -> ( RPCResult, BackendModel, Cmd msg )
handleEndpoint fn args model =
    fn args.sessionId model args


handleEndpointJson :
    (SessionId -> BackendModel -> Headers -> Json.Value -> ( Result Http.Error Json.Value, BackendModel, Cmd msg ))
    -> HttpRequest
    -> BackendModel
    -> ( RPCResult, BackendModel, Cmd msg )
handleEndpointJson fn args model =
    case args.body of
        BodyJson json ->
            case fn args.sessionId model args.headers json of
                ( response, newModel, newCmds ) ->
                    case response of
                        Ok value ->
                            ( ResultJson value, newModel, newCmds )

                        Err httpErr ->
                            ( failWith StatusBadRequest <| httpErrorToString httpErr, newModel, newCmds )

        _ ->
            ( failWith StatusBadRequest <| "JSON endpoint '" ++ args.endpoint ++ "' was given body type " ++ bodyTypeToString args.body
            , model
            , Cmd.none
            )


handleEndpointJsonRaw :
    (SessionId -> BackendModel -> Headers -> Json.Value -> ( Result RPCResult Json.Value, BackendModel, Cmd msg ))
    -> HttpRequest
    -> BackendModel
    -> ( RPCResult, BackendModel, Cmd msg )
handleEndpointJsonRaw fn args model =
    case args.body of
        BodyJson json ->
            case fn args.sessionId model args.headers json of
                ( response, newModel, newCmds ) ->
                    case response of
                        Ok value ->
                            ( ResultJson value, newModel, newCmds )

                        Err failResult ->
                            ( failResult, newModel, newCmds )

        _ ->
            ( failWith StatusBadRequest <| "JSON endpoint '" ++ args.endpoint ++ "' was given body type " ++ bodyTypeToString args.body
            , model
            , Cmd.none
            )


handleEndpointString :
    (SessionId -> BackendModel -> Headers -> String -> ( Result Http.Error String, BackendModel, Cmd msg ))
    -> HttpRequest
    -> BackendModel
    -> ( RPCResult, BackendModel, Cmd msg )
handleEndpointString fn args model =
    case args.body of
        BodyString string ->
            case fn args.sessionId model args.headers string of
                ( response, newModel, newCmds ) ->
                    case response of
                        Ok value ->
                            ( ResultString value, newModel, newCmds )

                        Err httpErr ->
                            ( failWith StatusBadRequest <| httpErrorToString httpErr, newModel, newCmds )

        _ ->
            ( failWith StatusBadRequest <| "String endpoint '" ++ args.endpoint ++ "' was given body type " ++ bodyTypeToString args.body
            , model
            , Cmd.none
            )


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl url ->
            "HTTP Malformed url: " ++ url

        Timeout ->
            "HTTP Timeout exceeded"

        NetworkError ->
            "HTTP Network error"

        BadStatus code ->
            "Unexpected HTTP response code: " ++ String.fromInt code

        BadBody text ->
            "Unexpected HTTP response: " ++ text


{-| Custom type representing all http methods
-}
type Method
    = GET
    | HEAD
    | POST
    | PUT
    | DELETE
    | CONNECT
    | OPTIONS
    | TRACE
    | PATCH


{-| Returns http `Method` as String
-}
methodString : Method -> String
methodString method =
    case method of
        GET ->
            "GET"

        HEAD ->
            "HEAD"

        POST ->
            "POST"

        PUT ->
            "PUT"

        DELETE ->
            "DELETE"

        CONNECT ->
            "CONNECT"

        OPTIONS ->
            "OPTIONS"

        TRACE ->
            "TRACE"

        PATCH ->
            "PATCH"


{-| Custom type representing all http `StatusCode`
-}
type StatusCode
    = StatusContinue
    | StatusSwitchingProtocols
    | StatusProcessing
    | StatusEarlyHints
    | StatusOK
    | StatusCreated
    | StatusAccepted
    | StatusNonAuthoritativeInformation
    | StatusNoContent
    | StatusResetContent
    | StatusPartialContent
    | StatusMultiStatus
    | StatusAlreadyReported
    | StatusIMUsed
    | StatusMultipleChoices
    | StatusMovedPermanently
    | StatusFound
    | StatusSeeOther
    | StatusNotModified
    | StatusUseProxy
    | StatusTemporaryRedirect
    | StatusPermanentRedirect
    | StatusBadRequest
    | StatusUnauthorized
    | StatusPaymentRequired
    | StatusForbidden
    | StatusNotFound
    | StatusMethodNotAllowed
    | StatusNotAcceptable
    | StatusProxyAuthenticationRequired
    | StatusRequestTimeout
    | StatusConflict
    | StatusGone
    | StatusLengthRequired
    | StatusPreconditionFailed
    | StatusPayloadTooLarge
    | StatusURITooLong
    | StatusUnsupportedMediaType
    | StatusRangeNotSatisfiable
    | StatusExpectationFailed
    | StatusMisdirectedRequest
    | StatusUnprocessableEntity
    | StatusLocked
    | StatusFailedDependency
    | StatusTooEarly
    | StatusUpgradeRequired
    | StatusPreconditionRequired
    | StatusTooManyRequests
    | StatusRequestHeaderFieldsTooLarge
    | StatusUnavailableForLegalReasons
    | StatusInternalServerError
    | StatusNotImplemented
    | StatusBadGateway
    | StatusServiceUnavailable
    | StatusGatewayTimeout
    | StatusHTTPVersionNotSupported
    | StatusVariantAlsoNegotiates
    | StatusInsufficientStorage
    | StatusLoopDetected
    | StatusNotExtended
    | StatusNetworkAuthenticationRequired


{-| Returns http StatusCode as integer
-}
statusToInt : StatusCode -> Int
statusToInt code =
    case code of
        StatusContinue ->
            100

        StatusSwitchingProtocols ->
            101

        StatusProcessing ->
            102

        StatusEarlyHints ->
            103

        StatusOK ->
            200

        StatusCreated ->
            201

        StatusAccepted ->
            202

        StatusNonAuthoritativeInformation ->
            203

        StatusNoContent ->
            204

        StatusResetContent ->
            205

        StatusPartialContent ->
            206

        StatusMultiStatus ->
            207

        StatusAlreadyReported ->
            208

        StatusIMUsed ->
            226

        StatusMultipleChoices ->
            300

        StatusMovedPermanently ->
            301

        StatusFound ->
            302

        StatusSeeOther ->
            303

        StatusNotModified ->
            304

        StatusUseProxy ->
            305

        StatusTemporaryRedirect ->
            307

        StatusPermanentRedirect ->
            308

        StatusBadRequest ->
            400

        StatusUnauthorized ->
            401

        StatusPaymentRequired ->
            402

        StatusForbidden ->
            403

        StatusNotFound ->
            404

        StatusMethodNotAllowed ->
            405

        StatusNotAcceptable ->
            406

        StatusProxyAuthenticationRequired ->
            407

        StatusRequestTimeout ->
            408

        StatusConflict ->
            409

        StatusGone ->
            410

        StatusLengthRequired ->
            411

        StatusPreconditionFailed ->
            412

        StatusPayloadTooLarge ->
            413

        StatusURITooLong ->
            414

        StatusUnsupportedMediaType ->
            415

        StatusRangeNotSatisfiable ->
            416

        StatusExpectationFailed ->
            417

        StatusMisdirectedRequest ->
            421

        StatusUnprocessableEntity ->
            422

        StatusLocked ->
            423

        StatusFailedDependency ->
            424

        StatusTooEarly ->
            425

        StatusUpgradeRequired ->
            426

        StatusPreconditionRequired ->
            428

        StatusTooManyRequests ->
            429

        StatusRequestHeaderFieldsTooLarge ->
            431

        StatusUnavailableForLegalReasons ->
            451

        StatusInternalServerError ->
            500

        StatusNotImplemented ->
            501

        StatusBadGateway ->
            502

        StatusServiceUnavailable ->
            503

        StatusGatewayTimeout ->
            504

        StatusHTTPVersionNotSupported ->
            505

        StatusVariantAlsoNegotiates ->
            506

        StatusInsufficientStorage ->
            507

        StatusLoopDetected ->
            508

        StatusNotExtended ->
            510

        StatusNetworkAuthenticationRequired ->
            511


statusToString : StatusCode -> String
statusToString statusCode =
    case statusCode of
        StatusContinue ->
            "Continue"

        StatusSwitchingProtocols ->
            "Switching Protocols"

        StatusProcessing ->
            "Processing"

        StatusEarlyHints ->
            "Early Hints"

        StatusOK ->
            "OK"

        StatusCreated ->
            "Created"

        StatusAccepted ->
            "Accepted"

        StatusNonAuthoritativeInformation ->
            "Non-Authoritative Information"

        StatusNoContent ->
            "No Content"

        StatusResetContent ->
            "Reset Content"

        StatusPartialContent ->
            "Partial Content"

        StatusMultiStatus ->
            "Multi-Status"

        StatusAlreadyReported ->
            "Already Reported"

        StatusIMUsed ->
            "IM Used"

        StatusMultipleChoices ->
            "Multiple Choices"

        StatusMovedPermanently ->
            "Moved Permanently"

        StatusFound ->
            "Found"

        StatusSeeOther ->
            "See Other"

        StatusNotModified ->
            "Not Modified"

        StatusUseProxy ->
            "Use Proxy"

        StatusTemporaryRedirect ->
            "Temporary Redirect"

        StatusPermanentRedirect ->
            "Permanent Redirect"

        StatusBadRequest ->
            "Bad Request"

        StatusUnauthorized ->
            "Unauthorized"

        StatusPaymentRequired ->
            "Payment Required"

        StatusForbidden ->
            "Forbidden"

        StatusNotFound ->
            "Not Found"

        StatusMethodNotAllowed ->
            "Method Not Allowed"

        StatusNotAcceptable ->
            "Not Acceptable"

        StatusProxyAuthenticationRequired ->
            "Proxy Authentication Required"

        StatusRequestTimeout ->
            "Request Timeout"

        StatusConflict ->
            "Conflict"

        StatusGone ->
            "Gone"

        StatusLengthRequired ->
            "Length Required"

        StatusPreconditionFailed ->
            "Precondition Failed"

        StatusPayloadTooLarge ->
            "Payload Too Large"

        StatusURITooLong ->
            "URI Too Long"

        StatusUnsupportedMediaType ->
            "Unsupported Media Type"

        StatusRangeNotSatisfiable ->
            "Range Not Satisfiable"

        StatusExpectationFailed ->
            "Expectation Failed"

        StatusMisdirectedRequest ->
            "Misdirected Request"

        StatusUnprocessableEntity ->
            "Unprocessable Entity"

        StatusLocked ->
            "Locked"

        StatusFailedDependency ->
            "Failed Dependency"

        StatusTooEarly ->
            "Too Early"

        StatusUpgradeRequired ->
            "Upgrade Required"

        StatusPreconditionRequired ->
            "Precondition Required"

        StatusTooManyRequests ->
            "Too Many Requests"

        StatusRequestHeaderFieldsTooLarge ->
            "Request Header Fields Too Large"

        StatusUnavailableForLegalReasons ->
            "Unavailable For Legal Reasons"

        StatusInternalServerError ->
            "Internal Server Error"

        StatusNotImplemented ->
            "Not Implemented"

        StatusBadGateway ->
            "Bad Gateway"

        StatusServiceUnavailable ->
            "Service Unavailable"

        StatusGatewayTimeout ->
            "Gateway Timeout"

        StatusHTTPVersionNotSupported ->
            "HTTP Version Not Supported"

        StatusVariantAlsoNegotiates ->
            "Variant Also Negotiates"

        StatusInsufficientStorage ->
            "Insufficient Storage"

        StatusLoopDetected ->
            "Loop Detected"

        StatusNotExtended ->
            "Not Extended"

        StatusNetworkAuthenticationRequired ->
            "Network Authentication Required"
