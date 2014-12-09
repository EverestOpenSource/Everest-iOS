//
//  EvstTwitter.m
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <Accounts/Accounts.h>
#import "EvstTwitter.h"
#import "AFOAuth1Client.h"
#import "EvstSocialIntegrationsEndPoint.h"
#import "EvstAuthStore.h"

static NSString *const kEvstTwitterBaseURL = @"https://api.twitter.com";
static NSString *const kEvstTwitterXAuthModeKey = @"x_auth_mode";
static NSString *const kEvstTwitterXAuthReverseParams = @"x_reverse_auth_parameters";
static NSString *const kEvstTwitterXAuthReverseTarget = @"x_reverse_auth_target";
static NSString *const kEvstTwitterReverseAuthKey = @"reverse_auth";
static NSString *const kEvstTwitterRequestTokenPath = @"/oauth/request_token";
static NSString *const kEvstTwitterAuthorizationPath = @"/oauth/authorize";
static NSString *const kEvstTwitterAccessTokenPath = @"/oauth/access_token";
static NSString *const kEvstTwitterVerifyCredentialsPath = @"/1.1/account/verify_credentials.json";
static NSString *const kEvstTwitterUpdateStatusPath = @"/1.1/statuses/update.json";
static NSString *const kEvstTwitterUpdateStatusWithMediaPath = @"/1.1/statuses/update_with_media.json";
static NSString *const kEvstTwitterHelpConfigurationPath = @"/1.1/help/configuration";
static NSUInteger const kEvstTwitterDefaultMaximumLinkLength = 30; // t.co link length in case help/configuration is down

typedef void(^TwitterKeyPairHandler)(NSString *oauthToken, NSString *oauthSecret);

@interface EvstTwitter ()
@property (nonatomic, strong) AFOAuth1Client *twitterClient;
@property (nonatomic, strong) NSString *lastUsernameFound;
@property (nonatomic, assign) NSUInteger maximumTwitterLinkLength;
@end

@implementation EvstTwitter

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
    // Setup the Twitter OAuth1 client
    self.twitterClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:kEvstTwitterBaseURL]
                                                             key:kEvstTwitterConsumerKey
                                                          secret:kEvstTwitterSecretKey];
    
    // Restore any previously stored access token
    if ([EvstAuthStore sharedStore].twitterAccessToken) {
      self.twitterClient.accessToken = [EvstAuthStore sharedStore].twitterAccessToken;
    }
    
    // Query Twitter for what the current maximum link length is for t.co links
    [self setupMaximumTwitterLinkLength];
  }
  return self;
}

// Checks Twitter's help/configuration path to see what the current max length is for their t.co links since it changes over time
- (void)setupMaximumTwitterLinkLength {
  NSURLRequest *request = [self.twitterClient requestWithMethod:@"POST" path:kEvstTwitterHelpConfigurationPath parameters:nil];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    NSUInteger maxLinkLength = [[JSON valueForKey:@"short_url_length"] integerValue];
    self.maximumTwitterLinkLength = (maxLinkLength == 0) ? kEvstTwitterDefaultMaximumLinkLength : maxLinkLength;
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    // Setup a safe default for now
    self.maximumTwitterLinkLength = kEvstTwitterDefaultMaximumLinkLength;
  }];
  [operation start];
}

#pragma mark - Linking / Unlinking

+ (BOOL)userAccountIsLinked {
  return [self.sharedInstance twitterClient].accessToken != nil;
}

