//
//  EvstMockManager.m
//  Everest
//
//  Created by Chris Cornelis on 01/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Accounts/Accounts.h>
#import "EvstMockManager.h"
#import "EvstMockBase.h"
#import "FBTestSession.h"
#import "EvstMockSignUp.h"
#import "EvstMockLogin.h"
#import "EvstMockHome.h"
#import "EvstMockDiscover.h"
#import "EvstMockDiscoverSearch.h"
#import "EvstMockUserRecentActivity.h"
#import "EvstMockUserPatch.h"
#import "EvstMockUserGet.h"
#import "EvstMockUserPut.h"
#import "EvstMockUserFollows.h"
#import "EvstMockUserUnfollow.h"
#import "EvstMockUserFollow.h"
#import "EvstMockJourneyList.h"
#import "EvstMockJourneyCreate.h"
#import "EvstMockJourneyGet.h"
#import "EvstMockJourneyMomentsList.h"
#import "EvstMockJourneyPut.h"
#import "EvstMockMomentCreate.h"
#import "EvstMockMomentPatch.h"
#import "EvstMockMomentLike.h"
#import "EvstMockCommentsList.h"
#import "EvstMockCommentCreate.h"
#import "EvstMockHomeUserSearch.h"
#import "EvstMockMomentDelete.h"
#import "EvstMockJourneyDelete.h"
#import "EvstMockNotificationsGet.h"
#import "EvstMockCommentDelete.h"
#import "EvstMockSocialLinkUnlink.h"
#import "EvstMockLogout.h"
#import "EvstMockUserResetPassword.h"
#import "EvstMockNotificationsCountGet.h"
#import "EvstMockSuggestedUsersGet.h"
#import "EvstMockEverestTeamGet.h"
#import "EvstMockDiscoverCategoriesIndex.h"
#import "EvstMockTagSearch.h"
#import "EvstMockLikersList.h"

static FBTestSession *fbTestSession;
CGFloat const kEvstTestMockItemRemovalDelay = 1.0;

@interface EvstMockManager()
@property (nonatomic, strong) NSMutableArray *mockItems;
@end

@implementation EvstMockManager

#pragma mark - Request & Response

- (BOOL)shouldMockRequest:(NSURLRequest *)request {
  // Iterate over all of the Mock managed items to check if one of them returns yes
  @synchronized(self.mockItems) {
    for (EvstMockBase *mockItem in [self.mockItems reverseObjectEnumerator]) { // Go through the list in reverse order, since the last added mocks should be used first
      if ([mockItem isMockForRequest:request]) {
        return YES;
      }
    }
  }
  return NO;
}

