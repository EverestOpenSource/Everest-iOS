//
//  EvstFacebook.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstFacebook.h"
#import "EvstSocialIntegrationsEndPoint.h"
#import "EvstSessionsEndPoint.h"

@implementation EvstFacebook

#pragma mark - Singleton & Class Init

+ (instancetype)sharedInstance {
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  if (self = [super init]) {
    [FBSettings setDefaultAppID:kEvstFacebookAppID];
    [FBSettings setDefaultDisplayName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
  }
  return self;
}

#pragma mark - Sessions

+ (BOOL)isOpen {
  return [FBSession activeSession].isOpen;
}

+ (NSString *)accessToken {
  return [FBSession activeSession].accessTokenData.accessToken;
}

+ (void)closeAndClearTokenInformation {
  [FBSession.activeSession closeAndClearTokenInformation];
  [FBSession.activeSession close];
  [FBSession setActiveSession:nil];
}

+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
  if (!error && state == FBSessionStateOpen) {
    DLog(@"Facebook session opened; user is logged in w/ Facebook");
    return;
  }
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
    DLog(@"Facebook session closed; user is logged out of Facebook");
  }
}


#pragma mark - Signing In

+ (void)getActiveFacebookUserInfoAndSignInWithSuccess:(void (^)(EverestUser *user))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  // We need to make sure to close any previously opened sessions
  if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
    [FBSession.activeSession closeAndClearTokenInformation];
  }
  
  [FBSession openActiveSessionWithReadPermissions:self.readOnlyPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    [self sessionStateChanged:session state:status error:error];
    
    // Handle any errors first
    if (error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([self messageForFacebookError:error]);
      }
      return;
    }

    // Facebook might call this block multiple times through state changes, so we should only continue past this point if is open
    if ([EvstFacebook isOpen] == NO) {
      return;
    }
    
    // Else, we were successful, so get the user data and log them in
    [self requestFacebookUserProfileMinimalOnly:NO success:^(id result) {
      EverestUser *user = [[EverestUser alloc] init];
      user.firstName = [result valueForKey:@"first_name"];
      user.lastName = [result valueForKey:@"last_name"];
      user.email = [result valueForKey:@"email"];
      user.gender = [result valueForKey:@"gender"];
      NSDictionary *data = [[result valueForKey:@"picture"] valueForKey:@"data"];
      if ([[data valueForKey:@"is_silhouette"] boolValue] == NO) {
        user.avatarURL = [data valueForKey:@"url"];
      }
      
      [EvstSessionsEndPoint loginUser:user withFacebookID:[result valueForKey:@"id"] facebookAccessToken:[self accessToken] success:^(EverestUser *currentUser) {
        // Caching of the user is handled elsewhere
        if (successHandler) {
          successHandler(currentUser);
        }
      } failure:^(NSString *errorMsg) {
        if (failureHandler) {
          failureHandler(errorMsg);
        }
      }];
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    }];
  }];
}

+ (void)requestFacebookUserProfileMinimalOnly:(BOOL)minimal success:(void (^)(id result))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSDictionary *parameters;
  if (minimal) {
    parameters = @{@"fields" : @"id"};
  } else {
    parameters = @{@"fields" : @"id,first_name,last_name,email,gender,picture.type(large),picture.height(1000),picture.width(1000)"};
  }
  [FBRequestConnection startWithGraphPath:@"me" parameters:parameters HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    // Handle any errors first
    if (error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([self messageForFacebookError:error]);
      }
      return;
    }
    
    if (successHandler) {
      successHandler(result);
    }
  }];
}

#pragma mark - Linking / Unlinking

+ (BOOL)userAccountIsLinked {
  // The user's session could be in any number of states, so let's check that it's not in the failed or no session types
  NSUInteger state = [FBSession activeSession].state;
  BOOL createdState = state == FBSessionStateCreated;
  BOOL loginFailedState = state == FBSessionStateClosedLoginFailed;
  return createdState == NO && loginFailedState == NO;
}

+ (void)selectFacebookAccountFromViewController:(UIViewController *)fromViewController withPermissions:(NSArray *)permissions linkWithEverest:(BOOL)linkWithEverest success:(void (^)(ACAccount *facebookAccount))successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler {
  [self.sharedInstance selectAccountWithTypeIdentifier:ACAccountTypeIdentifierFacebook fromViewController:fromViewController options:[self accountOptionsWithPermissions:permissions] success:^(ACAccount *account) {
    if (linkWithEverest) {
      [self linkWithFacebookWithSuccess:^{
        if (successHandler) {
          successHandler(account);
        }
      } failure:^(NSString *errorMsg) {
        if (failureHandler) {
          failureHandler(errorMsg);
        }
      }];
    }
    
    if (successHandler) {
      successHandler(account);
    }
  } failure:^(NSString *errorMsg) {
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  } cancel:^{
    if (cancelHandler) {
      cancelHandler();
    }
  }];
}

