//
//  SwiftTryCatch.h
//
//  Created by William Falcon on 10/10/14.
//  Copyright (c) 2014 William Falcon. All rights reserved.
//


#import "PiTryCatch.h"

@implementation PiTryCatch

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+(void)try:(void (^)())try catch:(void (^)(NSException *))catch finally:(void (^)())finally{
    @try {
        try ? try() : nil;
    }
    
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

+ (void)throwString:(NSString*)s
{
    @throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*)e
{
    @throw e;
}

@end