- (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request {
  if (self.simulateNoInternetConnection) {
    // When offline, generate an error response
    return [EvstMockBase errorResponseWithMessage:kLocaleNoInternetConnection];
  }
  
  @synchronized(self.mockItems) {
    for (EvstMockBase *mockItem in [self.mockItems reverseObjectEnumerator]) { // Go through the list in reverse order, since the last added mocks should be used first
      if ([mockItem isMockForRequest:request]) {
        OHHTTPStubsResponse *mockResponse = mockItem.response;
        // When a mock response is used, remove the mock item. However the removal requires a delay because in certain cases RestKit gets the response multiple times.
        // A separate mock should be created for each expected server request.
        [self.mockItems performSelector:@selector(removeObject:) withObject:mockItem afterDelay:kEvstTestMockItemRemovalDelay];
        return mockResponse;
      }
    }
  }
  ZAssert(false, @"A test programming error occurred. A request is mocked, but there is no mock item available that can provide a response.");
  return nil;
}

#pragma mark - Add mock items

- (void)addObject:(id<EvstMockItem>)object {
  if (!self.mockItems) {
    [self setMockItems:[NSMutableArray array]];
  }
  @synchronized(self.mockItems) {
    [self.mockItems addObject:object];
    
    // Add notifications count here since it happens so often
    BOOL hasMockForNotificationsCount = NO;
    for (id mockItem in self.mockItems) {
      hasMockForNotificationsCount = [mockItem isKindOfClass:[EvstMockNotificationsCountGet class]];
    }
    if (hasMockForNotificationsCount == NO) {
      EvstMockNotificationsCountGet *countMock = [[EvstMockNotificationsCountGet alloc] initWithOptions:0];
      countMock.optional = YES;
      [self.mockItems addObject:countMock];
    }
  }
}

- (void)addObjects:(NSArray *)objects {
  for (id<EvstMockItem> object in objects) {
    [self addObject:object];
  }
}

#pragma mark - General

- (BOOL)hasRequiredMocks {
  @synchronized(self.mockItems) {
    for (EvstMockBase *object in self.mockItems) {
      if (![object optional]) {
        return YES;
      }
    }
  }
  return NO;
}

- (void)printAll {
  @synchronized(self.mockItems) {
    NSLog(@"***** the mock items *****");
    for (EvstMockBase *mockItem in self.mockItems) {
      NSLog(@"%@ - %@ - %@ - %@", mockItem.optional ? @"OPTIONAL" : @"REQUIRED", [[mockItem class] description], mockItem.httpMethod, mockItem.requestURLString);
    }
    NSLog(@"**************************");
  }
}

#pragma mark - Social Link / Unlink

- (void)addMocksLinkingUnlinkingSocialNetworkFromOption:(EvstMockSocialLinkOptions)option {
  EvstMockSocialLinkUnlink *socialMock = [[EvstMockSocialLinkUnlink alloc] initWithOptions:option];
  [self addObject:socialMock];
}

- (void)addMocksForLinkingFacebook {
  [self addMocksLinkingUnlinkingSocialNetworkFromOption:kEvstMockLinkFacebookOption];
}

- (void)addMocksForUnlinkingFacebook {
  [self addMocksLinkingUnlinkingSocialNetworkFromOption:kEvstMockUnlinkFacebookOption];
}

- (void)addMocksForLinkingTwitter {
  [self addMocksLinkingUnlinkingSocialNetworkFromOption:kEvstMockLinkTwitterOption];
}

- (void)addMocksForUnlinkingTwitter {
  [self addMocksLinkingUnlinkingSocialNetworkFromOption:kEvstMockUnlinkTwitterOption];
}

#pragma mark - Login, Logout, Signup

- (void)addMocksForLogin {
  EvstMockLogin *loginMock = [[EvstMockLogin alloc] initWithOptions:kEvstMockSignInOptionEmail];
  [self addObject:loginMock];
  [self addMocksForHomeWithOptions:EvstMockOffsetForPage1];
  [self addMocksForUserGet:kEvstTestUserFullName optional:YES];
}

- (void)addMocksForLogout {
  EvstMockLogout *logoutMock = [[EvstMockLogout alloc] initWithOptions:0];
  [self addObject:logoutMock];
}

- (void)addMocksForSignInWithFacebook {
  EvstMockLogin *loginMock = [[EvstMockLogin alloc] initWithOptions:kEvstMockSignInOptionFacebook];
  [self addObject:loginMock];
  [self addMocksForHomeWithOptions:EvstMockOffsetForPage1 optional:YES];
}

- (void)addMocksForSignUpWithOptions:(NSUInteger)options {
  [self addMocksForSignUpWithOptions:options mockingError:NO];
}

- (void)addMocksForSignUpWithOptions:(NSUInteger)options mockingError:(BOOL)mockingError {
  EvstMockSignUp *signUpMock = [[EvstMockSignUp alloc] initWithOptions:options];
  signUpMock.mockingError = mockingError;
  [self addObject:signUpMock];
  [self addMocksForHomeWithOptions:EvstMockOffsetForPage1];
}

#pragma mark - Home 

- (void)addMocksForHomeWithOptions:(NSUInteger)options {
  [self addMocksForHomeWithOptions:options optional:NO];
}

- (void)addMocksForHomeWithOptions:(NSUInteger)options optional:(BOOL)optional {
  EvstMockHome *homeMock = [[EvstMockHome alloc] initWithOptions:options];
  homeMock.optional = optional;
  [self addObject:homeMock];
  
  [self addMocksForNotificationsCountGet];
}

#pragma mark - Journeys

- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional {
  [self addMocksForJourneyGetForJourneyNamed:journeyName forOtherUser:NO optional:optional];
}

- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName isJourneyPrivate:(BOOL)isJourneyPrivate optional:(BOOL)optional {
  [self addMocksForJourneyGetForJourneyNamed:journeyName forOtherUser:NO isJourneyPrivate:isJourneyPrivate optional:optional];
}

- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName forOtherUser:(BOOL)forOtherUser optional:(BOOL)optional {
  [self addMocksForJourneyGetForJourneyNamed:journeyName forOtherUser:forOtherUser isJourneyPrivate:NO optional:optional];
}

- (void)addMocksForJourneyGetForJourneyNamed:(NSString *)journeyName forOtherUser:(BOOL)forOtherUser isJourneyPrivate:(BOOL)isJourneyPrivate optional:(BOOL)optional {
  EvstMockJourneyGet *journeyGet = [[EvstMockJourneyGet alloc] initWithOptions:0];
  journeyGet.journeyName = journeyName;
  journeyGet.optional = optional;
  journeyGet.isOtherUser = forOtherUser;
  journeyGet.isJourneyPrivate = isJourneyPrivate;
  [self addObject:journeyGet];
}

- (void)addMocksForJourneyCreation:(NSString *)journeyName {
  [self addMocksForJourneyCreation:journeyName coverPhoto:nil];
}

- (void)addMocksForJourneyCreation:(NSString *)journeyName coverPhoto:(UIImage *)coverPhoto {
  EvstMockJourneyCreate *journeyCreateMock = [[EvstMockJourneyCreate alloc] initWithOptions:0];
  journeyCreateMock.journeyName = journeyName;
  journeyCreateMock.coverPhoto = coverPhoto;
  [self addObject:journeyCreateMock];
}

- (void)addMocksForDeletingJourneyWithUUID:(NSString *)uuid {
  EvstMockJourneyDelete *journeyDeleteMock = [[EvstMockJourneyDelete alloc] initWithOptions:0];
  [journeyDeleteMock mockJourneyDeleteWithUUID:uuid];
  [self addObject:journeyDeleteMock];
}

- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName {
  [self addMocksForJourneyUpdateForJourneyNamed:journeyName order:0];
}

- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName order:(NSUInteger)order {
  EvstMockJourneyPut *journeyPutMock = [[EvstMockJourneyPut alloc] initWithOptions:0];
  journeyPutMock.journeyName = journeyName;
  journeyPutMock.order = order;
  [self addObject:journeyPutMock];
}

- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForJourneyUpdateForJourneyNamed:journeyName options:options isJourneyPrivate:NO];
}

