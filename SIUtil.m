//
//  SIUtil.m
//  SIKit
//
//  Created by Matias Pequeno on 11/30/09.
//  Copyright 2009 Silicon Illusions, Inc. All rights reserved.
//

#import "SIUtil.h"

#import <UIKit/UIView.h>
#import <UIKit/UIScreen.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "SIFoundationExtension.h"
#import "Reachability.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/sysctl.h>  
#include <sys/types.h>
#include <mach/mach.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>

#pragma mark -
#pragma mark System Utility

OSVersion SIOSVersion(void)
{
	OSVersion v;
    
    NSString * versionString = [[UIDevice currentDevice] systemVersion];
	v.string = [versionString UTF8String];
    
	NSArray *vA = [versionString componentsSeparatedByString:@"."];
	v.major = [((NSString *)vA[0]) intValue];
	v.minor = [((NSString *)vA[1]) intValue];
	v.decimalVersion = (float)v.major + ((float)v.minor / 10.f);
	v.build = [vA count] > 2 ? [((NSString *)vA[2]) intValue] : 0;
	
	return v;
}

static SIDeviceModel cachedDeviceModel = SIDM_UNKNOWN;

NSString *SIRetrieveDeviceModelUsingAppleFormat(void)
{
	// Get the system platform name
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = @(machine);
	free(machine);

	return platform;
}

SIDeviceModel SIRetrieveDeviceModel(void)
{
	if( cachedDeviceModel == SIDM_UNKNOWN )
	{
		// Get the system platform name
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		NSString *platform = @(machine);
		free(machine);
		
		if(      [platform isEqualToString:@"iPhone1,1"] )	cachedDeviceModel = SIDM_IPHONE_EDGE;
		else if( [platform isEqualToString:@"iPhone1,2"] )	cachedDeviceModel = SIDM_IPHONE_3G;
		else if( [platform isEqualToString:@"iPhone2,1"] )	cachedDeviceModel = SIDM_IPHONE_3GS;
		else if( [platform isEqualToString:@"iPhone3,1"] )	cachedDeviceModel = SIDM_IPHONE_4;
        else if( [platform isEqualToString:@"iPhone3,2"] )	cachedDeviceModel = SIDM_IPHONE_4_VERIZON_CDMA;
        else if( [platform isEqualToString:@"iPhone3,3"] )  cachedDeviceModel = SIDM_IPHONE_4_VERIZON;
        else if( [platform isEqualToString:@"iPhone4,1"] )  cachedDeviceModel = SIDM_IPHONE_4S;
        else if( [platform isEqualToString:@"iPhone5,1"] )  cachedDeviceModel = SIDM_IPHONE_5;
		else if( [platform containsString:@"iPhone"] )		cachedDeviceModel = SIDM_IPHONE_UNKNOWN_NEWER;
		else if( [platform isEqualToString:@"iPod1,1"] )	cachedDeviceModel = SIDM_IPOD_1G;
		else if( [platform isEqualToString:@"iPod2,1"] )	cachedDeviceModel = SIDM_IPOD_2G;
		else if( [platform isEqualToString:@"iPod3,1"] )	cachedDeviceModel = SIDM_IPOD_3G;
		else if( [platform isEqualToString:@"iPod4,1"] )	cachedDeviceModel = SIDM_IPOD_4G;
		else if( [platform containsString:@"iPod"] )		cachedDeviceModel = SIDM_IPOD_UNKNOWN_NEWER;
		else if( [platform isEqualToString:@"iPad1,1"] )	cachedDeviceModel = SIDM_IPAD;
        else if( [platform isEqualToString:@"iPad2,1"] )    cachedDeviceModel = SIDM_IPAD_2;
        else if( [platform isEqualToString:@"iPad2,2"] )    cachedDeviceModel = SIDM_IPAD_2_GSM;
        else if( [platform isEqualToString:@"iPad2,3"] )    cachedDeviceModel = SIDM_IPAD_2_CDMA;
        else if( [platform isEqualToString:@"iPad2,4"] )    cachedDeviceModel = SIDM_IPAD_2_R2;
        else if( [platform isEqualToString:@"iPad3,1"] )    cachedDeviceModel = SIDM_IPAD_3;
        else if( [platform isEqualToString:@"iPad3,2"] )    cachedDeviceModel = SIDM_IPAD_3_CDMA;
        else if( [platform isEqualToString:@"iPad3,3"] )    cachedDeviceModel = SIDM_IPAD_3_GSM;
		else if( [platform containsString:@"iPad"] )		cachedDeviceModel = SIDM_IPAD_UNKNOWN_NEWER;
		else if( [platform containsString:@"i386"] )		cachedDeviceModel = SIDM_SIMULATOR;
        else if( [platform containsString:@"x86_64"] )		cachedDeviceModel = SIDM_SIMULATOR;
		else cachedDeviceModel = SIDM_UNKNOWN;
	}
	
	return cachedDeviceModel;
}

