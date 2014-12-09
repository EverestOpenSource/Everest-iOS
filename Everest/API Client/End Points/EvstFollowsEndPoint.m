//
//  EvstFollowsEndPoint.m
//  Everest
//
//  Created by Chris Cornelis on 02/06/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstFollowsEndPoint.h"

@implementation EvstFollowsEndPoint

#pragma mark - GET

+ (void)getFollowingForUser:(EverestUser *)user page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [self getFollowType:kJsonFollowing forUser:user page:page success:successHandler failure:failureHandler];
}

+ (void)getFollowersForUser:(EverestUser *)user page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [self getFollowType:kJsonFollowers forUser:user page:page success:successHandler failure:failureHandler];
}

+ (void)getFollowType:(NSString *)followType forUser:(EverestUser *)user page:(NSUInteger)page success:(void (^)(NSArray *users))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstDefaultPagingOffset];
  NSString *path = [NSString stringWithFormat:kEndPointGetFollowingFollowersUserFormat, user.uuid];
  NSDictionary *parameters = @{kJsonType: followType,
                               kJsonOffset : offset};
  [[EvstAPIClient objectManager] getObjectsAtPath:path parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Caching handled in table batch update
    if (successHandler) {
      successHandler(mappingResult.array);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - POST

+ (void)followUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(!user.isFollowed, @"Trying to follow a user that's already followed");
  NSString *path = [NSString stringWithFormat:kEndPointFollowUserFormat, user.uuid];
  NSDictionary *parameters = @{kJsonRequestFollowIdKey:user.uuid};
  [[EvstAPIClient objectManager].HTTPClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (!user.isFollowed) {
      user.isFollowed = YES;
      user.followersCount++;
      [EvstAPIClient currentUser].followingCount++;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstFollowingFollowersCountDidChangeNotification object:user];
    }
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

+ (void)unfollowUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(user.isFollowed, @"Trying to unfollow a user that's not yet followed");
  NSString *path = [NSString stringWithFormat:kEndPointUnfollowUserFormat, [EvstAPIClient currentUserUUID], user.uuid];
  [[EvstAPIClient objectManager].HTTPClient deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (user.isFollowed) {
      user.isFollowed = NO;
      user.followersCount--;
      [EvstAPIClient currentUser].followingCount--;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstFollowingFollowersCountDidChangeNotification object:user];
    }
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