- (void)addMocksForJourneyUpdateForJourneyNamed:(NSString *)journeyName options:(NSUInteger)options isJourneyPrivate:(BOOL)isJourneyPrivate {
  EvstMockJourneyPut *journeyPutMock = [[EvstMockJourneyPut alloc] initWithOptions:options];
  journeyPutMock.journeyName = journeyName;
  journeyPutMock.isJourneyPrivate = isJourneyPrivate;
  [self addObject:journeyPutMock];
}

- (void)addMocksForJourneyListForUserUUID:(NSString *)uuid limit:(NSUInteger)limit excludeAccomplished:(BOOL)excludeAccomplished options:(NSUInteger)options optional:(BOOL)optional {
  EvstMockJourneyList *journeyList = [[EvstMockJourneyList alloc] initWithOptions:options];
  [journeyList mockForUserUUID:uuid limit:limit excludeAccomplished:excludeAccomplished];
  journeyList.optional = optional;
  [self addObject:journeyList];
}

- (void)addMocksForFullJourneyListForUserUUID:(NSString *)uuid options:(NSUInteger)options optional:(BOOL)optional {
  [self addMocksForJourneyListForUserUUID:uuid limit:kEvstJourneysListPagingOffset excludeAccomplished:NO options:options optional:optional];
}