NSString *SIParseDeviceModel(SIDeviceModel model)
{
	switch( model ) {
		case SIDM_IPHONE_EDGE:			return @"iPhone 1G/Edge";
		case SIDM_IPHONE_3G:			return @"iPhone 3G";
		case SIDM_IPHONE_3GS:			return @"iPhone 3GS";
		case SIDM_IPHONE_4:				return @"iPhone 4";
        case SIDM_IPHONE_4S:            return @"iPhone 4S";
        case SIDM_IPHONE_5:             return @"iPhone 5";
		case SIDM_IPHONE_UNKNOWN_NEWER: return @"iPhone Unknown newer model";
		case SIDM_IPOD_1G:				return @"iPod 1st Gen";
		case SIDM_IPOD_2G:				return @"iPod 2st Gen";
		case SIDM_IPOD_3G:				return @"iPod 3rd Gen";
		case SIDM_IPOD_4G:				return @"iPod 4th Gen";
		case SIDM_IPOD_UNKNOWN_NEWER:	return @"iPod Unknown newer model";
		case SIDM_IPAD:					return @"iPad";
        case SIDM_IPAD_2:               return @"iPad 2";
        case SIDM_IPAD_3:               return @"iPad 3";
		case SIDM_IPAD_UNKNOWN_NEWER:	return @"iPad Unknown newer model";
		case SIDM_SIMULATOR:			return @"Device Simulator";
		case SIDM_UNKNOWN:				return @"Device Unknown";
		default: return @"Device Model Error";
	}
	
}

NSString *SIApplicationVersion(void)
{
	return (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

NSString *SIPhoneNumber(void)
{
	NSString *phoneNumber = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"SBFormattedPhoneNumber"];
	return phoneNumber;	
}

NSDictionary *SIGlobalPreferences(void)
{
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/.GlobalPreferences.plist"];  
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];  
	//CFShow(dict);
	return dict;
}

