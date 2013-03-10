//
//  SISMTPMessage.m
//  SIKit
//
//  Created by Matias Pequeno on 10/5/10.
//  Copyright 2010 Silicon Illusions, Inc. All rights reserved.
//

#import "SISMTPMessage.h"
#import "SIFoundationExtension.h"
#import "SIUtil.h"

NSString *kSISMTPPartContentDispositionKey = @"kSISMTPPartContentDispositionKey";
NSString *kSISMTPPartContentTypeKey = @"kSISMTPPartContentTypeKey";
NSString *kSISMTPPartMessageKey = @"kSISMTPPartMessageKey";
NSString *kSISMTPPartContentTransferEncodingKey = @"kSISMTPPartContentTransferEncodingKey";

#define SHORT_LIVENESS_TIMEOUT 20.0
#define LONG_LIVENESS_TIMEOUT 60.0

@interface SISMTPMessage ()

@property (nonatomic, readwrite, strong) NSMutableString *inputString;
@property (nonatomic, readwrite, strong) NSTimer *connectTimer;
@property (nonatomic, readwrite, strong) NSTimer *watchdogTimer;

- (void)parseBuffer;
- (BOOL)sendParts;
- (void)cleanUpStreams;
- (void)startShortWatchdog;
- (void)stopWatchdog;
- (NSString *)formatAnAddress:(NSString *)address;
- (NSString *)formatAddresses:(NSString *)addresses;

@end

@implementation SISMTPMessage
{
    NSOutputStream *outputStream;
    NSInputStream *inputStream;
    
    SISMTPState sendState;
    BOOL isSecure;
    
    // Auth support flags
    BOOL serverAuthCRAMMD5;
    BOOL serverAuthPLAIN;
    BOOL serverAuthLOGIN;
    BOOL serverAuthDIGESTMD5;
    
    // Content support flags
    BOOL server8bitMessages;
}
    
- (id)init
{
    static NSArray *defaultPorts = nil;
    
    if (!defaultPorts)
    {
        defaultPorts = @[@(25), @(465), @(587)];
    }
    
    if (self = [super init])
    {
        // Setup the default ports
        self.relayPorts = defaultPorts;
        
        // setup a default timeout (8 seconds)
        _connectTimeout = 8.0;
        
        // by default, validate the SSL chain
        _validateSSLChain = YES;
    }
    
    return self;
}

- (void)dealloc
{
    
    inputStream = nil;
    
    outputStream = nil;
    
    [self.connectTimer invalidate];
    
    [self stopWatchdog];
    
}

- (id)copyWithZone:(NSZone *)zone
{
    SISMTPMessage *smtpMessageCopy = [[[self class] allocWithZone:zone] init];
    smtpMessageCopy.delegate = self.delegate;
    smtpMessageCopy.fromEmail = self.fromEmail;
    smtpMessageCopy.login = self.login;
    smtpMessageCopy.parts = [self.parts copy];
    smtpMessageCopy.pass = self.pass;
    smtpMessageCopy.relayHost = self.relayHost;
    smtpMessageCopy.requiresAuth = self.requiresAuth;
    smtpMessageCopy.subject = self.subject;
    smtpMessageCopy.toEmail = self.toEmail;
    smtpMessageCopy.wantsSecure = self.wantsSecure;
    smtpMessageCopy.validateSSLChain = self.validateSSLChain;
    smtpMessageCopy.ccEmail = self.ccEmail;
    smtpMessageCopy.bccEmail = self.bccEmail;
    
    return smtpMessageCopy;
}

- (void)startShortWatchdog
{
    LogInfo(@"*** starting short watchdog ***");
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:SHORT_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)startLongWatchdog
{
    LogInfo(@"*** starting long watchdog ***");
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:LONG_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)stopWatchdog
{
    LogInfo(@"*** stopping watchdog ***");
    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
}

