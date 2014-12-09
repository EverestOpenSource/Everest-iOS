//
//  EvstUsersEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 12/9/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstUsersEndPoint.h"
#import "EverestUser.h"
#import "UIImage+EvstAdditions.h"
#import "EvstCacheBase.h"
#import "EvstS3ImageUploader.h"

@implementation EvstUsersEndPoint

#pragma mark - CREATE

+ (void)signUpWithParameters:(NSMutableDictionary *)params image:(UIImage *)image success:(void (^)(EverestUser *currentUser))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  // Setup a block to perform the Everest API request
  void (^signupRequestBlock)(NSString *) = ^void(NSString *imageURLString) {
    if (imageURLString) {
      [params setObject:imageURLString forKey:kJsonRemoteAvatarURL];
    }
    NSDictionary *userParameters = @{kJsonUser : params};
    
    NSURLRequest *request = [[EvstAPIClient objectManager] requestWithObject:nil method:RKRequestMethodPOST path:kEndPointCreateListUsers parameters:userParameters];
    RKObjectRequestOperation *operation = [[EvstAPIClient objectManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      // Ensure we show onboarding for new users on the same device
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEvstDidShowOnboardingKey];
      [[NSUserDefaults standardUserDefaults] synchronize];
      
      EverestUser *newUser = mappingResult.firstObject;
      [EvstUsersEndPoint handleSignUpSuccessForUser:newUser];
      // Caching of current user is handled in API client class
      if (successHandler) {
        successHandler(newUser);
      }
      if (imageURLString) {
        [[EvstS3ImageUploader sharedUploader] clearSuccessfulUploadWithAbsoluteURLString:imageURLString];
      }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }];
    [[EvstAPIClient objectManager] enqueueObjectRequestOperation:operation];
  };
  
  // If we have an attached image, upload it to S3 before making the Everest request
  if (image) {
    [[EvstS3ImageUploader sharedUploader] uploadToS3WithImage:image forType:EvstS3UserAvatarImageUploadType success:^(NSString *s3absoluteURLString) {
      signupRequestBlock(s3absoluteURLString);
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    } progress:^(CGFloat percentUploaded) {
      if (progressHandler) {
        progressHandler(percentUploaded);
      }
    }];
  } else {
    signupRequestBlock(nil);
  }
}