+ (void)selectTwitterAccountAndLinkWithEverestFromViewController:(UIViewController *)fromViewController
                                                         success:(void (^)(ACAccount *twitterAccount))successHandler
                                                         failure:(void (^)(NSString *errorMsg))failureHandler
                                                          cancel:(void (^)())cancelHandler
                                          failSilentlyForLinking:(BOOL)failSilentlyForLinking {
  [self.sharedInstance selectAccountWithTypeIdentifier:ACAccountTypeIdentifierTwitter fromViewController:fromViewController options:nil success:^(ACAccount *account) {
    [self.sharedInstance fetchOAuthTokenForTwitterAccount:account success:^(NSString *oauthToken, NSString *oauthSecret) {
      NSString *username = account.username ?: [[self sharedInstance] lastUsernameFound];
      if (failSilentlyForLinking) {
        [self linkWithTwitterUsername:username authToken:oauthToken secretToken:oauthSecret success:nil failure:nil];
        if (successHandler) {
          successHandler(account);
        }
        return;
      }
      
      // From this point on, success and failure is based on Everest's response
      [self linkWithTwitterUsername:username authToken:oauthToken secretToken:oauthSecret success:^{
        if (successHandler) {
          successHandler(account);
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

+ (void)linkWithTwitterUsername:(NSString *)username authToken:(NSString *)authToken secretToken:(NSString *)secretToken success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [EvstSocialIntegrationsEndPoint linkTwitterWithTwitterUsername:username authToken:authToken secretToken:secretToken success:^{
    if (successHandler) {
      successHandler();
    }
  } failure:^(NSString *errorMsg) {
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  }];
}

+ (void)unlinkWithTwitterWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [EvstSocialIntegrationsEndPoint unlinkTwitterWithSuccess:^{
    // Clear out the Twitter access token
    [self.sharedInstance twitterClient].accessToken = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstTwitterAccessTokenDidChangeNotification object:nil];
    
    if (successHandler) {
      successHandler();
    }
  } failure:^(NSString *errorMsg) {
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  }];
}

#pragma mark - Permissions

- (void)fetchOAuthTokenForTwitterAccount:(ACAccount *)account success:(TwitterKeyPairHandler)successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  void (^fallbackToSafari)() = ^void() {
    [self authenticateUsingSafariWithSuccess:^(NSString *oauthToken, NSString *oauthSecret) {
      if (successHandler) {
        successHandler(oauthToken, oauthSecret);
      }
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    }];
  };
  
  // Check if we have already retreived an access token for this username
  if (account && [account.username isEqualToString:self.lastUsernameFound] && self.twitterClient.accessToken) {
    if (successHandler) {
      successHandler(self.twitterClient.accessToken.key, self.twitterClient.accessToken.secret);
    }
  } else if (account) {
    // Since this could take a while because Twitter is super slow most of the time, let's show a HUD
    [SVProgressHUD showWithStatus:kLocaleAuthorizing maskType:SVProgressHUDMaskTypeClear];
    
    // Try to get the tokens from their iOS native account by using reverse auth
    [self performReverseAuthForAccount:account success:^(NSString *oauthToken, NSString *oauthSecret) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
        self.lastUsernameFound = account.username;
        self.twitterClient.accessToken = [[AFOAuth1Token alloc] initWithKey:oauthToken secret:oauthSecret session:nil expiration:nil renewable:NO];
        if (successHandler) {
          successHandler(oauthToken, oauthSecret);
        }
      });
    } failure:^(NSString *errorMsg) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        fallbackToSafari();
      });
    }];
  } else {
    // Fall back to using non-native (Safari based) auth
    fallbackToSafari();
  }
}

- (void)authenticateUsingSafariWithSuccess:(TwitterKeyPairHandler)successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSURL *callbackURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://success", kEvstURLSchemeTwitter]];
  [self.twitterClient authorizeUsingOAuthWithRequestTokenPath:kEvstTwitterRequestTokenPath userAuthorizationPath:kEvstTwitterAuthorizationPath callbackURL:callbackURL accessTokenPath:kEvstTwitterAccessTokenPath accessMethod:@"POST" scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
    // We don't care if they authenticate a different username than they originally selected
    NSString *authenticatedUsername = [accessToken.userInfo objectForKey:@"screen_name"];
    self.lastUsernameFound = authenticatedUsername;
    if (successHandler) {
      successHandler(accessToken.key, accessToken.secret);
    }
    // Post the new access token so it gets saved properly in the EvstAuthStore for later user
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstTwitterAccessTokenDidChangeNotification object:accessToken];
  } failure:^(NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      // This can happen if the user cancels or if they had an issue authenticating, such as the Twitter site being down
      DLog(@"Error authenticating with Twitter: %@", error);
      failureHandler(kLocaleTwitterAuthenticationError);
    }
  }];
}

+ (void)verifyCredentialsWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  // Note: the requestWithMethod: within the Twitter Client is customized to include OAuth headers in the request
  NSURLRequest *request = [[self.sharedInstance twitterClient] requestWithMethod:@"GET" path:kEvstTwitterVerifyCredentialsPath parameters:nil];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:response error:error]);
    }
  }];
  [operation start];
}

+ (void)establishWritePermissionsFromViewController:(UIViewController *)fromViewController success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler {
  if ([self userAccountIsLinked]) {
    [self verifyCredentialsWithSuccess:successHandler failure:failureHandler];
  } else {
    [self selectTwitterAccountAndLinkWithEverestFromViewController:fromViewController success:successHandler failure:failureHandler cancel:cancelHandler failSilentlyForLinking:YES];
  }
}

#pragma mark - Reverse Auth

// Note: The following was adapted from: https://github.com/seancook/TWReverseAuthExample

/*!
 Performs reverse auth for the given account in order to exchange the iOS token for a verified Twitter access/secret token pair
 \param account The @c ACAccount for which you wish to exchange tokens after being granted access by the user
 */
- (void)performReverseAuthForAccount:(ACAccount *)account success:(TwitterKeyPairHandler)successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSParameterAssert(account);
  
#ifdef TESTING
  successHandler(@"oauth token", @"oauth secret token");
  return;