- (BOOL)send
{
    NSAssert(sendState == kSISMTPIdle, @"Message has already been sent!");
    
    if (_requiresAuth)
    {
        NSAssert(_login, @"auth requires login");
        NSAssert(_pass, @"auth requires pass");
    }
    
    NSAssert(_relayHost, @"send requires relayHost");
    NSAssert(_subject, @"send requires subject");
    NSAssert(_fromEmail, @"send requires fromEmail");
    NSAssert(_toEmail, @"send requires toEmail");
    NSAssert(_parts, @"send requires parts");
    
    if (![_relayPorts count])
    {
        [_delegate messageFailed:self
                          error:[NSError errorWithDomain:@"SISMTPMessageError" 
                                                    code:kSISMTPErrorConnectionFailed 
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery")}]];
        
        return NO;
    }
    
    // Grab the next relay port
    short relayPort = [_relayPorts[0] shortValue];
    
    // Pop this off the head of the queue.
    self.relayPorts = ([_relayPorts count] > 1) ? [_relayPorts subarrayWithRange:NSMakeRange(1, [_relayPorts count] - 1)] : @[];
    
    LogInfo(@"C: Attempting to connect to server at: %@:%d", _relayHost, relayPort);
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:_connectTimeout
                                                         target:self
                                                       selector:@selector(connectionConnectedCheck:)
                                                       userInfo:nil 
                                                        repeats:NO];
    
    NSInputStream * is = nil;
    NSOutputStream * os = nil;
    
    [NSStream getStreamsToHostNamed:_relayHost port:relayPort inputStream:&is outputStream:&os];
    
    inputStream = is;
    outputStream = os;
    
    if ((inputStream != nil) && (outputStream != nil))
    {
        sendState = kSISMTPConnecting;
        isSecure = NO;
        
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
        [inputStream open];
        [outputStream open];
        
        self.inputString = [NSMutableString string];
        
        
        
        return YES;
    }
    else
    {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        
        [_delegate messageFailed:self
                          error:[NSError errorWithDomain:@"SISMTPMessageError" 
                                                    code:kSISMTPErrorConnectionFailed 
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery")}]];
        
        return NO;
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode 
{
    switch(eventCode) 
    {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            memset(buf, 0, sizeof(uint8_t) * 1024);
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) 
            {
                NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                [_inputString appendString:tmpStr];
                
                [self parseBuffer];
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self stopWatchdog];
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            stream = nil; // stream is ivar, so reinit it
            
            if (sendState != kSISMTPMessageSent)
            {
                [_delegate messageFailed:self
                                  error:[NSError errorWithDomain:@"SISMTPMessageError" 
                                                            code:kSISMTPErrorConnectionInterrupted 
                                                        userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The connection to the server was interrupted.", @"server connection interrupted error description"),
                                                                  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery")}]];
				
            }
            
            break;
        }
        default:
            break;
    }
}


- (NSString *)formatAnAddress:(NSString *)address
{
	NSString		*formattedAddress;
	NSCharacterSet	*whitespaceCharSet = [NSCharacterSet whitespaceCharacterSet];
	
	if (([address rangeOfString:@"<"].location == NSNotFound) && ([address rangeOfString:@">"].location == NSNotFound)) {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:<%@>\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];									
	}
	else {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:%@\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];																		
	}
	
	return(formattedAddress);
}

- (NSString *)formatAddresses:(NSString *)addresses
{
	NSCharacterSet	*splitSet = [NSCharacterSet characterSetWithCharactersInString:@";,"];
	NSMutableString	*multipleRcptTo = [NSMutableString string];
	
	if ((addresses != nil) && (![addresses isEqualToString:@""])) {
		if( [addresses rangeOfString:@";"].location != NSNotFound || [addresses rangeOfString:@","].location != NSNotFound ) {
			NSArray *addressParts = [addresses componentsSeparatedByCharactersInSet:splitSet];
			
			for( NSString *address in addressParts ) {
				[multipleRcptTo appendString:[self formatAnAddress:address]];
			}
		}
		else {
			[multipleRcptTo appendString:[self formatAnAddress:addresses]];
		}		
	}
	
	return(multipleRcptTo);
}


- (void)parseBuffer
{
    // Pull out the next line
    NSScanner *scanner = [NSScanner scannerWithString:_inputString];
    NSString *tmpLine = nil;
    
    NSError *error = nil;
    BOOL encounteredError = NO;
    BOOL messageSent = NO;
    
    while (![scanner isAtEnd])
    {
        BOOL foundLine = [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                                 intoString:&tmpLine];
        if (foundLine)
        {
            [self stopWatchdog];
            
            LogInfo(@"S: %@", tmpLine);
            switch (sendState)
            {
                case kSISMTPConnecting:
                {
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        sendState = kSISMTPWaitingEHLOReply;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        LogInfo(@"C: %@", ehlo);
                        if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSISMTPWaitingEHLOReply:
                {
                    // Test auth login options
                    if ([tmpLine hasPrefix:@"250-AUTH"])
                    {
                        NSRange testRange;
                        testRange = [tmpLine rangeOfString:@"CRAM-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthCRAMMD5 = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"PLAIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthPLAIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"LOGIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthLOGIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"DIGEST-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthDIGESTMD5 = YES;
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250-8BITMIME"])
                    {
                        server8bitMessages = YES;
                    }
                    else if ([tmpLine hasPrefix:@"250-STARTTLS"] && !isSecure && _wantsSecure)
                    {
                        // if we're not already using TLS, start it up
                        sendState = kSISMTPWaitingTLSReply;
                        
                        NSString *startTLS = @"STARTTLS\r\n";
                        LogInfo(@"C: %@", startTLS);
                        if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[startTLS UTF8String], [startTLS lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250 "])
                    {
                        if (self.requiresAuth)
                        {
                            // Start up auth
                            if (serverAuthPLAIN)
                            {
                                sendState = kSISMTPWaitingAuthSuccess;
                                NSString *loginString = [NSString stringWithFormat:@"\000%@\000%@", _login, _pass];
                                NSString *authString = [NSString stringWithFormat:@"AUTH PLAIN %@\r\n", [[loginString dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                                LogInfo(@"C: %@", authString);
                                if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else if (serverAuthLOGIN)
                            {
                                sendState = kSISMTPWaitingLOGINUsernameReply;
                                NSString *authString = @"AUTH LOGIN\r\n";
                                LogInfo(@"C: %@", authString);
                                if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else
                            {
                                error = [NSError errorWithDomain:@"SISMTPMessageError" 
                                                            code:kSISMTPErrorUnsupportedLogin
                                                        userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unsupported login mechanism.", @"server unsupported login fail error description"),
                                                                  NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Your server's security setup is not supported, please contact your system administrator or use a supported email account like MobileMe.", @"server security fail error recovery")}];
								
                                encounteredError = YES;
                            }
							
                        }
                        else
                        {
                            // Start up send from
                            sendState = kSISMTPWaitingFromReply;
                            
                            NSString *mailFrom = [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", _fromEmail];
                            LogInfo(@"C: %@", mailFrom);
                            if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom UTF8String], [mailFrom lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                            {
                                error =  [outputStream streamError];
                                encounteredError = YES;
                            }
                            else
                            {
                                [self startShortWatchdog];
                            }
                        }
                    }
                    break;
                }
                    
                case kSISMTPWaitingTLSReply:
                {
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        
                        // Attempt to use TLSv1
                        CFMutableDictionaryRef sslOptions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                        
                        CFDictionarySetValue(sslOptions, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelTLSv1);
                        
                        if (!self.validateSSLChain)
                        {
                            // Don't validate SSL certs. This is terrible, please complain loudly to your BOFH.
                            LogWarning(@"Will not validate SSL chain!!!");
                            
                            CFDictionarySetValue(sslOptions, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
                        }
                        
                        LogInfo(@"Beginning TLSv1...");
                        
                        CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, sslOptions);
                        CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, sslOptions);
                        
                        CFRelease(sslOptions);
                        
                        // restart the connection
                        sendState = kSISMTPWaitingEHLOReply;
                        isSecure = YES;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        LogInfo(@"C: %@", ehlo);
                        
                        if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                        
                        /*
						 else
						 {
						 error = [NSError errorWithDomain:@"SISMTPMessageError" 
						 code:kSISMTPErrorTLSFail
						 userInfo:[NSDictionary dictionaryWithObject:@"Unable to start TLS" 
						 forKey:NSLocalizedDescriptionKey]];
						 encounteredError = YES;
						 }
						 */
                    }
                }
					
                case kSISMTPWaitingLOGINUsernameReply:
                {
                    if ([tmpLine hasPrefix:@"334 VXNlcm5hbWU6"])
                    {
                        sendState = kSISMTPWaitingLOGINPasswordReply;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[_login dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        LogInfo(@"C: %@", authString);
                        if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                    
                case kSISMTPWaitingLOGINPasswordReply:
                {
                    if ([tmpLine hasPrefix:@"334 UGFzc3dvcmQ6"])
                    {
                        sendState = kSISMTPWaitingAuthSuccess;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[_pass dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        LogInfo(@"C: %@", authString);
                        if( SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0 )
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
					
                case kSISMTPWaitingAuthSuccess:
                {
                    if ([tmpLine hasPrefix:@"235 "])
                    {
                        sendState = kSISMTPWaitingFromReply;
                        
                        NSString *mailFrom = server8bitMessages ? [NSString stringWithFormat:@"MAIL FROM:<%@> BODY=8BITMIME\r\n", _fromEmail] : [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", _fromEmail];
                        LogInfo(@"C: %@", mailFrom);
                        if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom cStringUsingEncoding:NSASCIIStringEncoding], [mailFrom lengthOfBytesUsingEncoding:NSASCIIStringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"535 "])
                    {
                        error =[NSError errorWithDomain:@"SISMTPMessageError" 
                                                   code:kSISMTPErrorInvalidUserPass 
                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid username or password.", @"server login fail error description"),
                                                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Go to Email Preferences in the application and re-enter your username and password.", @"server login error recovery")}];
                        encounteredError = YES;
                    }
                    break;
                }
					
                case kSISMTPWaitingFromReply:
                {
					// toc 2009-02-18 begin changes per mdesaro issue 18 - http://code.google.com/p/skpsmtpmessage/issues/detail?id=18
					// toc 2009-02-18 begin changes to support cc & bcc
					
                    if ([tmpLine hasPrefix:@"250 "]) {
                        sendState = kSISMTPWaitingToReply;
                        
						NSMutableString	*multipleRcptTo = [NSMutableString string];
						[multipleRcptTo appendString:[self formatAddresses:_toEmail]];
						[multipleRcptTo appendString:[self formatAddresses:_ccEmail]];
						[multipleRcptTo appendString:[self formatAddresses:_bccEmail]];
						
                        LogInfo(@"C: %@", multipleRcptTo);
                        if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[multipleRcptTo UTF8String], [multipleRcptTo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSISMTPWaitingToReply:
                {
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        sendState = kSISMTPWaitingForEnterMail;
                        
                        NSString *dataString = @"DATA\r\n";
                        LogInfo(@"C: %@", dataString);
                        if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[dataString UTF8String], [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"530 "])
                    {
                        error =[NSError errorWithDomain:@"SISMTPMessageError" 
                                                   code:kSISMTPErrorNoRelay 
                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Relay rejected.", @"server relay fail error description"),
														 NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Your server probably requires a username and password.", @"server relay fail error recovery")}];
                        encounteredError = YES;
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        error =[NSError errorWithDomain:@"SISMTPMessageError" 
                                                   code:kSISMTPErrorInvalidMessage 
                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"To address rejected.", @"server to address fail error description"),
                                                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please re-enter the To: address.", @"server to address fail error recovery")}];
                        encounteredError = YES;
                    }
                    break;
                }
                case kSISMTPWaitingForEnterMail:
                {
                    if ([tmpLine hasPrefix:@"354 "])
                    {
                        sendState = kSISMTPWaitingSendSuccess;
                        
                        if (![self sendParts])
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                    }
                    break;
                }
                case kSISMTPWaitingSendSuccess:
                {
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        sendState = kSISMTPWaitingQuitReply;
                        
                        NSString *quitString = @"QUIT\r\n";
                        LogInfo(@"C: %@", quitString);
                        if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[quitString UTF8String], [quitString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        error =[NSError errorWithDomain:@"SISMTPMessageError" 
                                                   code:kSISMTPErrorInvalidMessage 
                                               userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to logout.", @"server logout fail error description"),
                                                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery")}];
                        encounteredError = YES;
                    }
                }
                case kSISMTPWaitingQuitReply:
                {
                    if ([tmpLine hasPrefix:@"221 "])
                    {
                        sendState = kSISMTPMessageSent;
                        
                        messageSent = YES;
                    }
                }
            }
            
        }
        else
        {
            break;
        }
    }
    self.inputString = [[_inputString substringFromIndex:[scanner scanLocation]] mutableCopy];
    
    if (messageSent)
    {
        [self cleanUpStreams];
        
        [_delegate messageSent:self];
    }
    else if (encounteredError)
    {
        [self cleanUpStreams];
        
        [_delegate messageFailed:self error:error];
    }
}

- (BOOL)sendParts
{
    NSMutableString *message = [[NSMutableString alloc] init];
    static NSString *separatorString = @"--SISMTPMessage--Separator--Delimiter\r\n";
    
	CFUUIDRef	uuidRef   = CFUUIDCreate(kCFAllocatorDefault);
	NSString	*uuid     = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
	CFRelease(uuidRef);
    
    NSDate *now = [[NSDate alloc] init];
	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	
	[message appendFormat:@"Date: %@\r\n", [dateFormatter stringFromDate:now]];
	[message appendFormat:@"Message-id: <%@@%@>\r\n", [(NSString *)uuid stringByReplacingOccurrencesOfString:@"-" withString:@""], self.relayHost];
	
    
    [message appendFormat:@"From:%@\r\n", _fromEmail];
	
    
	if ((self.toEmail != nil) && (![self.toEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"To:%@\r\n", self.toEmail];		
	}
	
	if ((self.ccEmail != nil) && (![self.ccEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"Cc:%@\r\n", self.ccEmail];		
	}
    
    [message appendString:@"Content-Type: multipart/mixed; boundary=SISMTPMessage--Separator--Delimiter\r\n"];
    [message appendString:@"Mime-Version: 1.0 (SISMTPMessage 1.0)\r\n"];
    [message appendFormat:@"Subject:%@\r\n\r\n",_subject];
    [message appendString:separatorString];
    
    NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    LogInfo(@"C: %s", [messageData bytes], [messageData length]);
    if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[messageData bytes], [messageData length]) < 0)
    {
        return NO;
    }
    
    message = [[NSMutableString alloc] init];
    
    for (NSDictionary *part in _parts)
    {
        if (part[kSISMTPPartContentDispositionKey])
        {
            [message appendFormat:@"Content-Disposition: %@\r\n", part[kSISMTPPartContentDispositionKey]];
        }
        [message appendFormat:@"Content-Type: %@\r\n", part[kSISMTPPartContentTypeKey]];
        [message appendFormat:@"Content-Transfer-Encoding: %@\r\n\r\n", part[kSISMTPPartContentTransferEncodingKey]];
        [message appendString:part[kSISMTPPartMessageKey]];
        [message appendString:@"\r\n"];
        [message appendString:separatorString];
    }
    
    [message appendString:@"\r\n.\r\n"];
    
    LogInfo(@"C: %@", message);
    if (SIWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[message UTF8String], [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
    {
        return NO;
    }
    [self startLongWatchdog];
    return YES;
}

- (void)connectionConnectedCheck:(NSTimer *)aTimer
{
    if (sendState == kSISMTPConnecting)
    {
        [inputStream close];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        inputStream = nil;
        
        [outputStream close];
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        outputStream = nil;
        
        // Try the next port - if we don't have another one to try, this will fail
        sendState = kSISMTPIdle;
        [self send];
    }
    
    self.connectTimer = nil;
}

- (void)connectionWatchdog:(NSTimer *)aTimer
{
    [self cleanUpStreams];
    
    // No hard error if we're wating on a reply
    if (sendState != kSISMTPWaitingQuitReply)
    {
        NSError *error = [NSError errorWithDomain:@"SISMTPMessageError" 
                                             code:kSKPSMPTErrorConnectionTimeout 
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Timeout sending message.", @"server timeout fail error description"),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery")}];
        [_delegate messageFailed:self error:error];
    }
    else
    {
        [_delegate messageSent:self];
    }
}

- (void)cleanUpStreams
{
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    inputStream = nil;
    
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    outputStream = nil;
}

@end
