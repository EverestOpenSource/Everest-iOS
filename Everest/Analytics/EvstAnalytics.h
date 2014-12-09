//
//  EvstAnalytics.h
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>
#import "EvstAnalyticsEvents.h"
#import "EvstAnalyticsProperties.h"

@interface EvstAnalytics : NSObject

#pragma mark - Identification

+ (void)identifyUserAfterLogin;
+ (void)identifyUserAfterSignup;

#pragma mark - Event Tracking

+ (void)track:(NSString *)eventName;
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties;

#pragma mark - Onboarding

+ (void)trackActivation;

#pragma mark - Launching

+ (void)trackAppLaunch;

#pragma mark - Session Tracking

+ (void)startSession;
+ (void)endSession;

#pragma mark - View Tracking

+ (void)trackView:(NSString *)eventName objectUUID:(NSString *)uuid;

#pragma mark - Notifications

+ (void)trackPushNotificationWithUserInfo:(NSDictionary *)userInfo;
+ (void)trackOpenedNotificationWithMessage:(NSString *)message;

#pragma mark - Moment & Journey Creation

+ (void)trackCreatedMoment:(EverestMoment *)moment fromView:(NSString *)fromView;
+ (void)trackCreatedJourney:(EverestJourney *)journey withImage:(BOOL)withImage fromView:(NSString *)fromView;

#pragma mark - Photos

+ (void)trackAddPhotoFromSource:(NSString *)source withDestination:(NSString *)destination;

#pragma mark - Sharing

+ (void)trackShareFromSource:(NSString *)source withDestination:(NSString *)destination type:(NSString *)type;
+ (void)trackShareFromSource:(NSString *)source withDestination:(NSString *)destination type:(NSString *)type urlString:(NSString *)urlString;

@end
