//
//  EvstAnalytics.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstAnalytics.h"
#import "Mixpanel.h"

static NSString *const kEvstAnalyticsUnknown = @"Unknown";

@interface EvstAnalytics ()
@property (nonatomic, strong) NSDate *sessionStart;
@end

@implementation EvstAnalytics

#pragma mark - Singleton

+ (instancetype)sharedAnalytics {
  static id sharedAnalytics = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedAnalytics = [[self alloc] init];
  });
  return sharedAnalytics;
}

#pragma mark - Identification 

+ (void)identifyUserAfterLogin {
  // Check if this was a Facebook sign up (e.g. if they were created <= 10 seconds ago)
  if (fabs(floor([[EvstAPIClient currentUser].createdAt timeIntervalSinceNow])) <= 10) {
    [self identifyUserAfterSignup];
  } else {
    [[Mixpanel sharedInstance] identify:[EvstAPIClient currentUserUUID]];
    [self setUserProfileData];
  }
}

+ (void)identifyUserAfterSignup {
  Mixpanel *mixpanel = [Mixpanel sharedInstance];
  [mixpanel createAlias:[EvstAPIClient currentUserUUID] forDistinctID:mixpanel.distinctId];
  [mixpanel identify:mixpanel.distinctId]; // Note: this absolutely has to be the Mixpanel generated distinctId or else the signup funnel breaks
  [self setUserProfileData];
}

+ (void)setUserProfileData {
  [[Mixpanel sharedInstance].people set:@{ @"$name" : [EvstAPIClient currentUser].fullName,
                                           @"$email" : [EvstAPIClient currentUser].email }];
}

#pragma mark - Event Tracking

+ (void)track:(NSString *)eventName {
  [[Mixpanel sharedInstance] track:eventName];
}

+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties {
  [[Mixpanel sharedInstance] track:eventName properties:properties];
}

#pragma mark - View Tracking

+ (void)trackView:(NSString *)eventName objectUUID:(NSString *)uuid {
  [self track:eventName properties:@{kEvstAnalyticsUUID : uuid ?: kEvstAnalyticsUnknown}];
}

#pragma mark - Onboarding

+ (void)trackActivation {
  [EvstAnalytics track:kEvstAnalyticsDidOnboardUser];
  [[Mixpanel sharedInstance].people set:@{ kEvstAnalyticsDidOnboardUser : @YES }];
}

#pragma mark - Launching

+ (void)trackAppLaunch {
  // Check if it was their first time launching
  static NSString *kEvstAnalyticsWasUsersFirstAppLaunchKey = @"Analytics Was Users First App Launch";
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kEvstAnalyticsWasUsersFirstAppLaunchKey] == NO) {
    if ([self userWasCreatedLessThan24hrsAgo]) {
      [self track:kEvstAnalyticsLaunchedAppForFirstTime];
      [[Mixpanel sharedInstance].people set:@{ kEvstAnalyticsLaunchedAppForFirstTime: @YES }];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstAnalyticsWasUsersFirstAppLaunchKey];
  }
}

#pragma mark - Session Tracking

+ (void)startSession {
  [EvstAnalytics sharedAnalytics].sessionStart = [NSDate date];
  [self track:kEvstAnalyticsSessionDidStart];
  [[Mixpanel sharedInstance].people increment:kEvstAnalyticsSessionCount by:@1];
}

+ (void)endSession {
  NSTimeInterval sessionLength = fabs([[EvstAnalytics sharedAnalytics].sessionStart timeIntervalSinceNow]);
  
  // Check if it was their first session ever
  static NSString *kEvstAnalyticsWasUsersFirstSessionKey = @"Analytics Was Users First Session";
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kEvstAnalyticsWasUsersFirstSessionKey] == NO) {
    if ([self userWasCreatedLessThan24hrsAgo]) {
      [self track:kEvstAnalyticsSessionDidEnd properties:@{kEvstAnalyticsLength : [NSNumber numberWithInteger:(NSInteger)ceil(sessionLength)], kEvstAnalyticsWasFirstSessionEver : [NSNumber numberWithBool:YES]}];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEvstAnalyticsWasUsersFirstSessionKey];
  } else {
    [self track:kEvstAnalyticsSessionDidEnd properties:@{kEvstAnalyticsLength : [NSNumber numberWithInteger:(NSInteger)ceil(sessionLength)]}];
  }

  [EvstAnalytics sharedAnalytics].sessionStart = nil;
}

+ (BOOL)userWasCreatedLessThan24hrsAgo {
  return fabs(floor([[EvstAPIClient currentUser].createdAt timeIntervalSinceNow])) <= (60 * 60 * 24);
}

#pragma mark - Notifications Handling

+ (void)trackPushNotificationWithUserInfo:(NSDictionary *)userInfo {
  if (userInfo) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [EvstAnalytics track:kEvstAnalyticsOpenedNotification properties:[self notificationPropertiesForUserInfo:userInfo]];
    });
  }
}

+ (void)trackOpenedNotificationWithMessage:(NSString *)message {
  if (message) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [EvstAnalytics track:kEvstAnalyticsOpenedNotification properties:[self notificationPropertiesForMessage:message]];
    });
  }
}

+ (NSDictionary *)notificationPropertiesForUserInfo:(NSDictionary *)userInfo {
  NSString *alertMessage = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"] ?: kEvstAnalyticsUnknown;
  return [self notificationPropertiesWithSource:kEvstAnalyticsPush destination:[self destinationForMessage:alertMessage]];
}