NSURL *SIApplicationDocumentsDirectory(void)
{
    return ([[NSFileManager defaultManager] respondsToSelector:@selector(URLsForDirectory:inDomains:)] ?
                [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] :
                [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
}

BOOL SIMultitaskingSupport(void)
{
    BOOL backgroundSupported = NO;
    if( [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] )
        backgroundSupported = [UIDevice currentDevice].multitaskingSupported;
    return backgroundSupported;
}

double SIAvailableMemory(void)
{
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if( kernReturn != KERN_SUCCESS )
		return LONG_MAX;
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

void SIEnableDebugToFile(NSString *filename)
{
	// Create OS specific path
	const char *path = [[[SIApplicationDocumentsDirectory() absoluteString] stringByAppendingPathComponent:filename] UTF8String];
	// Specify stderr writes to a file (truncating contents first) 
	freopen(path, "w", stderr);
	
	LogInfo(@"Enabled debug to path: %@", [NSString stringWithUTF8String:path]);;
}

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
//
// Because the definition of the kinfo_proc structure (in <sys/sysctl.h>) is 
// conditionalized by __APPLE_API_UNSTABLE, you should restrict use of the 
// code below to the debug build of your program.
BOOL SIDebuggerAttached(void)
{
	int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
	
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
	
    info.kp_proc.p_flag = 0;
	
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
	
    // Call sysctl.
	
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
	
    // We're being debugged if the P_TRACED flag is set.
	
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

BOOL SIRunningOnSimulator(void)
{
    return SIRetrieveDeviceModel() == SIDM_SIMULATOR;
}

void SICallNumber(NSString *number)
{
	// clean number from category text (home, mobile, etc)
	NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@":"];
	NSArray *array = [number componentsSeparatedByCharactersInSet:charsToRemove];
	// (index 0 is the category, index 1 is the ": " string, index 2 is finally the complete number
	NSString *cleanNumber = array[1];
	LogInfo(@"about to call %@", cleanNumber);
	NSString *url = [[@"tel://" stringByAppendingString:cleanNumber] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

void SISendSMS(NSString *number)
{
	NSString *url = [[@"sms://" stringByAppendingString:number] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

UIView *SIRetrieveKeyboardView(void)
{
    for( UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows] ) 
	{
        // Now iterating over each subview of the available windows
        for( UIView *keyboard in [keyboardWindow subviews] ) 
		{
            // Check to see if the description of the view we have referenced is UIKeyboard.
            // If so then we found the keyboard view that we were looking for.
            if( [[keyboard description] hasPrefix:@"<UIKeyboard"] ) 
				return keyboard;
		}
	}
	
	return nil;
}

#pragma mark -
#pragma mark Graphics Utility

CGSize SIStatusBarSize(void)
{
	return [[UIApplication sharedApplication] statusBarFrame].size;
}

float SINavigationBarHeight(void)
{
    return SIIdiomIsPhone()?32.f:44.f;
}

CGSize SIScreenSize(void)
{
	return [UIScreen mainScreen].bounds.size;
}

CGSize SIScreenPercentage(CGFloat p)
{
	CGSize ss = SIScreenSize();
	ss.width = nearbyint(ss.width * p);
	ss.height = nearbyint(ss.height * p);
	return ss;
}

CGFloat SIFontPixelToPoint(int pixelSize)
{
	/*if( SIRetrieveDeviceModel() == SIDM_IPHONE_4 || SIRetrieveDeviceModel() == SIDM_IPHONE_UNKNOWN_NEWER )
		return pixelSize / 1.13195;
	else */
		return pixelSize / 2.2639;

	
    //return (pixelSise * 72/*max in points*/) / 163 /*max in pixels*/ ;
}

// angles in drawing are in radians, where pi radians = 180 degrees
#define DEGREES_TO_RADIANS(x) ( M_PI * (x) / 180.0 )

static BOOL optRoundedInit = NO;
static CGSize roundSize;
static CGFloat roundRadius, roundMinX, roundMinY, roundMaxX, roundMaxY;
static CGFloat angle0, angle90, angle180, angle270, angle360;
static CGRect roundDrawingRect, roundInteriorRect;
static CGMutablePathRef roundClippingPath;

UIImage *SIRoundCornersOfImageOptimized(UIImage *image)
{
	// Single time optimization, bool comparison is the fastest thing a CPU can do, 
	// no worries about perf here
	if( !optRoundedInit )
	{
		roundSize = CGSizeMake(90.f, 90.f);
		roundRadius = MIN(12.f, .5f * MIN(roundSize.width, roundSize.height) );
		
		// it's not that the "interior rect" makes any sense by itself; it's just used
		// to determine the coordinates of the straight parts of the rounded rect
		//
		roundDrawingRect = CGRectMake( 0.0f, 0.0f, roundSize.width, roundSize.height );
		roundInteriorRect = CGRectInset( roundDrawingRect, roundRadius, roundRadius );
		
		roundMinX = CGRectGetMinX( roundInteriorRect );
		roundMinY = CGRectGetMinY( roundInteriorRect );
		roundMaxX = CGRectGetMaxX( roundInteriorRect );
		roundMaxY = CGRectGetMaxY( roundInteriorRect );
		
		angle0   = DEGREES_TO_RADIANS( 0.0 );
		angle90  = DEGREES_TO_RADIANS( 90.0 );
		angle180 = DEGREES_TO_RADIANS( 180.0 );
		angle270 = DEGREES_TO_RADIANS( 270.0 );
		angle360 = DEGREES_TO_RADIANS( 360.0 );
		
		// we're not using a transformation of the coordinate system
		const CGAffineTransform * noTransform = NULL;
		
		// drawing will be counterclockwise
		const bool counterclockwise = NO;  //NO means counterclockwise; YES means clockwise
		
		// if the button size and rounded-corner radius are going to be constant,
		// this block (and its setup) could conceivably be moved to -viewDidLoad,
		// with clippingPath being an instance variable.
		//
		roundClippingPath = CGPathCreateMutable();
		CGPathAddArc( roundClippingPath, noTransform, roundMaxX, roundMaxY, roundRadius, angle0,   angle90,  counterclockwise );
		CGPathAddArc( roundClippingPath, noTransform, roundMinX, roundMaxY, roundRadius, angle90,  angle180, counterclockwise );
		CGPathAddArc( roundClippingPath, noTransform, roundMinX, roundMinY, roundRadius, angle180, angle270, counterclockwise );
		CGPathAddArc( roundClippingPath, noTransform, roundMaxX, roundMinY, roundRadius, angle270, angle360, counterclockwise );
		
		// Warning! clippingPath is never dealloced!
		
		optRoundedInit = YES;
		
	}
	
	// all actual drawing takes place in a drawing context.
    // Since have haven't gone through -drawRect: at this stage, we have to create a context ourselves.
    UIGraphicsBeginImageContext( roundSize );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // all the setup is done; now define the clipping path
    CGContextBeginPath( context );
    CGContextAddPath( context, roundClippingPath );
    CGContextClosePath( context );
    CGContextClip( context );
    
    // ...and draw our image, clipping the corners
    [image drawInRect: roundDrawingRect];
    
    // get the result as an autoreleased image
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // we're done with our image context
    UIGraphicsEndImageContext();
    
    // and return the autoreleased image to the caller
    return resultImage;

}

UIImage *SIRoundCornersOfImage(UIImage *image, CGFloat radius, CGSize size)
{
    // account for a passed-in radius that is too large to work with the size
    radius = MIN(radius, .5 * MIN(size.width, size.height) );
    
    // it's not that the "interior rect" makes any sense by itself; it's just used
    // to determine the coordinates of the straight parts of the rounded rect
    //
    CGRect drawingRect = CGRectMake( 0.0f, 0.0f, size.width, size.height );
    CGRect interiorRect = CGRectInset( drawingRect, radius, radius );
    
    CGFloat minX = CGRectGetMinX( interiorRect );
    CGFloat minY = CGRectGetMinY( interiorRect );
    CGFloat maxX = CGRectGetMaxX( interiorRect );
    CGFloat maxY = CGRectGetMaxY( interiorRect );
    
    CGFloat angle0   = DEGREES_TO_RADIANS( 0.0 );
    CGFloat angle90  = DEGREES_TO_RADIANS( 90.0 );
    CGFloat angle180 = DEGREES_TO_RADIANS( 180.0 );
    CGFloat angle270 = DEGREES_TO_RADIANS( 270.0 );
    CGFloat angle360 = DEGREES_TO_RADIANS( 360.0 );
    
    // we're not using a transformation of the coordinate system
    const CGAffineTransform * noTransform = NULL;
    
    // drawing will be counterclockwise
    const bool counterclockwise = NO;  //NO means counterclockwise; YES means clockwise
    
    // if the button size and rounded-corner radius are going to be constant,
    // this block (and its setup) could conceivably be moved to -viewDidLoad,
    // with clippingPath being an instance variable.
    //
    CGMutablePathRef clippingPath = CGPathCreateMutable();
    CGPathAddArc( clippingPath, noTransform, maxX, maxY, radius, angle0,   angle90,  counterclockwise );
    CGPathAddArc( clippingPath, noTransform, minX, maxY, radius, angle90,  angle180, counterclockwise );
    CGPathAddArc( clippingPath, noTransform, minX, minY, radius, angle180, angle270, counterclockwise );
    CGPathAddArc( clippingPath, noTransform, maxX, minY, radius, angle270, angle360, counterclockwise );
    
    // all actual drawing takes place in a drawing context.
    // Since have haven't gone through -drawRect: at this stage, we have to create a context ourselves.
    UIGraphicsBeginImageContext( size );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // all the setup is done; now define the clipping path
    CGContextBeginPath( context );
    CGContextAddPath( context, clippingPath );
    CGContextClosePath( context );
    CGContextClip( context );
    
    // ...and draw our image, clipping the corners
    [image drawInRect: drawingRect];
    
    // get the result as an autoreleased image
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // release the memory for our clipping path (but move to -dealloc if clippingPath 
    // is changed to be an instance variable and its definition is moved to -viewDidLoad)
    CFRelease( clippingPath );
    
    // we're done with our image context
    UIGraphicsEndImageContext();
    
    // and return the autoreleased image to the caller
    return resultImage;
}

UIImage *SIResizeImagePercentage(UIImage *image, int percentage)
{
	CGSize s = [image size];
	float p = (float)percentage / 100.f;
	s.width *= p;
	s.height *= p;
	
	return SIResizeImage(image, s, UIViewContentModeScaleToFill);
	
}

UIImage *SIResizeImage(UIImage *image, CGSize size, UIViewContentMode contentMode)
{
	if( contentMode == UIViewContentModeScaleToFill )
	{
		// Do nothing
	}
	else if( contentMode == UIViewContentModeScaleAspectFit )
	{
		CGFloat relationWidth = size.width / [image size].width;
		CGFloat relationHeight = size.height / [image size].height;
		CGFloat relation = ( relationWidth < relationHeight ) ? relationWidth : relationHeight;
		size = CGSizeMake([image size].width * relation, [image size].height * relation);
	}
	else 
	{
		LogWarning(@"SIResizeImage: UIViewContentMode not supported.");
	}
	
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaledImage = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]];	// Hope this is not the slowest thing in the world... :)
	//UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext(); // Autoreleased
	UIGraphicsEndImageContext();
	
	return scaledImage;
	
}

UIImage *SIImageToGrayScale(UIImage *image)
{
    uint8_t kBlue = 1, kGreen = 2, kRed = 3;
	
	CGSize size = image.size;
    int width = size.width;
    int height = size.height;
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
	
    for( int y = 0; y < height; y++ ) 
	{
        for( int x = 0; x < width; x++ ) 
		{
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[kRed] + 0.59 * rgbaPixel[kGreen] + 0.11 * rgbaPixel[kBlue];
			
            // set the pixels to gray
            rgbaPixel[kRed] = gray;
            rgbaPixel[kGreen] = gray;
            rgbaPixel[kBlue] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
	
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
	
    // we're done with image now too
    CGImageRelease(imageRef);
	
    return resultUIImage;
	
}

void SIBeginCurveAnimation(float duration)
{
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
}

void SICommitCurveAnimation(void)
{
	[UIView commitAnimations];
}

NSString *SIStringFromRect(CGRect r)
{
    return [NSString stringWithFormat:@"%f, %f, %f, %f", r.origin.x, r.origin.y, r.size.width, r.size.height];
}

BOOL SIIsRetina(void)
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] > 1.f);
}

BOOL SIIsTall(void)
{
    BOOL isPhone = SIIdiomIsPhone();
    CGFloat screenHeight = ([UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale]);
    return isPhone && (screenHeight >= 1136.f);
}

UIImage *SIRotateImageByDegrees(UIImage *image, CGFloat degrees)
{
    // Create the bitmap context
    UIImage* self = image;
    CGSize size = CGSizeMake(self.size.width *self.scale, self.size.height *self.scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, size.width/2, size.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, SIDegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

UIImage *SIRotateImageByRadians(UIImage *image, CGFloat radians)
{
    return SIRotateImageByDegrees(image, SIRadiansToDegrees(radians));
}

#pragma mark
#pragma mark Orientation Utility

BOOL SICurrentOrientationIsPortrait(void)
{
    if (UIDeviceOrientationIsValidInterfaceOrientation([[UIDevice currentDevice] orientation]))
        return UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
    else
        return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

BOOL SICurrentOrientationIsLandscape(void)
{
    return !SICurrentOrientationIsPortrait();
}

BOOL SICurrentOrientationIsFacingUpOrDown(void)
{
    return !UIDeviceOrientationIsValidInterfaceOrientation([[UIDevice currentDevice] orientation]);
}

UIInterfaceOrientation SIInterfaceOrientationFromDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
    UIInterfaceOrientation interfaceOrientation = 0;
    switch( deviceOrientation ) {
        case UIDeviceOrientationPortrait:           interfaceOrientation = UIInterfaceOrientationPortrait; break;
        case UIDeviceOrientationPortraitUpsideDown: interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown; break;
        case UIDeviceOrientationLandscapeLeft:      interfaceOrientation = UIInterfaceOrientationLandscapeRight; break;
        case UIDeviceOrientationLandscapeRight:     interfaceOrientation = UIInterfaceOrientationLandscapeLeft; break;
        default:
            interfaceOrientation = 0;
    }
    
    return interfaceOrientation;
}

NSString *SIInterfaceOrientationToString(UIInterfaceOrientation interfaceOrientation)
{
    switch( interfaceOrientation ) {
        case UIInterfaceOrientationPortrait:            return @"UIInterfaceOrientationPortrait";
        case UIInterfaceOrientationPortraitUpsideDown:  return @"UIInterfaceOrientationPortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:       return @"UIInterfaceOrientationLandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:      return @"UIInterfaceOrientationLandscapeRight";
    }
}

#pragma mark -
#pragma mark UIView Utility

CGPoint SICenterPointForView(UIView *view)
{
    UIView *tmpView = [[UIView alloc] initWithFrame:view.bounds];
    return tmpView.center;
}

#pragma mark -
#pragma mark String and Data Utility

BOOL SIStringHasUnicodeCharacters(NSString *string)
{
    BOOL containsUnicode = NO;
    for( int i = 0; i < [string length] && !containsUnicode; i++ )
    {
        unichar c = [string characterAtIndex:i];
        containsUnicode = (c > 0xff);
    }
    
    return containsUnicode;
}

NSString *SIValueInJsonForKey(NSString *json, NSString *key)
{
    NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
    if (keyRange.location != NSNotFound)
    {
        NSInteger start = keyRange.location + keyRange.length;
        NSRange valueStart = [json rangeOfString:@":" options:0 range:NSMakeRange(start, [json length] - start)];
        if (valueStart.location != NSNotFound)
        {
            start = valueStart.location + 1;
            NSRange valueEnd = [json rangeOfString:@"," options:0 range:NSMakeRange(start, [json length] - start)];
            if (valueEnd.location != NSNotFound)
            {
                NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                {
                    if (valueEnd.location == NSNotFound)
                    {
                        break;
                    }
                    NSInteger newStart = valueEnd.location + 1;
                    valueEnd = [json rangeOfString:@"," options:0 range:NSMakeRange(newStart, [json length] - newStart)];
                    value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                
                while (YES)
                {
                    NSRange unicode = [value rangeOfString:@"\\u"];
                    if (unicode.location == NSNotFound)
                    {
                        break;
                    }
                    
                    uint32_t c = 0;
                    NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                    NSScanner *scanner = [NSScanner scannerWithString:hex];
                    [scanner scanHexInt:&c];
                    
                    if (c <= 0xffff)
                    {
                        value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                    }
                    else
                    {
                        //convert character to surrogate pair
                        uint16_t x = (uint16_t)c;
                        uint16_t u = (c >> 16) & ((1 << 5) - 1);
                        uint16_t w = (uint16_t)u - 1;
                        unichar high = 0xd800 | (w << 6) | x >> 10;
                        unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                        
                        value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                    }
                }
                return value;
            }
        }
    }
    return nil;

}

#pragma mark -
#pragma mark Network Utility

void SIOpenWeb(NSString *url)
{
	// Add URL prefix
	if( [url rangeOfString:@"http://"].location == NSNotFound )
		url = [@"http://" stringByAppendingString:url];
    
	// Percent escapes
	url = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];	
}

void SISendEmail(NSString *to, NSString *subject, NSString *body)
{
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

void SISendEmailWithAttachment(NSString *to, NSString *subject, NSString *body, NSString *attachment, id <SISMTPMessageDelegate> delegate)
{
    SISMTPMessage *mail = [[SISMTPMessage alloc] init];
    mail.fromEmail = @"matias.pequeno@gmail.com";
    mail.toEmail = to;
    mail.relayHost = @"smtp.gmail.com";
    mail.requiresAuth = YES;
    mail.login = @"matias.pequeno@gmail.com";
    mail.pass = @"werqao7y";
    mail.subject = subject;
    mail.bccEmail = @"";
    mail.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    // mail.validateSSLChain = NO; // Only do this for self-signed certs!
    mail.delegate = delegate;
    
    NSDictionary *plainPart = @{kSISMTPPartContentTypeKey: @"text/plain",
                                kSISMTPPartMessageKey: body,
                                kSISMTPPartContentTransferEncodingKey: @"8bit"};
    
	NSString *filename = [attachment lastPathComponent];
	NSString *typeKey = [NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"", filename];
	NSString *contentDisposition = [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"", filename];
    NSData *attachmentData = [NSData dataWithContentsOfFile:attachment];
    NSDictionary *attachmentPart = @{kSISMTPPartContentTypeKey: typeKey,
                                     kSISMTPPartContentDispositionKey: contentDisposition,
                                     kSISMTPPartMessageKey: [attachmentData encodeBase64ForData],
                                     kSISMTPPartContentTransferEncodingKey: @"base64"};
    
    [mail setParts:@[plainPart, attachmentPart]];
    [mail send];
	
}


BOOL SIAddressFromString(NSString *IPAddress, struct sockaddr_in *address)
{
	if( !IPAddress || ![IPAddress length] ) 
		return NO;
	
	memset((char *) address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if( conversionResult == 0 ) 
	{
		LogError(@"SIAddressFromString: Failed to convert the IP address (%@) string into a sockaddr_in (%@).", IPAddress, address);
		return NO;
	}
	
	return YES;
	
}

NSString *SIIPAddressForHost(NSString *theHost)
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
	
    if (host == NULL) 
	{
        herror("resolv");
		return NULL;
	}
	
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = @(inet_ntoa(*list[0]));
	
	return addressString;
}
/*
BOOL SINetworkAvailable(void)
{
#ifdef _DISABLE_NETWORK
	return NO;
#else
	Reachability *networkReach = [Reachability reachabilityForInternetConnection];
	[networkReach startNotifier];
	//[self updateInterfaceWithReachability: internetReach];
	NetworkStatus netStatus = [networkReach currentReachabilityStatus];
	return netStatus != NotReachable;
#endif
}

BOOL SIHostAvailable(NSString *theHost)
{
#ifdef _DISABLE_NETWORK
	return NO;
#else
	NSString *addressString = SIIPAddressForHost(theHost);
	if (!addressString) 
	{
		printf("Error recovering IP address from host name\n");
		return NO;
	}
	
	struct sockaddr_in address;
	BOOL gotAddress = SIAddressFromString(addressString, &address);
	
	if (!gotAddress)
	{
		printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
		return NO;
	}
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags) 
	{
		printf("Error. Could not recover network reachability flags\n");
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	
	return isReachable;
#endif
}
*/
void SIStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream)
{
    int sockpair[2];
    int success = socketpair(AF_UNIX, SOCK_STREAM, 0, sockpair);
    if (success < 0)
    {
        [NSException raise:@"HSK_CFUtilitiesErrorDomain" format:@"Unable to create socket pair, errno: %d", errno];
    }
    
    CFStreamCreatePairWithSocket(NULL, sockpair[0], readStream, NULL);
    CFReadStreamSetProperty(*readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFStreamCreatePairWithSocket(NULL, sockpair[1], NULL, writeStream);    
    CFWriteStreamSetProperty(*writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
}

CFIndex SIWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length)
{
    CFIndex bufferOffset = 0;
    CFIndex bytesWritten;
	
    while( bufferOffset < length )
    {
        if (CFWriteStreamCanAcceptBytes(outputStream))
        {
            bytesWritten = CFWriteStreamWrite(outputStream, &(buffer[bufferOffset]), length - bufferOffset);
            if (bytesWritten < 0)
            {
                // Bail!                
                return bytesWritten;
            }
            bufferOffset += bytesWritten;
        }
        else if (CFWriteStreamGetStatus(outputStream) == kCFStreamStatusError)
        {
            return -1;
        }
        else
        {
            // Pump the runloop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, true);
        }
    }
    
    return bufferOffset;
	
}

NSString *SIStringFromNetworkError(SINetworkErrorsExtended networkError)
{
    switch( networkError )
    {
            // Client Errors; 4xx
        case kSIErrorClientBadRequest: return @"Bad Request";
        case kSIErrorClientUnauthorized: return @"Unauthorized";
        case kSIErrorClientPaymentRequired: return @"Payment Required";
        case kSIErrorClientForbidden: return @"Forbidden";
        case kSIErrorClientNotFound: return @"Not Found";
        case kSIErrorClientMethodNotAllowed: return @"Method Not Allowed";
        case kSIErrorClientNotAcceptable: return @"Not Acceptable";
        case kSIErrorClientProxyAuthenticationRequired: return @"Proxy Authentication Required";
        case kSIErrorClientRequestTimeout: return @"Request Timeout";
        case kSIErrorClientConflict: return @"Conflict";
        case kSIErrorClientGone: return @"Gone";
        case kSIErrorClientLengthRequired: return @"Length Required";
        case kSIErrorClientPreconditionFailed: return @"Precondition Failed";
        case kSIErrorClientRequestEntityTooLarge: return @"Request Entity Too Large";
        case kSIErrorClientRequestURITooLong: return @"Request URI Too Long";
        case kSIErrorClientUnsupportedMediaType: return @"Unsupported Media Type";
        case kSIErrorClientRequestedRangeNotSatisfiable: return @"Requested Range Not Satisfiable";
        case kSIErrorClientExpectationFailed: return @"Expectation Failed";
            // beyond rfc2616
        case kSIErrorClientImaTeapot: return @"I'm a Teapot";                                       // IETF April Fools' jokes
        case kSIErrorClientEnhanceYourCalm: return @"Enhance Your Calm";                            // non-standard, used by Twitter
        case kSIErrorClientUnprocessableEntity: return @"Unprocessable Entity";                     // WebDAV; rfc4918
        case kSIErrorClientLocked: return @"Locked";                                                // WebDAV; rfc4918
        case kSIErrorClientFailedDependency: return @"Failed Dependency";                           // WebDAV; rfc4918
        case kSIErrorClientUnorderedCollection: return @"Unordered Collection";
        case kSIErrorClientUpgradeRequired: return @"Upgrade Required";                             // rfc2817
        case kSIErrorClientPreconditionRequired: return @"Precondition Required";                   // rfc6585
        case kSIErrorClientTooManyRequests: return @"Too Many Requests";                            // rfc6585
        case kSIErrorClientRequestHeaderFieldsTooLarge: return @"Request Header Fields Too Large";  // rfc6585
            
            // Server Errors; 5xx
        case kSIErrorServerInternalServerError: return @"Internal Server Error";
        case kSIErrorServerNotImplemented: return @"Not Implemented";
        case kSIErrorServerBadGateway: return @"Bad Gateway";
        case kSIErrorServerServiceUnavailable: return @"Service Unavailable";
        case kSIErrorServerGatewayTimeout: return @"Gateway Timeout";
        case kSIErrorServerHTTPVersionNotSupported: return @"HTTP Version Not Supported";
            // beyond rfc2616
        case kSIErrorServerVariantAlsoNegotiates: return @"Variant Also Negotiates";                    // rfc 2295
        case kSIErrorServerInsufficientStorage: return @"Insufficient Storage";                         // WebDAV; rfc4918
        case kSIErrorServerLoopDetected: return @"Loop Detected";                                       // WebDAV; rfc5842
        case kSIErrorServerBandwidthLimitExceeded: return @"Bandwidth Limit Exceeded";                  // Apache; non-standard
        case kSIErrorServerNotExtended: return @"Not Extended";                                         // rfc2774
        case kSIErrorServerNetworkAuthenticationRequired: return @"Network Authentication Required";    // rfc6585
            
        default: return @""; // This case caused a crash when not implemented.
    }
}

#pragma mark -
#pragma mark Math Utility

float normB(unsigned char b)
{
	return (float)b / 255.0f;
}