+ (void)linkWithFacebookWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [FBSession openActiveSessionWithReadPermissions:self.readOnlyPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    if (error) {
      DLog(@"There was an error linking Facebook %@", error);
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([self messageForFacebookError:error]);
        return;
      }
    }
    
    if (status == FBSessionStateClosed) {
      // Indicates that the session was closed, but the users token remains cached on the device for later use
      if (successHandler) {
        successHandler();
      }
    } else {
      NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;
      [self requestFacebookUserProfileMinimalOnly:YES success:^(id result) {
        [EvstSocialIntegrationsEndPoint linkFacebookWithFacebookID:[result valueForKey:@"id"] authToken:accessToken success:successHandler failure:nil];
      } failure:nil];
    }
  }];
}

+ (void)unlinkWithFacebookWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [EvstSocialIntegrationsEndPoint unlinkFacebookWithSuccess:^{
    [self clearActiveSessionAndToken];
    if (successHandler) {
      successHandler();
    }
  } failure:^(NSString *errorMsg) {
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  }];
}

+ (void)clearActiveSessionAndToken {
  [[FBSession activeSession] closeAndClearTokenInformation];
  [FBSession setActiveSession:nil];
}

#pragma mark - Permissions

+ (NSArray *)readOnlyPermissions {
  return @[@"email", @"user_likes", @"user_interests", @"read_stream"];
}

+ (NSArray *)publishPermissions {
  return @[@"publish_actions"];
}

+ (NSDictionary *)accountOptionsWithPermissions:(NSArray *)permissions {
  return @{ACFacebookAppIdKey : kEvstFacebookAppID,
           ACFacebookPermissionsKey : permissions,
           ACFacebookAudienceKey : ACFacebookAudienceEveryone};
}

+ (BOOL)userCanPublishToFacebook {
  // Note: There is a known issue where the session will still be considered "open" even after the user deauthorizes the app
  // in the Settings.app.  Facebook catches this error the next time they try to post using that token and then clears the
  // token out at that time.  It's not ideal, but we don't have a lot of control over that unfortunately
  return ([FBSession activeSession].isOpen == YES) && ([[FBSession activeSession].permissions indexOfObject:@"publish_actions"] != NSNotFound);
}

+ (void)establishWritePermissionsFromViewController:(UIViewController *)fromViewController success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler {
  if ([self userCanPublishToFacebook]) {
    if (successHandler) {
      successHandler();
    }
  } else {
    // Linking w/ Facebook only asks for "read" permissions, so when they try to post a moment to FB here, we ask them for publish permissions.
    [self establishSessionWithPermissions:[EvstFacebook publishPermissions] success:^{
      // Silently try to patch the server w/ the updated access token, but we don't care if it succeeds or fails
      NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;
      [self requestFacebookUserProfileMinimalOnly:YES success:^(id result) {
        [EvstSocialIntegrationsEndPoint linkFacebookWithFacebookID:[result valueForKey:@"id"] authToken:accessToken success:nil failure:nil];
      } failure:nil];
      if (successHandler) {
        successHandler();
      }
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    }];
  }
}

+ (void)establishSessionWithPermissions:(NSArray *)permissions success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  // Linking w/ Facebook only asks for "read" permissions, so when they try to post a moment to FB here, we ask them for publish permissions.
  [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    // Handle any errors first
    if (error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([self messageForFacebookError:error]);
        return;
      }
    }
    
    // Else, we were successful.
    if (status == FBSessionStateClosed) {
      // Indicates that the session was closed, but the users token remains cached on the device for later use
      if (successHandler) {
        successHandler();
      }
    } else {
      // Ensure the session is in a successful state before we try to get the token.  For example, the user didn't cancel auth w/ Safari
      if ([FBSession activeSession].isOpen) {
        if (successHandler) {
          successHandler();
        }
      } else {
        if (failureHandler) {
          failureHandler(kLocaleFacebookAuthenticationError);
        }
      }
    }
  }];
}

#pragma mark - Lifecycle Handlers

