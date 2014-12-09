//
//  EvstLikesEndPoint.m
//  Everest
//
//  Created by Chris Cornelis on 02/07/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLikesEndPoint.h"
#import "EverestMoment.h"

@implementation EvstLikesEndPoint

#pragma mark - POST

+ (void)likeMoment:(EverestMoment *)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *path = [NSString stringWithFormat:kEndPointLikeMomentFormat, moment.uuid];
  [[EvstAPIClient objectManager].HTTPClient postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [moment addCurrentUserAsLiker];
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - DELETE

+ (void)unlikeMoment:(EverestMoment *)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSString *path = [NSString stringWithFormat:kEndPointLikeMomentFormat, moment.uuid];
  [[EvstAPIClient objectManager].HTTPClient deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [moment removeCurrentUserAsLiker];
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

@end
