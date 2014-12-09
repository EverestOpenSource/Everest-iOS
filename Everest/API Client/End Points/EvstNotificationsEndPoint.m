//
//  EvstNotificationsEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 1/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstNotificationsEndPoint.h"
#import "EverestNotification.h"
#import "EvstCustomMapper.h"

@implementation EvstNotificationsEndPoint

+ (void)getNotificationsCountWithSuccess:(void (^)(NSNumber *count))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager].HTTPClient getPath:kEndPointGetNotificationsCount parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                         options:kNilOptions
                                                           error:nil];
    id count = [json valueForKeyPath:@"meta.total"];
    id result = count ?: [NSNumber numberWithInteger:0];
    if (successHandler) {
      successHandler(result);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)getNotificationsWithSuccess:(void (^)(NSArray *notifications))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager] getObjectsAtPath:kEndPointGetNotifications parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    if (successHandler) {
      successHandler([EvstCustomMapper mappedNotificationsToMessagePartsUsingDictionary:mappingResult.dictionary]);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

@end
