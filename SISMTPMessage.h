//
//  SISMTPMessage.h
//  SIKit
//
//  Created by Matias Pequeno on 10/5/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

enum 
{
    kSISMTPIdle = 0,
    kSISMTPConnecting,
    kSISMTPWaitingEHLOReply,
    kSISMTPWaitingTLSReply,
    kSISMTPWaitingLOGINUsernameReply,
    kSISMTPWaitingLOGINPasswordReply,
    kSISMTPWaitingAuthSuccess,
    kSISMTPWaitingFromReply,
    kSISMTPWaitingToReply,
    kSISMTPWaitingForEnterMail,
    kSISMTPWaitingSendSuccess,
    kSISMTPWaitingQuitReply,
    kSISMTPMessageSent
};
typedef NSUInteger SISMTPState;

// Message part keys
extern NSString *kSISMTPPartContentDispositionKey;
extern NSString *kSISMTPPartContentTypeKey;
extern NSString *kSISMTPPartMessageKey;
extern NSString *kSISMTPPartContentTransferEncodingKey;

// Error message codes
#define kSKPSMPTErrorConnectionTimeout -5
#define kSISMTPErrorConnectionFailed -3
#define kSISMTPErrorConnectionInterrupted -4
#define kSISMTPErrorUnsupportedLogin -2
#define kSISMTPErrorTLSFail -1
#define kSISMTPErrorInvalidUserPass 535
#define kSISMTPErrorInvalidMessage 550
#define kSISMTPErrorNoRelay 530

@class SISMTPMessage;

@protocol SISMTPMessageDelegate

@required

- (void)messageSent:(SISMTPMessage *)message;
- (void)messageFailed:(SISMTPMessage *)message error:(NSError *)error;

@end

@interface SISMTPMessage : NSObject <NSCopying, NSStreamDelegate>

@property(nonatomic, copy) NSString *login;
@property(nonatomic, copy) NSString *pass;
@property(nonatomic, copy) NSString *relayHost;
@property(nonatomic, retain) NSArray *relayPorts;

@property(nonatomic, assign) BOOL requiresAuth;
@property(nonatomic, assign) BOOL wantsSecure;
@property(nonatomic, assign) BOOL validateSSLChain;

@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *fromEmail;
@property(nonatomic, copy) NSString *toEmail;
@property(nonatomic, copy) NSString *ccEmail;
@property(nonatomic, copy) NSString *bccEmail;
@property(nonatomic, retain) NSArray *parts;

@property(nonatomic, assign) NSTimeInterval connectTimeout;

@property(nonatomic, assign) id <SISMTPMessageDelegate> delegate;

- (BOOL)send;

@end
