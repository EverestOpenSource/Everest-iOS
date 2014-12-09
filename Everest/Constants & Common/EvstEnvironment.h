//
//  EvstEnvironment.h
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

// Server environments for conditional compilation
#define kEvstEnvironmentLocal 0
#define kEvstEnvironmentStaging 1
#define kEvstEnvironmentProduction 2

// Use production by default
#ifndef CD_ENVIRONMENT
    #ifdef DEBUG
        #define CD_ENVIRONMENT kEvstEnvironmentLocal
    #else
        #define CD_ENVIRONMENT kEvstEnvironmentProduction
    #endif
#endif

@interface EvstEnvironment : NSObject

+ (NSString *)baseURLString;
+ (NSString *)baseURLStringWithAPIPath;
+ (NSString *)apiPath;
+ (NSString *)evstURLScheme;
+ (NSString *)s3Bucket;
+ (NSString *)mixpanelToken;

@end