//
//  EvstSocialIntegrationsEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSocialIntegrationsEndPoint.h"

@implementation EvstSocialIntegrationsEndPoint

#pragma mark - Facebook

+ (void)linkFacebookWithFacebookID:(NSString *)facebookID authToken:(NSString *)authToken success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSDictionary *params = @{kJsonRequestFacebookKey : @{kJsonRequestFacebookIDKey : facebookID, kJsonRequestFacebookAccessTokenKey : authToken}};
  
  [[EvstAPIClient objectManager].HTTPClient postPath:kEndPointLinkUnlinkFacebook parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)unlinkFacebookWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager].HTTPClient deletePath:kEndPointLinkUnlinkFacebook parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - Twitter

+ (void)linkTwitterWithTwitterUsername:(NSString *)username authToken:(NSString *)authToken secretToken:(NSString *)secretToken success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  NSDictionary *params = @{kJsonRequestTwitterKey : @{kJsonTwitterUsername : username,
                                                      kJsonTwitterAccessToken : authToken,
                                                      kJsonTwitterSecretToken : secretToken}};
  [[EvstAPIClient objectManager].HTTPClient postPath:kEndPointLinkUnlinkTwitter parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    if (successHandler) {
      successHandler();
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)unlinkTwitterWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [[EvstAPIClient objectManager].HTTPClient deletePath:kEndPointLinkUnlinkTwitter parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
