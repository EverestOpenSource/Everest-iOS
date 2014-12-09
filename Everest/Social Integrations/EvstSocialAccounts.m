//
//  EvstSocialAccounts.m
//  Everest
//
//  Created by Rob Phillips on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstSocialAccounts.h"
#import "EvstSocialAccountsViewController.h"

@interface EvstSocialAccounts ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@end

@implementation EvstSocialAccounts

#pragma mark - Linking

+ (BOOL)userAccountIsLinked {
  ZAssert(NO, @"Subclasses should override the userAccountIsLinked method.");
  return NO;
}

#pragma mark - Multiple Account Selection

- (void)selectAccountWithTypeIdentifier:(NSString *)accountTypeIdentifier fromViewController:(UIViewController *)fromViewController options:(NSDictionary *)options success:(void (^)(ACAccount *account))successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler {
  BOOL isTwitter = [accountTypeIdentifier isEqualToString:ACAccountTypeIdentifierTwitter];
  
  // Ask for access to the iOS system accounts
  self.accountStore = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];
  __weak typeof(self) weakSelf = self;
  [self.accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (granted) {
        self.accounts = [weakSelf.accountStore accountsWithAccountType:(ACAccountType *)accountType];
        if (self.accounts.count == 0) {
          // Since no accounts are available in the device settings, let's default back to Facebook & Twitter's secondary login methods by falling through this method and calling success (this will typically launch Safari or maybe Facebook's native app to authenticate)
          if (successHandler) {
            successHandler(nil);
          }
        } else if (self.accounts.count == 1) {
          if (successHandler) {
            successHandler(self.accounts.firstObject);
          }
        } else {
          EvstSocialAccountsViewController *accountsVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstSocialAccountsViewController"];
          accountsVC.accounts = self.accounts;
          [accountsVC setDidChooseAccountHandler:successHandler];
          [accountsVC setDidCancelHandler:cancelHandler];
          UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:accountsVC];
          [fromViewController presentViewController:navVC animated:YES completion:nil];
        }
      } else {
        if ([error code] == ACErrorAccountNotFound) {
          // Since no accounts are available in the device settings, let's default back to Facebook & Twitter's secondary login methods by falling through this method and calling success (this will typically launch Safari or maybe Facebook's native app to authenticate)
          if (successHandler) {
            successHandler(nil);
          }
          return;
        }
        if ([EvstCommon showUserError:error] && failureHandler) {
          failureHandler(isTwitter ? kLocaleLaunchSettingsAppForTwitter : kLocaleLaunchSettingsAppForFacebook);
        }
      }
    });
  }];
}

#pragma mark - Permissions

+ (void)establishWritePermissionsFromViewController:(UIViewController *)fromViewController success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler cancel:(void (^)())cancelHandler {
  ZAssert(NO, @"Subclasses should override the establishWritePermissions method.");
}

#pragma mark - Sharing Filters

+ (NSString *)filteredSharingMessageForLifecycleMoments:(NSString *)message {
  if (!message) {
    return message;
  }
  
  // Don't share the lifecycle moment internal format
  NSString *filteredMessage = [message stringByReplacingOccurrencesOfString:kEvstStartedJourneyMomentType withString:kLocaleLifecycleStarted];
  filteredMessage = [filteredMessage stringByReplacingOccurrencesOfString:kEvstAccomplishedJourneyMomentType withString:kLocaleLifecycleAccomplished];
  filteredMessage = [filteredMessage stringByReplacingOccurrencesOfString:kEvstReopenedJourneyMomentType withString:kLocaleLifecycleReopened];
  return filteredMessage;
}

#pragma mark - Silent Sharing

+ (void)silentlyShareMessage:(NSString *)message withLink:(NSString *)link momentImage:(UIImage *)momentImage {
  ZAssert(NO, @"Subclasses should override the shareMessage: method.");
}

+ (NSString *)concatenateMessage:(NSString *)message withLink:(NSString *)link {
  ZAssert(NO, @"Subclasses should override the concatenateMessage:withLink: method.");
  return nil;
}

#pragma mark - Sharing via iOS Native Dialogs

+ (void)shareLink:(NSString *)link fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  ZAssert(NO, @"Subclasses should override the shareMessage: method.");
}

+ (void)shareMoment:(EverestMoment *)moment fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  ZAssert(NO, @"Subclasses should override the shareMessage: method.");
}

+ (void)shareJourney:(EverestJourney *)journey fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  ZAssert(NO, @"Subclasses should override the shareMessage: method.");
}

+ (void)shareMessage:(NSString *)message withLink:(NSString *)link onService:(NSString *)serviceType fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  [self shareMessage:message withLink:link imageURL:nil onService:serviceType fromViewController:fromViewController completion:completionHandler];
}

+ (void)shareMessage:(NSString *)message withLink:(NSString *)link imageURL:(NSString *)imageURL onService:(NSString *)serviceType fromViewController:(UIViewController *)fromViewController completion:(void (^)())completionHandler {
  ZAssert(link.length, @"Link cannot be nil or empty when trying to share on a social network.");
  
  // Note: If the user does not have any Facebook/Twitter accounts setup, iOS will display an error message asking them to
  // go into the Settings.app and configure one before they can share.  Otherwise, they can share by copying the link
  
  NSString *filteredMessage = [self filteredSharingMessageForLifecycleMoments:message];
  
  SLComposeViewController *shareSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
  if (![shareSheet setInitialText:filteredMessage]) {
    // Failing to set the text should very rarely happen, but if it does, let's just set the URL instead
    [shareSheet addURL:[NSURL URLWithString:link]];
  }
  [shareSheet addURL:[NSURL URLWithString:link]];
  
  if (imageURL) {
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
      if (image) {
        [shareSheet addImage:image];
      }
    }];
  }
  
  [shareSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
    if (completionHandler) {
      completionHandler();
    }
  }];
  
  [fromViewController presentViewController:shareSheet animated:YES completion:nil];
}

@end
