//
//  SwiftTryCatch.h
//
//  Created by William Falcon on 10/10/14.
//  Copyright (c) 2014 William Falcon. All rights reserved.
//


#import <Foundation/Foundation.h>
//@import UIKit;

@interface PiTryCatch : NSObject

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)try:(void(^)())try catch:(void(^)(NSException*exception))catch finally:(void(^)())finally;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;
@end