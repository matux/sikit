//
//  UIImageView+SIExtension.h
//  SIKit
//
//  Created by Matias Pequeno on 9/16/12.
//  Copyright (c) 2012 Silicon Illusions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (SIExtension)

/*!
 Clones basic functionality from AFNetworking extension UIImageView+AFNetworking
 to be used on projects that do not use this library or need to support < iOS 4.
 
 @discussion These methods will not be defined if AFNetworking is being used.

 @warning This implementation is not efficient and should only be used when
            AFNetworking is not available or you need a quick 'n dirty way of
            accomplishing setImageWithURL in iOS 3.
 */

#ifndef _AFNETWORKING_
- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
#endif

@end

