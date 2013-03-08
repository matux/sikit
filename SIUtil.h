//
//  SIUtil.h
//  SIKit
//
//  Created by Matias Pequeno on 7/2/09.
//  Copyright 2009 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#include <netinet/in.h>

#import "SISMTPMessage.h"

@class UIImage;

#pragma mark -
#pragma mark System Utility

typedef enum _SIDeviceModel {
	SIDM_IPHONE_EDGE,
	SIDM_IPHONE_3G,
	SIDM_IPHONE_3GS,
	SIDM_IPHONE_4,
    SIDM_IPHONE_4_VERIZON_CDMA,
    SIDM_IPHONE_4_VERIZON,
    SIDM_IPHONE_4S,
    SIDM_IPHONE_5,
	SIDM_IPHONE_UNKNOWN_NEWER,
	SIDM_IPAD,
    SIDM_IPAD_2,
    SIDM_IPAD_2_GSM,
    SIDM_IPAD_2_CDMA,
    SIDM_IPAD_2_R2,
    SIDM_IPAD_3,
    SIDM_IPAD_3_CDMA,
    SIDM_IPAD_3_GSM,
	SIDM_IPAD_UNKNOWN_NEWER,
	SIDM_IPOD_1G,
	SIDM_IPOD_2G,
	SIDM_IPOD_3G,
	SIDM_IPOD_4G,
	SIDM_IPOD_UNKNOWN_NEWER,
	SIDM_SIMULATOR,
	SIDM_UNKNOWN,
} SIDeviceModel;

typedef struct _OSVersion {
	float decimalVersion;
	unsigned char major;
	unsigned char minor;
	int build;
    const char * string;
} OSVersion;

// Phone properties
OSVersion SIOSVersion(void);
FOUNDATION_STATIC_INLINE float SIOSVersionFloat(void) { return [[[UIDevice currentDevice] systemVersion] floatValue]; }
SIDeviceModel SIRetrieveDeviceModel(void);
NSString *SIRetrieveDeviceModelUsingAppleFormat(void);
NSString *SIParseDeviceModel(SIDeviceModel model);
NSString *SIApplicationVersion(void); /*! @discussion make it: inline (...) __attribute__((always_inline)) */
NSString *SIPhoneNumber(void);
NSDictionary *SIGlobalPreferences(void);
NSURL *SIApplicationDocumentsDirectory(void); /*! @discussion Returns the path to the application's Documents directory. */
BOOL SIMultitaskingSupport(void);
BOOL SIRunningOnSimulator(void);
FOUNDATION_STATIC_INLINE BOOL SIIdiomIsPhone(void)  { return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone); }
FOUNDATION_STATIC_INLINE BOOL SIIdiomIsPad(void)    { return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad); }
FOUNDATION_STATIC_INLINE NSString *SIConcatIdiom(NSString *concat)  { return [concat stringByAppendingString:(SIIdiomIsPhone()?@"_iPhone":@"_iPad")]; }

// Phone functions
void SISendSMS(NSString *number);
void SICallNumber(NSString *number);

// Misc
double SIAvailableMemory(void);
UIView *SIRetrieveKeyboardView(void);
void SIEnableDebugToFile(NSString *filename);
BOOL SIDebuggerAttached(void);

#pragma mark -
#pragma mark Language Utility

#define SI_GCD_AVAILABLE  (SIOSVersionFloat() >= 4.f)

// Allow modern Objective-C literals when compiling in pre-6.0 SDKs
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSDictionary(subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end
@interface NSMutableDictionary(subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end
@interface NSArray(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end
@interface NSMutableArray(subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
#endif

#pragma mark -
#pragma mark Graphics Utility

CGSize SIStatusBarSize(void);
float SINavigationBarHeight(void);
CGSize SIScreenSize(void);
CGSize SIScreenPercentage(CGFloat p);
UIImage *SIRoundCornersOfImageOptimized(UIImage *image); // Defaults to radius 12 and size 90, 90
UIImage *SIRoundCornersOfImage(UIImage *image, CGFloat radius, CGSize size);
UIImage *SIResizeImagePercentage(UIImage *image, int percentage);
UIImage *SIResizeImage(UIImage *image, CGSize size, UIViewContentMode contentMode); // UIViewContentModeScaleAspectFit is the only UIViewContentMode currently supported 
CGFloat SIFontPixelToPoint(int pixelSize);
UIImage *SIImageToGrayScale(UIImage *image);
void SIBeginCurveAnimation(float duration);
void SICommitCurveAnimation(void);
NSString *SIStringFromRect(CGRect r);
BOOL SIIsRetina(void);
BOOL SIIsTall(void);
UIImage *SIRotateImageByDegrees(UIImage *image, CGFloat degrees);
UIImage *SIRotateImageByRadians(UIImage *image, CGFloat radians);

#pragma mark
#pragma mark Orientation Utility

BOOL SICurrentOrientationIsPortrait(void);
BOOL SICurrentOrientationIsLandscape(void);
BOOL SICurrentOrientationIsFacingUpOrDown(void);
UIInterfaceOrientation SIInterfaceOrientationFromDeviceOrientation(UIDeviceOrientation deviceOrientation);
NSString *SIInterfaceOrientationToString(UIInterfaceOrientation interfaceOrientation);

#pragma mark -
#pragma mark UIView Utility

CGPoint SICenterPointForView(UIView *view);

#pragma mark -
#pragma mark String and Data Utility

BOOL SIStringHasUnicodeCharacters(NSString *string);
NSString *SIValueInJsonForKey(NSString *json, NSString *key);

#pragma mark -
#pragma mark Network Utility

BOOL SIAddressFromString(NSString *IPAddress, struct sockaddr_in *address);
NSString *SIIPAddressForHost(NSString *theHost); /*! @discussion Use NSURL */
BOOL SINetworkAvailable(void);
BOOL SIHostAvailable(NSString *theHost); /*! @discussion Use NSURL */
void SISendEmail(NSString *to, NSString *subject, NSString *body);
void SISendEmailWithAttachment(NSString *to, NSString *subject, NSString *body, NSString *attachment, id <SISMTPMessageDelegate> delegate);
void SIOpenWeb(NSString *url);
NSString *SIStringFromNetworkError(SINetworkErrorsExtended networkError); /*! @discussion Only supports SINetworkErrorsExtended */

// Streams
void SIStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
CFIndex SIWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length);

#pragma mark -
#pragma mark Math Utility

FOUNDATION_STATIC_INLINE double SIDegreesToRadians(double degrees) { return degrees * M_PI / 180.0; }
FOUNDATION_STATIC_INLINE double SIRadiansToDegrees(double radians) { return radians * 180.0 / M_PI; }
float SINormB(unsigned char b);