#pragma mark - Comments

- (void)addMocksForCommentListWithMomentNamed:(NSString *)momentName offset:(NSUInteger)offset limit:(NSUInteger)limit {
  EvstMockCommentsList *commentsListMock = [[EvstMockCommentsList alloc] initWithOptions:0];
  [commentsListMock mockWithMomentNamed:momentName offset:offset limit:limit];
  commentsListMock.optional = YES;
  [self addObject:commentsListMock];
}

- (void)addMocksForCommentCreation:(NSString *)commentText momentName:(NSString *)momentName {
  EvstMockCommentCreate *createCommentMock = [[EvstMockCommentCreate alloc] initWithOptions:0];
  createCommentMock.momentName = momentName;
  createCommentMock.commentText = commentText;
  [self addObject:createCommentMock];
}

- (void)addMocksForDeletingCommentWithUUID:(NSString *)uuid {
  EvstMockCommentDelete *deleteCommentMock = [[EvstMockCommentDelete alloc] initWithOptions:0];
  [deleteCommentMock mockCommentDeleteWithUUID:uuid];
  [self addObject:deleteCommentMock];
}

#pragma mark - Moments

- (void)addMocksForPostMomentWithText:(NSString *)momentText tags:(NSSet *)tags journeyName:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForPostMomentWithText:momentText tags:tags photo:nil throwbackDate:nil journeyName:journeyName options:options];
}

- (void)addMocksForPostMomentWithText:(NSString *)momentText journeyName:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForPostMomentWithText:momentText photo:nil journeyName:journeyName options:options];
}

- (void)addMocksForPostMomentWithPhoto:(UIImage *)momentPhoto journeyName:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForPostMomentWithText:nil photo:momentPhoto journeyName:journeyName options:options];
}

- (void)addMocksForPostMomentWithText:(NSString *)momentText photo:(UIImage *)momentPhoto journeyName:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForPostMomentWithText:momentText photo:momentPhoto throwbackDate:nil journeyName:journeyName options:options];
}

- (void)addMocksForPostMomentWithText:(NSString *)momentText photo:(UIImage *)momentPhoto throwbackDate:(NSDate *)throwbackDate journeyName:(NSString *)journeyName options:(NSUInteger)options {
  [self addMocksForPostMomentWithText:momentText tags:nil photo:momentPhoto throwbackDate:throwbackDate journeyName:journeyName options:options];
}

- (void)addMocksForPostMomentWithText:(NSString *)momentText tags:(NSSet *)tags photo:(UIImage *)momentPhoto throwbackDate:(NSDate *)throwbackDate journeyName:(NSString *)journeyName options:(NSUInteger)options {
  EvstMockMomentCreate *momentCreateMock = [[EvstMockMomentCreate alloc] initWithOptions:options];
  momentCreateMock.journeyName = journeyName;
  momentCreateMock.momentText = momentText;
  momentCreateMock.momentPhoto = momentPhoto;
  momentCreateMock.throwbackDate = throwbackDate;
  momentCreateMock.tags = tags;
  [self addObject:momentCreateMock];
  
  [self addMocksForNotificationsCountGet];
}

- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid imageOption:(NSUInteger)imageOption importanceOption:(NSUInteger)importanceOption {
  EvstMockMomentPatch *momentEditMock = [[EvstMockMomentPatch alloc] initWithOptions:0];
  momentEditMock.importanceOption = importanceOption;
  [momentEditMock mockWithMomentName:momentName withUUID:uuid imageOption:imageOption];
  [self addObject:momentEditMock];
}

- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid imageOption:(NSUInteger)imageOption {
  [self addMocksForEditingMomentWithName:momentName uuid:uuid imageOption:imageOption importanceOption:EvstMockMomentNormalImportanceOption];
}

- (void)addMocksForEditingMomentWithName:(NSString *)momentName uuid:(NSString *)uuid {
  [self addMocksForEditingMomentWithName:momentName uuid:uuid imageOption:EvstMockMomentImageOptionNoImage];
}

