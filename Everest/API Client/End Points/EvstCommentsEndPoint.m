//
//  EvstCommentsEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 1/6/14.
//  Copyright (c) 2014 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstCommentsEndPoint.h"
#import "EverestComment.h"
#import "EvstCustomMapper.h"

@implementation EvstCommentsEndPoint

#pragma mark - CREATE

+ (void)createNewComment:(EverestComment *)comment onMoment:(EverestMoment *)moment success:(void (^)(EverestComment *))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(comment, @"Comment must not be nil when we attempt to CREATE it.");
  ZAssert(moment, @"Moment must not be nil when we attempt to CREATE a new comment on it.");
  NSString *commentsMomentPath = [NSString stringWithFormat:kEndPointCreateListMomentCommentsFormat, moment.uuid];
  [[EvstAPIClient objectManager] postObject:comment path:commentsMomentPath parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // No caching needed
    if (successHandler) {
      successHandler([EvstCustomMapper mappedCommentsToUsersUsingDictionary:mappingResult.dictionary].firstObject);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - DELETE

+ (void)deleteComment:(EverestComment *)comment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(comment, @"Comment must not be nil when we attempt to DELETE it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteCommentFormat, comment.uuid];
  [[EvstAPIClient objectManager] deleteObject:comment path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // No cache invalidation needed
    if (successHandler) {
      successHandler();
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - INDEX

+ (void)getCommentsForMoment:(EverestMoment *)moment beforeDate:(NSDate *)beforeDate offset:(NSUInteger)offset limit:(NSUInteger)limit success:(void (^)(NSArray *comments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(moment, @"Moment must not be nil when we attempt to LIST comments for it.");
  
  NSNumber *limitParam = [NSNumber numberWithInteger:limit];
  NSNumber *offsetParam = [NSNumber numberWithInteger:offset];
  NSString *iso8601String = RKStringFromDate(beforeDate);
  NSString *commentsMomentPath = [NSString stringWithFormat:kEndPointCreateListMomentCommentsFormat, moment.uuid];
  [[EvstAPIClient objectManager] getObjectsAtPath:commentsMomentPath parameters:@{kJsonCreatedBefore : iso8601String, kJsonOffset : offsetParam, kJsonLimit : limitParam} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // No caching needed
    if (successHandler) {
      successHandler([EvstCustomMapper mappedCommentsToUsersUsingDictionary:mappingResult.dictionary]);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

@end