+ (NSDictionary *)notificationPropertiesForMessage:(NSString *)message {
  return [self notificationPropertiesWithSource:kEvstAnalyticsPanel destination:[self destinationForMessage:message]];
}

+ (NSDictionary *)notificationPropertiesWithSource:(NSString *)source destination:(NSString *)destination {
  return @{kEvstAnalyticsSource : source, kEvstAnalyticsDestination : destination};
}

+ (NSString *)destinationForMessage:(NSString *)message {
  // TODO: We need these to be localized to properly track it
  
  if ([message rangeOfString:kLocaleAnalyticsLiked].location != NSNotFound) {
    return kEvstAnalyticsLike;
  }
  
  if ([message rangeOfString:kLocaleAnalyticsCommented].location != NSNotFound) {
    return kEvstAnalyticsComment;
  }
  
  if ([message rangeOfString:kLocaleAnalyticsFollowing].location != NSNotFound) {
    return kEvstAnalyticsFollower;
  }
  
  if ([message rangeOfString:kLocaleAnalyticsAccomplished].location != NSNotFound) {
    return kEvstAnalyticsAccomplished;
  }
  
  if ([message rangeOfString:kLocaleAnalyticsMilestone].location != NSNotFound) {
    return kEvstAnalyticsMilestone;
  }
  
  return kEvstAnalyticsUnknown;
}

#pragma mark - Moment & Journey Creation

+ (void)trackCreatedMoment:(EverestMoment *)moment fromView:(NSString *)fromView {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *view = fromView ?: kEvstAnalyticsUnknown;
    if ([view isEqualToString:@"EvstHomeViewController"]) {
      view = kEvstAnalyticsHome;
    } else if ([view isEqualToString:@"EvstUserViewController"]) {
      view = kEvstAnalyticsProfile;
    } else if ([view isEqualToString:@"EvstJourneyViewController"]) {
      view = kEvstAnalyticsJourney;
    }
    
    NSString *has = kEvstAnalyticsUnknown;
    if (moment.imageURL && moment.name && moment.name.length != 0) {
      has = kEvstAnalyticsTextAndPhoto;
    } else if (moment.imageURL) {
      has = kEvstAnalyticsPhotoOnly;
    } else if (moment.name) {
      has = kEvstAnalyticsTextOnly;
    }
    
    [self track:kEvstAnalyticsCreatedMoment properties:@{kEvstAnalyticsView : view,
                                                         kEvstAnalyticsHas : has,
                                                         kEvstAnalyticsProminence : moment.importance }];
  });
}

+ (void)trackCreatedJourney:(EverestJourney *)journey withImage:(BOOL)withImage fromView:(NSString *)fromView {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *view = fromView ?: kEvstAnalyticsUnknown;
    if ([view isEqualToString:@"EvstMenuViewController"]) {
      view = kEvstAnalyticsMenu;
    } else if ([view isEqualToString:@"EvstJourneysListViewController"]) {
      view = kEvstAnalyticsJourneyList;
    } else if ([view isEqualToString:@"EvstMomentFormViewController"]) {
      view = kEvstAnalyticsAddMomentForm;
    } else if ([view isEqualToString:@"EvstSelectJourneyViewController"]) {
      view = kEvstAnalyticsSelectJourneyList;
    }
    
    [self track:kEvstAnalyticsCreatedJourney properties:@{kEvstAnalyticsView : view,
                                                          kEvstAnalyticsType : journey.isPrivate ? kEvstAnalyticsPrivate : kEvstAnalyticsPublic,
                                                          kEvstAnalyticsHasCoverPhoto : withImage ? kEvstAnalyticsTrue : kEvstAnalyticsFalse}];
    
  });
}

#pragma mark - Photos

+ (void)trackAddPhotoFromSource:(NSString *)source withDestination:(NSString *)destination {
  [self track:kEvstAnalyticsAddedImage properties:@{kEvstAnalyticsSource : source ?: kEvstAnalyticsUnknown,
                                                    kEvstAnalyticsDestination : destination ?: kEvstAnalyticsUnknown}];
}

#pragma mark - Sharing

+ (void)trackShareFromSource:(NSString *)source withDestination:(NSString *)destination type:(NSString *)type urlString:(NSString *)urlString {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *zeSource = source ?: kEvstAnalyticsUnknown;
    if ([zeSource isEqualToString:@"EvstDiscoverViewController"]) {
      zeSource = kEvstAnalyticsDiscover;
    } else if ([zeSource isEqualToString:@"EvstHomeViewController"]) {
      zeSource = kEvstAnalyticsHome;
    } else if ([zeSource isEqualToString:@"EvstJourneyViewController"]) {
      zeSource = kEvstAnalyticsJourney;
    } else if ([zeSource isEqualToString:@"EvstUserViewController"]) {
      zeSource = kEvstAnalyticsProfile;
    } else if ([zeSource isEqualToString:@"EvstMomentSearchViewController"]) {
      zeSource = kEvstAnalyticsDiscoverSearch;
    }
    
    [self track:kEvstAnalyticsDidShare properties:@{kEvstAnalyticsSource : zeSource,
                                                    kEvstAnalyticsDestination : destination ?: kEvstAnalyticsUnknown,
                                                    kEvstAnalyticsType : type ?: kEvstAnalyticsUnknown,
                                                    kEvstAnalyticsURL : urlString ?: kEvstAnalyticsUnknown}];
  });
}

+ (void)trackShareFromSource:(NSString *)source withDestination:(NSString *)destination type:(NSString *)type {
  [self trackShareFromSource:source withDestination:destination type:type urlString:nil];
}

@end