- (void)addMocksForDeletingMomentWithUUID:(NSString *)uuid {
  EvstMockMomentDelete *momentDeleteMock = [[EvstMockMomentDelete alloc] initWithOptions:0];
  [momentDeleteMock mockMomentDeleteWithUUID:uuid];
  [self addObject:momentDeleteMock];
}

- (void)addMocksForMomentLike:(NSString *)momentName {
  EvstMockMomentLike *momentLikeMock = [[EvstMockMomentLike alloc] initWithOptions:EvstMockMomentLikeOptionLike];
  momentLikeMock.momentName = momentName;
  [self addObject:momentLikeMock];
}

- (void)addMocksForMomentUnlike:(NSString *)momentName {
  EvstMockMomentLike *momentLikeMock = [[EvstMockMomentLike alloc] initWithOptions:EvstMockMomentLikeOptionUnlike];
  momentLikeMock.momentName = momentName;
  [self addObject:momentLikeMock];
}

- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName {
  [self addMocksForJourneyMomentsForJourneyNamed:journeyName optional:NO];
}

- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional {
  [self addMocksForJourneyMomentsForJourneyNamed:journeyName optional:optional importanceOption:EvstMockMomentNormalImportanceOption];
}

- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional importanceOption:(NSUInteger)importanceOption {
  [self addMocksForJourneyMomentsForJourneyNamed:journeyName optional:optional importanceOption:importanceOption options:0];
}

- (void)addMocksForJourneyMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional importanceOption:(NSUInteger)importanceOption options:(NSUInteger)options {
  EvstMockJourneyMomentsList *momentsListMock = [[EvstMockJourneyMomentsList alloc] initWithOptions:options];
  momentsListMock.journeyName = journeyName;
  momentsListMock.importanceOption = importanceOption;
  momentsListMock.optional = optional;
  [self addObject:momentsListMock];
}

- (void)addMocksForLifecycleMomentsForJourneyNamed:(NSString *)journeyName optional:(BOOL)optional {
  EvstMockJourneyMomentsList *momentsListMock = [[EvstMockJourneyMomentsList alloc] initWithOptions:0];
  momentsListMock.journeyName = journeyName;
  momentsListMock.optional = optional;
  momentsListMock.onlyLifecycleMoments = YES;
  [self addObject:momentsListMock];
}

- (void)addMocksForLikersListForMomentWithUUID:(NSString *)momentUUID {
  EvstMockLikersList *likersMock = [[EvstMockLikersList alloc] initWithOptions:0];
  likersMock.momentUUID = momentUUID;
  [self addObject:likersMock];
}

#pragma mark - Discover

- (void)addMocksForDiscoverCategoriesIndexAsOptional:(BOOL)optional {
  EvstMockDiscoverCategoriesIndex *discoverCategories = [[EvstMockDiscoverCategoriesIndex alloc] initWithOptions:0];
  discoverCategories.optional = optional;
  [self addObject:discoverCategories];
}

- (void)addMocksForDiscoverCategoryWithUUID:(NSString *)uuid options:(NSUInteger)options {
  EvstMockDiscover *exploreMock = [[EvstMockDiscover alloc] initWithOptions:options];
  exploreMock.categoryUUID = uuid;
  [self addObject:exploreMock];
}

- (void)addMocksForDiscoverSearchWithOptions:(NSUInteger)options searchKeyword:(NSString *)searchKeyword {
  EvstMockDiscoverSearch *exploreSearchMock = [[EvstMockDiscoverSearch alloc] initWithOptions:options];
  exploreSearchMock.searchKeyword = searchKeyword;
  [self addObject:exploreSearchMock];
}

#pragma mark - Tags

- (void)addMocksForTagSearchWithOptions:(NSUInteger)options tag:(NSString *)tag {
  EvstMockTagSearch *tagSearchMock = [[EvstMockTagSearch alloc] initWithOptions:options];
  tagSearchMock.tag = tag;
  [self addObject:tagSearchMock];
}

#pragma mark - Users

