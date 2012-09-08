//
//  CFNetworkErrors+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 8/22/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#ifndef __CFNETWORKERRORS_SIEXTENSION__
#define __CFNETWORKERRORS_SIEXTENSION__

#if PRAGMA_ONCE
#   pragma once
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
#if PRAGMA_ENUM_ALWAYSINT
#   pragma enumsalwaysint on
#endif

/*
 *  SINetworkErrorsExtended
 *
 *  Discussion:
 *	Enum extended base CFNetworkErrors with Client Errors 4xx and Server Errors 5xx
 *  Follows rfc2616 as discussed in http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 *  Added rfc2324, rfc2817, rfc4918, rfc6585, and some non-standard
 */
enum SINetworkErrorsExtended {
    // Client Errors; 4xx
    kSIErrorClientBadRequest = 400,
    kSIErrorClientUnauthorized = 401,
    kSIErrorClientPaymentRequired = 402,
    kSIErrorClientForbidden = 403,
    kSIErrorClientNotFound = 404,
    kSIErrorClientMethodNotAllowed = 405,
    kSIErrorClientNotAcceptable = 406,
    kSIErrorClientProxyAuthenticationRequired = 407,
    kSIErrorClientRequestTimeout = 408,
    kSIErrorClientConflict = 409,
    kSIErrorClientGone = 410,
    kSIErrorClientLengthRequired = 411,
    kSIErrorClientPreconditionFailed = 412,
    kSIErrorClientRequestEntityTooLarge = 413,
    kSIErrorClientRequestURITooLong = 414,
    kSIErrorClientUnsupportedMediaType = 415,
    kSIErrorClientRequestedRangeNotSatisfiable = 416,
    kSIErrorClientExpectationFailed = 417,
    // beyond rfc2616
    kSIErrorClientImaTeapot = 418, // IETF April Fools' jokes
    kSIErrorClientEnhanceYourCalm = 420, // non-standard, used by Twitter
    kSIErrorClientUnprocessableEntity = 422, // WebDAV; rfc4918
    kSIErrorClientLocked = 423, // WebDAV; rfc4918
    kSIErrorClientFailedDependency = 424, // WebDAV; rfc4918
    kSIErrorClientMethodFailure = 424, // WebDAV, non-standard
    kSIErrorClientUnorderedCollection = 425,
    kSIErrorClientUpgradeRequired = 426, // rfc2817
    kSIErrorClientPreconditionRequired = 428, // rfc6585
    kSIErrorClientTooManyRequests = 429, // rfc6585
    kSIErrorClientRequestHeaderFieldsTooLarge = 431, // rfc6585
    
    // Server Errors; 5xx
    kSIErrorServerInternalServerError = 500,
    kSIErrorServerNotImplemented = 501,
    kSIErrorServerBadGateway = 502,
    kSIErrorServerServiceUnavailable = 503,
    kSIErrorServerGatewayTimeout = 504,
    kSIErrorServerHTTPVersionNotSupported = 505,
    // beyond rfc2616
    kSIErrorServerVariantAlsoNegotiates = 506, // rfc 2295
    kSIErrorServerInsufficientStorage = 507, // WebDAV; rfc4918
    kSIErrorServerLoopDetected = 508, // WebDAV; rfc5842
    kSIErrorServerBandwidthLimitExceeded = 509, // Apache; non-standard
    kSIErrorServerNotExtended = 510, // rfc2774
    kSIErrorServerNetworkAuthenticationRequired = 511, // rfc6585
    
};
typedef enum SINetworkErrorsExtended SINetworkErrorsExtended;

#ifdef __cplusplus
}
#endif

#endif /* __CFNETWORKERRORS_SIEXTENSION__ */
