//
//  EvstTwitter.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSocialAccounts.h"

@interface EvstTwitter : EvstSocialAccounts

#pragma mark - Linking / Unlinking

+ (void)selectTwitterAccountAndLinkWithEverestFromViewController:(UIViewController *)fromViewController
                                                         success:(void (^)(ACAccount *twitterAccount))successHandler
                                                         failure:(void (^)(NSString *errorMsg))failureHandler
                                                          cancel:(void (^)())cancelHandler
                                          failSilentlyForLinking:(BOOL)failSilentlyForLinking;
+ (void)unlinkWithTwitterWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