- (void)addMocksForSuggestedUsersGetAsOptional:(BOOL)optional {
  EvstMockSuggestedUsersGet *suggestedUser = [[EvstMockSuggestedUsersGet alloc] initWithOptions:0];
  suggestedUser.optional = optional;
  [self addObject:suggestedUser];
}

- (void)addMocksForEverestTeamGetAsOptional:(BOOL)optional {
  EvstMockEverestTeamGet *everestTeam = [[EvstMockEverestTeamGet alloc] initWithOptions:0];
  everestTeam.optional = optional;
  [self addObject:everestTeam];
}

- (void)addMocksForSuggestedPeopleAsOptional:(BOOL)optional {
  [self addMocksForSuggestedUsersGetAsOptional:optional];
  [self addMocksForEverestTeamGetAsOptional:optional];
}

- (void)addMocksForUserGet:(NSString *)userName {
  [self addMocksForUserGet:userName optional:NO];
}

- (void)addMocksForUserGet:(NSString *)userName optional:(BOOL)optional {
  EvstMockUserGet *userGetMock = [[EvstMockUserGet alloc] initWithOptions:0];
  userGetMock.userName = userName;
  userGetMock.optional = optional;
  [self addObject:userGetMock];
}

- (void)addMocksForUserPutWithNewValues:(NSDictionary *)newValues {
  [self addMocksForUserPutWithNewValues:newValues mockingError:NO];
}

- (void)addMocksForUserPutWithNewValues:(NSDictionary *)newValues mockingError:(BOOL)mockingError {
  EvstMockUserPut *userPutMock = [[EvstMockUserPut alloc] initWithOptions:0];
  userPutMock.mockingError = mockingError;
  
  for (NSString *key in [newValues allKeys]) {
    NSString *newValue = [newValues objectForKey:key];
    if ([key isEqualToString:kJsonFirstName]) {
      userPutMock.firstName = newValue;
    }
    if ([key isEqualToString:kJsonLastName]) {
      userPutMock.lastName = newValue;
    }
    if ([key isEqualToString:kJsonGender]) {
      userPutMock.gender = newValue;
    }
    if ([key isEqualToString:kJsonEmail]) {
      userPutMock.email = newValue;
    }
    if ([key isEqualToString:kJsonUsername]) {
      userPutMock.userName = newValue;
    }
    if ([key isEqualToString:kJsonPassword]) {
      userPutMock.password = newValue;
    }
  }
  [self addObject:userPutMock];
}

- (void)addMocksForUserPut {
  [self addMocksForUserPutWithNewValues:@{kJsonFirstName :kEvstTestUserFirstName, kJsonLastName : kEvstTestUserLastName}];
}

- (void)addMocksForUserPatch {
  [self addMocksForUserPatchWithOptions:0];
}

- (void)addMocksForUserPatchWithOptions:(NSUInteger)options {
  EvstMockUserPatch *userPatchMock = [[EvstMockUserPatch alloc] initWithOptions:options];
  [self addObject:userPatchMock];
}

- (void)addMocksForUserRecentActivity:(NSString *)userName options:(NSUInteger)options {
  EvstMockUserRecentActivity *userRecentActivityMock = [[EvstMockUserRecentActivity alloc] initWithOptions:options];
  userRecentActivityMock.userName = userName;
  [self addObject:userRecentActivityMock];
}

- (void)addMocksForUserFollowingList {
  EvstMockUserFollows *userFollowingListMock = [[EvstMockUserFollows alloc] initWithOptions:EvstMockUserFollowsOptionFollowing];
  [self addObject:userFollowingListMock];
}

- (void)addMocksForUserFollowersList {
  EvstMockUserFollows *userFollowersListMock = [[EvstMockUserFollows alloc] initWithOptions:EvstMockUserFollowsOptionFollowers];
  [self addObject:userFollowersListMock];
}

- (void)addMocksForFollow:(NSString *)userName {
  EvstMockUserFollow *userFollowMock = [[EvstMockUserFollow alloc] initWithOptions:0];
  userFollowMock.userName = userName;
  [self addObject:userFollowMock];
}

