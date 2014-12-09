//
//  EvstEnvironment.m
//  Everest
//
//  Created by Rob Phillips on 12/6/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstEnvironment.h"

// Setup the base URL and URL scheme
#if CD_ENVIRONMENT == kEvstEnvironmentLocal
    NSString *const kEvstMixpanelAPIKey = @"key-goes-here";
    NSString *const kEvstServerBaseURLString = @"http://0.0.0.0:3000";
    NSString *const kEvstLocalURLSchemeString =  @"evst-localhost";
    NSString *const kEvstS3BucketName =  @"everest-development-images";
#elif CD_ENVIRONMENT == kEvstEnvironmentStaging
    NSString *const kEvstMixpanelAPIKey = @"key-goes-here";
    NSString *const kEvstServerBaseURLString = @"https://everest-api-staging.herokuapp.com";
    NSString *const kEvstLocalURLSchemeString =  @"evst-staging";
    NSString *const kEvstS3BucketName =  @"everest-staging-images";
#elif CD_ENVIRONMENT == kEvstEnvironmentProduction
    NSString *const kEvstMixpanelAPIKey = @"key-goes-here";
    NSString *const kEvstServerBaseURLString =  @"https://everest-api-production.herokuapp.com";
    NSString *const kEvstLocalURLSchemeString =  @"evst";
    NSString *const kEvstS3BucketName =  @"everest-production-images";
#endif

@implementation EvstEnvironment

+ (NSString *)baseURLString {
  return kEvstServerBaseURLString;
}

+ (NSString *)baseURLStringWithAPIPath {
  return [NSString stringWithFormat:@"%@/%@", kEvstServerBaseURLString, [EvstEnvironment apiPath]];
}

+ (NSString *)apiPath {
  NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EvstAPIVersion"];
  return [NSString stringWithFormat:@"api/%@", version];
}

+ (NSString *)evstURLScheme {
  return kEvstLocalURLSchemeString;
}

+ (NSString *)s3Bucket {
  return kEvstS3BucketName;
}

+ (NSString *)mixpanelToken {
  return kEvstMixpanelAPIKey;
}

@end