+ (void)requestForgottenPasswordTokenForUserWithEmail:(NSString *)email success:(void (^)())successHandler failure:(void (^)(NSString *))failureHandler {
  ZAssert(email, @"The user's email address must be passed in if we want to request a password reset token for it.");
  [[EvstAPIClient objectManager].HTTPClient postPath:kEndPointForgotPassword parameters:@{kJsonUser : @{kJsonEmail : email}} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - GET

+ (void)getFullUserFromPartialUser:(EverestUser *)user success:(void (^)(EverestUser *))successHandler failure:(void (^)(NSString *))failureHandler {
  ZAssert(user.uuid, @"User's uuid must not be nil when we attempt to GET the user");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, user.uuid];
  [[EvstAPIClient objectManager] getObject:user path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    EverestUser *mappedUser = mappingResult.firstObject;
    if (mappedUser.isCurrentUser) {
      [[EvstAPIClient sharedClient] updateCurrentUser:mappedUser]; // This only updates the current user without changing the memory address, so we need to return the current user so the view uses the proper memory address as well
      mappedUser = [EvstAPIClient currentUser];
    } else {
      mappedUser = [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:mappedUser];
    }
    if (successHandler) {
      successHandler(mappedUser);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)getSuggestedUsersForPage:(NSUInteger)page success:(void (^)(NSArray *suggestedUsers))successHandler {
  [self getTypeOfUsers:kEndPointTypeFeatured page:page limit:kEvstDefaultPagingOffset success:successHandler];
}

+ (void)getEverestTeamWithSuccess:(void (^)(NSArray *everestTeam))successHandler {
  [self getTypeOfUsers:kEndPointTypeTeam page:1 limit:20 success:successHandler];
}

#pragma mark - PUT

+ (void)updateCurrentUserWithUser:(EverestUser *)user success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(user, @"User must not be nil when we attempt to PUT the current user with it.");
  
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, [EvstAPIClient currentUserUUID]];
  [[EvstAPIClient objectManager] putObject:user path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    [[EvstAPIClient sharedClient] updateCurrentUser:mappingResult.firstObject];
    if (successHandler) {
      successHandler();
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)changePassword:(NSDictionary *)params success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert([EvstAPIClient currentUser], @"Current user must not be nil when we attempt to PUT it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, [EvstAPIClient currentUserUUID]];
  [[EvstAPIClient objectManager].HTTPClient putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)updateSettingsWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert([EvstAPIClient currentUser], @"Current user must not be nil when we attempt to PUT it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, [EvstAPIClient currentUserUUID]];
  // The server expects that all settings are sent when one of them is updated.
  EverestUser *currentUser = [EvstAPIClient currentUser];
  NSDictionary *params = @{
                           kJsonRequestSettingsPushLikes : [NSNumber numberWithBool:currentUser.pushNotificationsLikes],
                           kJsonRequestSettingsPushComments : [NSNumber numberWithBool:currentUser.pushNotificationsComments],
                           kJsonRequestSettingsPushFollows : [NSNumber numberWithBool:currentUser.pushNotificationsFollows],
                           kJsonRequestSettingsPushMilestones : [NSNumber numberWithBool:currentUser.pushNotificationsMilestones],
                           kJsonRequestSettingsEmailLikes : [NSNumber numberWithBool:currentUser.emailNotificationsLikes],
                           kJsonRequestSettingsEmailComments : [NSNumber numberWithBool:currentUser.emailNotificationsComments],
                           kJsonRequestSettingsEmailFollows : [NSNumber numberWithBool:currentUser.emailNotificationsFollows],
                           kJsonRequestSettingsEmailMilestones : [NSNumber numberWithBool:currentUser.emailNotificationsMilestones]
                          };
  [[EvstAPIClient objectManager] putObject:currentUser path:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    [[EvstAPIClient sharedClient] updateCurrentUser:mappingResult.firstObject];
    if (successHandler) {
      successHandler();
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - PATCH

+ (void)patchCurrentUserImage:(UIImage *)image success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  [self patchUserImageForType:EvstS3UserAvatarImageUploadType image:image success:successHandler failure:failureHandler progress:progressHandler];
}

+ (void)patchCurrentUserCoverImage:(UIImage *)image success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  [self patchUserImageForType:EvstS3UserCoverImageUploadType image:image success:successHandler failure:failureHandler progress:progressHandler];
}

#pragma mark - Private Convenience Methods

+ (void)getTypeOfUsers:(NSString *)type page:(NSUInteger)page limit:(NSUInteger)limit success:(void (^)(NSArray *suggestedUsers))successHandler {
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstDefaultPagingOffset];
  [[EvstAPIClient objectManager] getObjectsAtPath:[NSString stringWithFormat:kEndPointListTypeOfUsersFormat, type] parameters:@{kJsonOffset : offset, kJsonLimit : [NSNumber numberWithInteger:limit]} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    if (successHandler) {
      successHandler(mappingResult.array);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    DLog(@"Error getting the list of users for type %@: %@", type, error.localizedDescription);
  }];
}

+ (void)handleSignUpSuccessForUser:(EverestUser *)currentUser {
  ZAssert([currentUser uuid], @"No user UUID was given in the SIGN UP response JSON");
  ZAssert([currentUser accessToken], @"No access token was given in the SIGN UP response JSON");
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstAccessTokenDidChangeNotification object:currentUser.accessToken];
  [[EvstAPIClient sharedClient] updateCurrentUser:currentUser];
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserDidSignInNotification object:currentUser];
  
  [EvstAnalytics identifyUserAfterSignup];
}

+ (void)handleSignUpFailure {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserDidFailSignInNotification object:nil];
}

+ (void)patchUserImageForType:(EvstS3ImageUploadType)uploadType image:(UIImage *)image success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  ZAssert([EvstAPIClient currentUser], @"Current user must not be nil when we attempt to PATCH the cover image.");
  ZAssert(image, @"Image must not be nil when we attempt to PATCH the cover image.");
  
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteUserFormat, [EvstAPIClient currentUserUUID]];
  
  // Setup a block to perform the Everest API request
  void (^userRequestBlock)(NSString *) = ^void(NSString *imageURLString) {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (imageURLString) {
      NSString *imageKey = (uploadType == EvstS3UserAvatarImageUploadType) ? kJsonRequestUserAvatarKey : kJsonRequestUserCoverImageKey;
      [parameters setObject:imageURLString forKey:imageKey];
    }
    
    NSURLRequest *request = [[EvstAPIClient objectManager] requestWithObject:[EvstAPIClient currentUser] method:RKRequestMethodPATCH path:path parameters:parameters];
    RKObjectRequestOperation *operation = [[EvstAPIClient objectManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      [[EvstAPIClient sharedClient] updateCurrentUser:mappingResult.firstObject];
      if (successHandler) {
        successHandler();
      }
      if (imageURLString) {
        [[EvstS3ImageUploader sharedUploader] clearSuccessfulUploadWithAbsoluteURLString:imageURLString];
      }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }];
    [[EvstAPIClient objectManager] enqueueObjectRequestOperation:operation];
  };
  
  // If we have an attached image, upload it to S3 before making the Everest request
  if (image) {
    [[EvstS3ImageUploader sharedUploader] uploadToS3WithImage:image forType:uploadType success:^(NSString *s3absoluteURLString) {
      userRequestBlock(s3absoluteURLString);
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    } progress:^(CGFloat percentUploaded) {
      if (progressHandler) {
        progressHandler(percentUploaded);
      }
    }];
  } else {
    userRequestBlock(nil);
  }
}

@end