- (void)addMocksForUnfollow:(NSString *)userName {
  EvstMockUserUnfollow *userUnfollowMock = [[EvstMockUserUnfollow alloc] initWithOptions:0];
  userUnfollowMock.userName = userName;
  [self addObject:userUnfollowMock];
}

- (void)addMocksForCurrentUserProfileAndJourneysList {
  [self addMocksForUserProfileAndJourneysList:kEvstTestUserFullName userUUID:kEvstTestUserUUID];
}

- (void)addMocksForUserProfileAndJourneysList:(NSString *)userName userUUID:(NSString *)uuid {
  [self addMocksForUserGet:userName];
  [self addMocksForUserRecentActivity:userName options:EvstMockOffsetForPage1];
  [self addMocksForFullJourneyListForUserUUID:uuid options:EvstMockOffsetForPage1 optional:NO];
}

- (void)addMocksForHomeUserSearchWithOptions:(NSUInteger)options searchKeyword:(NSString *)searchKeyword {
  EvstMockHomeUserSearch *homeUserSearchMock = [[EvstMockHomeUserSearch alloc] initWithOptions:options];
  homeUserSearchMock.searchKeyword = searchKeyword;
  [self addObject:homeUserSearchMock];
}

- (void)addMocksForResettingPassword {
  EvstMockUserResetPassword *resetPasswordMock = [[EvstMockUserResetPassword alloc] initWithOptions:0];
  [self addObject:resetPasswordMock];
}

#pragma mark - Notifications

- (void)addMocksForNotificationsGetWithOptions:(NSUInteger)options {
  EvstMockNotificationsGet *notificationsGetMock = [[EvstMockNotificationsGet alloc] initWithOptions:options];
  [self addObject:notificationsGetMock];
}

- (void)addMocksForNotificationsCountGet {
  EvstMockNotificationsCountGet *countMock = [[EvstMockNotificationsCountGet alloc] initWithOptions:0];
  countMock.optional = YES;
  [self addObject:countMock];
}

#pragma mark - Social swizzling

+ (void)swizzledRequestAccessToAccountsWithType:(ACAccountType *)accountType
                                        options:(NSDictionary *)options
                                     completion:(ACAccountStoreRequestAccessCompletionHandler)completion {
  completion(YES, nil);
}

+ (NSArray *)swizzledEmptyAccountsWithAccountType:(ACAccountType *)accountType {
  return @[];
}

+ (NSArray *)swizzledOneAccountWithAccountType:(ACAccountType *)accountType {
  ACAccount *firstAccount = [[ACAccount alloc] initWithAccountType:accountType];
  firstAccount.username = ([accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]) ? kEvstTestUserFullName : kEvstTestUserUsername;
  return @[firstAccount];
}

+ (NSArray *)swizzledTwoAccountsWithAccountType:(ACAccountType *)accountType {
  ACAccount *firstAccount = [[ACAccount alloc] initWithAccountType:accountType];
  firstAccount.username = ([accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]) ? kEvstTestUserFullName : kEvstTestUserUsername;
  
  ACAccount *secondAccount = [[ACAccount alloc] initWithAccountType:accountType];
  secondAccount.username = ([accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]) ? kEvstTestUserOtherFullName : kEvstTestUserOtherUsername;
  
  return @[firstAccount, secondAccount];
}

#pragma mark - Twitter swizzling

+ (void)swizzledAuthorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                                  userAuthorizationPath:(NSString *)userAuthorizationPath
                                            callbackURL:(NSURL *)callbackURL
                                        accessTokenPath:(NSString *)accessTokenPath
                                           accessMethod:(NSString *)accessMethod
                                                  scope:(NSString *)scope
                                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                                failure:(void (^)(NSError *error))failure {
  AFOAuth1Token *token = [[AFOAuth1Token alloc] initWithKey:@"730893570-lbAhtdNFffLFNdJAqN0OpP5AYxwEumkbwx0JYDKJ" secret:@"40H89VX32RzuVwfah1BHZqRSK03iA5ZS2V2q21az9gxiL" session:nil expiration:nil renewable:NO];
  token.userInfo = @{@"screen_name" : kEvstTestUserUsername};
  success(token, nil);
}