+ (void)handleDidFinishLaunching {
  // Empty
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
  NSRange accessTokenRange = [[url absoluteString] rangeOfString:@"access_token="];
  if (accessTokenRange.location == NSNotFound) {
    // The user did not give the app permission to use FB
    return NO;
  }
  
  // Attempt to handle URLs to complete any FB auth flow
  return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

+ (void)handleDidBecomeActive {
  // Notifies the FB events system that the app has launched & logs an activatedApp event
  [FBAppEvents activateApp];
  
  // Handles activation with regards to returning from iOS 6.0 authorization dialog or from fast app switching
  [FBSession.activeSession handleDidBecomeActive];
}

+ (void)handleWillTerminate {
  [FBSession.activeSession close];
}

#pragma mark - Silent Sharing

+ (NSString *)concatenateMessage:(NSString *)message withLink:(NSString *)link {
  return (message.length == 0) ? link : [message stringByAppendingString:[NSString stringWithFormat:@" %@", link]];
}

+ (void)silentlyShareMessage:(NSString *)message withLink:(NSString *)link momentImage:(UIImage *)momentImage {
  ZAssert(message, @"Message cannot be nil when trying to share on Facebook.");
  
  NSString *filteredMessage = [self filteredSharingMessageForLifecycleMoments:message];
  
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  
  NSString *graphPath = @"me/feed";
  if (momentImage) {
    graphPath = @"me/photos";
    [params setObject:UIImageJPEGRepresentation(momentImage, 0.9f) forKey:@"picture"];
    // For pictures, you can't attach a link so we need to concatenate the link with the message
    filteredMessage = [self concatenateMessage:filteredMessage withLink:link];
  } else {
    [params setObject:link forKey:@"link"];
  }
  [params setObject:filteredMessage forKey:@"message"];

  [FBRequestConnection startWithGraphPath:graphPath parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (error) {
      DLog(@"Error silently sharing message to Facebook with link %@ \n%@", link, error);
      return;
    }
    // Status update posted successfully to Facebook
  }];
}

#pragma mark - Sharing via iOS Native Dialogs

+ (void)shareLink:(NSString *)link fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:nil withLink:link imageURL:nil onService:SLServiceTypeFacebook fromViewController:fromViewController completion:completionHandler];
}

+ (void)shareMoment:(EverestMoment *)moment fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:moment.name withLink:moment.webURL imageURL:moment.imageURL onService:SLServiceTypeFacebook fromViewController:fromViewController completion:completionHandler];
}

+ (void)shareJourney:(EverestJourney *)journey fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:journey.name withLink:journey.webURL onService:SLServiceTypeFacebook fromViewController:fromViewController completion:completionHandler];
}

#pragma mark - Invite Friends

+ (void)getAllFriendsAndShowLoginUI:(BOOL)showLoginUI success:(void (^)(NSArray *facebookFriends))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [FBSession openActiveSessionWithReadPermissions:self.readOnlyPermissions allowLoginUI:showLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    // Handle any errors first
    if (error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([self messageForFacebookError:error]);
      }
      return;
    }
    
    // Else, we were successful
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = [FBSession activeSession];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
      if (error) {
        if ([EvstCommon showUserError:error] && failureHandler) {
          failureHandler([self messageForFacebookError:error]);
        }
        return;
      }
      if (successHandler) {
        successHandler(result[@"data"]);
      }
    }];
  }];
}

+ (void)inviteFriendWithFacebookID:(NSString *)facebookID success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(facebookID, @"Facebook ID cannot be nil when trying to invite them via Facebook.");
  
    // Facebook invites cannot be done server side. We need to do them via the FB SDK.
  NSDictionary *params = @{@"message" : kLocaleInviteFacebookFriend,
                           @"to" : facebookID};

  [FBWebDialogs presentDialogModallyWithSession:[FBSession activeSession] dialog:@"apprequests"
                                     parameters:params
                                        handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                          if (error) {
                                            if ([EvstCommon showUserError:error] && failureHandler) {
                                              failureHandler([self messageForFacebookError:error]);
                                            }
                                            return;
                                          }
                                          
                                          if (successHandler) {
                                            successHandler();
                                          }
                                        }];
}
                                                   
#pragma mark - Convenience Methods
                                                   
+ (NSString *)messageForFacebookError:(NSError *)error {
  NSString *errorMsg;
  if (error.fberrorShouldNotifyUser) {
    errorMsg = error.fberrorUserMessage;
  } else {
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
      errorMsg = kLocaleLaunchSettingsAppForFacebook;
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
      // Handle session closures that happen outside of the app
      errorMsg = kLocaleCurrentFacebookSessionIsInvalid;
    } else {
      // Get more error information from the error
      NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
      errorMsg = [NSString stringWithFormat:kLocalePleaseRetryFacebookErrorFormat, [errorInformation objectForKey:@"message"]];
    }
  }
  // Clear the token associated with this error
  [FBSession.activeSession closeAndClearTokenInformation];
  
  return errorMsg;
}

@end
