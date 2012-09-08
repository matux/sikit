//
//  Created by alcodev on 5/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "NSHTTPCookieStorage+SIExtension.h"

@implementation NSHTTPCookieStorage (SIFoundationExtension)

- (void)clearAllCookies
{
    for (NSHTTPCookie *cookie in [self cookies])
        [self deleteCookie:cookie];
}

@end