#pragma mark - Facebook swizzling

+ (void)resetFacebookTestAccount {
  fbTestSession = nil;
}

+ (void)facebookOpenActiveSessionWithReadPermissions:(NSArray *)readPermissions allowLoginUI:(BOOL)allowLoginUI completionHandler:(FBSessionStateHandler)completionHandler {
  if (fbTestSession) {
    return;
  }
  
  fbTestSession = [FBTestSession sessionWithPrivateUserWithPermissions:readPermissions];
  FBAccessTokenData *fbAccessTokenData = [FBAccessTokenData createTokenFromString:kEvstTestFacebookAccessToken
                                                                      permissions:readPermissions
                                                                   expirationDate:nil
                                                                        loginType:FBSessionLoginTypeTestUser
                                                                      refreshDate:nil];
  [fbTestSession openFromAccessTokenData:fbAccessTokenData completionHandler:completionHandler];
}

+ (void)facebookOpenActiveSessionWithPublishPermissions:(NSArray *)publishPermissions defaultAudience:(FBSessionDefaultAudience)defaultAudience allowLoginUI:(BOOL)allowLoginUI completionHandler:(FBSessionStateHandler)completionHandler {
  fbTestSession = [FBTestSession sessionWithPrivateUserWithPermissions:publishPermissions];
  FBAccessTokenData *fbAccessTokenData = [FBAccessTokenData createTokenFromString:kEvstTestFacebookAccessToken
                                                                      permissions:publishPermissions
                                                                   expirationDate:nil
                                                                        loginType:FBSessionLoginTypeTestUser
                                                                      refreshDate:nil];
  [fbTestSession openFromAccessTokenData:fbAccessTokenData completionHandler:completionHandler];
}

+ (FBSession *)facebookActiveSession {
  return fbTestSession;
}

+ (FBRequestConnection *)swizzledStartWithGraphPath:(NSString *)graphPath parameters:(NSDictionary *)parameters HTTPMethod:(NSString *)HTTPMethod completionHandler:(FBRequestHandler)handler {
  NSDictionary *result = @{
                           @"email" : kEvstTestUserEmail,
                           @"first_name" : kEvstTestUserFirstName,
                           @"gender" : kJsonMale,
                           @"id" : @"1234567890",
                           @"last_name" : kEvstTestUserLastName,
                           @"picture" : @{ @"data" : @{
                                               @"height" : @"960",
                                               @"is_silhouette" : @"0",
                                               @"url" : kEvstTestFacebookUserImage,
                                               @"width" : @"960",
                                               },
                                           },
                           };
  handler(nil, result, nil);
  return nil;
}

+ (void)facebookStartWithGraphPath:(NSString *)graphPath completionHandler:(FBRequestHandler)completionHandler {
  completionHandler(nil, nil, nil);
}

- (void)facebookDialog:(NSString *)action andParams:(NSMutableDictionary *)params andDelegate:(id <FBDialogDelegate>)delegate {
  if (![action isEqualToString:@"apprequests"]) {
    [[[UIAlertView alloc] initWithTitle:@"KIF test failed" message:@"Facebook dialog requested with unsupported action" delegate:nil cancelButtonTitle:nil otherButtonTitles:kLocaleOK, nil] show];
    return;
  }
  
  NSString *dialogMessage = [params objectForKey:@"message"];
  if (![dialogMessage isEqualToString:kLocaleInviteFacebookFriend]) {
    [[[UIAlertView alloc] initWithTitle:@"KIF test failed" message:@"Facebook dialog requested with wrong message" delegate:nil cancelButtonTitle:nil otherButtonTitles:kLocaleOK, nil] show];
    return;
  }
  
  FBDialog *fbDialog = [[FBDialog alloc] init];
  [fbDialog setParams:[NSMutableDictionary dictionaryWithDictionary:@{@"to": [params objectForKey:@"to"]}]];
  [delegate performSelector:@selector(dialogDidComplete:) withObject:fbDialog];
}

@end