#endif
  
  [self getReverseAuthHeadersWithSuccess:^(NSString *signedReverseAuthSignature) {
    [self exchangeTokensForAccount:account signature:signedReverseAuthSignature success:^(id responseData) {
      NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
      NSArray *components = [responseString componentsSeparatedByString:@"&"];
      NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:components.count];
      for (NSString *keyWithValueSeparatedByEqualSign in components) {
        NSArray *keyWithValue = [keyWithValueSeparatedByEqualSign componentsSeparatedByString:@"="];
        [response setValue:keyWithValue.lastObject forKeyPath:keyWithValue.firstObject];
      }
      NSString *oauthToken = [response objectForKey:@"oauth_token"];
      NSString *oauthSecretToken = [response objectForKey:@"oauth_token_secret"];
      if (successHandler) {
        successHandler(oauthToken, oauthSecretToken);
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
}

/*!
 Step 1: In this step, we sign and send a request to Twitter to obtain an authorization header
 */
- (void)getReverseAuthHeadersWithSuccess:(void (^)(NSString *signedReverseAuthSignature))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSDictionary *parameters = @{kEvstTwitterXAuthModeKey : kEvstTwitterReverseAuthKey};
  NSURLRequest *request = [self.twitterClient requestWithMethod:@"POST" path:kEvstTwitterRequestTokenPath parameters:parameters];
  AFHTTPRequestOperation *operation = [self.twitterClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
  [operation start];
}

/*! 
 Step 2: In this step, we send our signed authorization header to Twitter in a request that is signed by iOS
 \param account The @c ACAccount for which you wish to exchange tokens
 \param signedReverseAuthSignature The authorization header returned from Step 1
 */
- (void)exchangeTokensForAccount:(ACAccount *)account signature:(NSString *)signedReverseAuthSignature success:(void (^)(id responseData))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSParameterAssert(account);
  NSParameterAssert(signedReverseAuthSignature);
  
  NSDictionary *parameters = @{kEvstTwitterXAuthReverseParams : signedReverseAuthSignature,
                               kEvstTwitterXAuthReverseTarget : kEvstTwitterConsumerKey};
  NSString *absolutePath = [NSString stringWithFormat:@"%@%@", kEvstTwitterBaseURL, kEvstTwitterAccessTokenPath];
  SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:absolutePath] parameters:parameters];
  slRequest.account = account;
  [slRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    if (error && [EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:urlResponse error:error]);
      return;
    }
    successHandler(responseData);
  }];
}

#pragma mark - Silent Sharing

// Created using this as a guide:
// https://dev.twitter.com/docs/tco-link-wrapper/faq#How_do_I_calculate_if_a_Tweet_with_a_link_is_going_to_be_over_140_characters_or_not
+ (NSString *)concatenateMessage:(NSString *)message withLink:(NSString *)link {
  NSUInteger twitterCharLength = 140;
  NSUInteger messageLength = message.length;
  NSUInteger webURLLength = [self.sharedInstance maximumTwitterLinkLength]; // t.co links are variable length
  NSString *ellipsis = @"…";
  NSUInteger whitespaceLength = 1;
  NSUInteger ellipsisLength = ellipsis.length;
  NSUInteger maxTweetLength = twitterCharLength - whitespaceLength - webURLLength;
  
  NSString *truncatedMessage;
  if (messageLength > maxTweetLength) {
    NSUInteger truncatedTweetLength = maxTweetLength - ellipsisLength - whitespaceLength;
    truncatedMessage = [[message substringToIndex:truncatedTweetLength] stringByAppendingString:ellipsis];
  } else {
    truncatedMessage = message;
  }
  truncatedMessage = (truncatedMessage.length == 0) ? link : [truncatedMessage stringByAppendingString:[NSString stringWithFormat:@" %@", link]];
  
  ZAssert(truncatedMessage.length < twitterCharLength, @"The truncated message is greater than Twitter's allowable tweet length.");
  return truncatedMessage;
}

+ (void)silentlyShareMessage:(NSString *)message withLink:(NSString *)link momentImage:(UIImage *)momentImage {
  ZAssert(message, @"Message cannot be nil when trying to share on Twitter.");

  NSString *filteredMessage = [self filteredSharingMessageForLifecycleMoments:message];
  
  // Per design, we only share plain text status updates since Twitter forces you to include links to pic.twitter.com for any photo uploads so it results in two links in the status update
  NSURLRequest *request = [[self.sharedInstance twitterClient] requestWithMethod:@"POST" path:kEvstTwitterUpdateStatusPath parameters:@{@"status" : [self concatenateMessage:filteredMessage withLink:link]}];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    // Tweet was successful
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    DLog(@"Error silently sharing tweet: %@", error.localizedDescription);
  }];
  [operation start];
}

#pragma mark - Sharing via iOS Native Dialogs

+ (void)shareLink:(NSString *)link fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:nil withLink:link onService:SLServiceTypeTwitter fromViewController:fromViewController completion:completionHandler];
}

+ (void)shareMoment:(EverestMoment *)moment fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:moment.name withLink:moment.webURL onService:SLServiceTypeTwitter fromViewController:fromViewController completion:completionHandler];
}

+ (void)shareJourney:(EverestJourney *)journey fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:journey.name withLink:journey.webURL onService:SLServiceTypeTwitter fromViewController:fromViewController completion:completionHandler];
}

@end
