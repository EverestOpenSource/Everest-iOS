//
//  EvstKIFTestConstants.m
//  Everest
//
//  Created by Chris Cornelis on 01/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstKIFTestConstants.h"

#pragma mark - Errors

NSString *const kEvstTestIsAlreadyInUseMessage = @"is already in use by another user";

#pragma mark - Notifications 

NSString *const kEvstTestNotificationsCount = @"5";

#pragma mark - Default test user

NSString *const kEvstTestUserEmail = @"a@b.c";
NSString *const kEvstTestUserPassword = @"password";
NSString *const kEvstTestUserUUID = @"kEvstTestUserUUID";
NSString *const kEvstTestUserFirstName = @"Test";
NSString *const kEvstTestUserLastName = @"User";
NSString *const kEvstTestUserFullName = @"Test User";
NSString *const kEvstTestUserUsername = @"testuser";
NSString *const kEvstTestEverestAccessToken = @"kTestEverestAccessToken";

#pragma mark - Discover

NSString *const kEvstTestDiscoverCategory1UUID = @"Category1UUID";
NSString *const kEvstTestDiscoverCategory1Name = @"Everything";
NSString *const kEvstTestDiscoverCategory1Detail = @"Drink from a firehose, s'il te plaît";
NSString *const kEvstTestDiscoverCategory1Image = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/categories/category1.jpg";

NSString *const kEvstTestDiscoverCategory2UUID = @"Category2UUID";
NSString *const kEvstTestDiscoverCategory2Name = @"Trending";
NSString *const kEvstTestDiscoverCategory2Detail = @"No Beliebers allowed";
NSString *const kEvstTestDiscoverCategory2Image = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/categories/category2.jpg";

NSString *const kEvstTestDiscoverCategory3UUID = @"Category3UUID";
NSString *const kEvstTestDiscoverCategory3Name = @"Editor's Picks";
NSString *const kEvstTestDiscoverCategory3Detail = @"Stuff we choose";
NSString *const kEvstTestDiscoverCategory3Image = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/categories/category3.jpg";

#pragma mark - Following / Followers

NSUInteger const kEvstMockFollowingRowCount = 2;
NSString *const kEvstTestUserFollowing1UUID = @"kEvstTestUserFollowing1UUID";
NSString *const kEvstTestUserFollowing1FirstName = @"Following";
NSString *const kEvstTestUserFollowing1LastName = @"User1";
NSString *const kEvstTestUserFollowing1FullName = @"Following User1";
NSString *const kEvstTestUserFollowing1Email = @"following1@example.com";
NSString *const kEvstTestUserFollowing2UUID = @"kEvstTestUserFollowing2UUID";
NSString *const kEvstTestUserFollowing2FirstName = @"Following";
NSString *const kEvstTestUserFollowing2LastName = @"User2";
NSString *const kEvstTestUserFollowing2FullName = @"Following User2";
NSString *const kEvstTestUserFollowing2Email = @"following2@example.com";

NSUInteger const kEvstMockFollowersRowCount = 3;
NSString *const kEvstTestUserFollowers1UUID = @"kEvstTestUserFollowers1UUID";
NSString *const kEvstTestUserFollowers1FirstName = @"Followers";
NSString *const kEvstTestUserFollowers1LastName = @"User1";
NSString *const kEvstTestUserFollowers1FullName = @"Followers User1";
NSString *const kEvstTestUserFollowers1Email = @"followers1@example.com";
NSString *const kEvstTestUserFollowers2UUID = @"kEvstTestUserFollowers2UUID";
NSString *const kEvstTestUserFollowers2FirstName = @"Followers";
NSString *const kEvstTestUserFollowers2LastName = @"User2";
NSString *const kEvstTestUserFollowers2FullName = @"Followers User2";
NSString *const kEvstTestUserFollowers2Email = @"followers2@example.com";
NSString *const kEvstTestUserFollowers3UUID = @"kEvstTestUserFollowers3UUID";
NSString *const kEvstTestUserFollowers3FirstName = @"Followers";
NSString *const kEvstTestUserFollowers3LastName = @"User3";
NSString *const kEvstTestUserFollowers3FullName = @"Followers User3";
NSString *const kEvstTestUserFollowers3Email = @"followers3@example.com";

#pragma mark - Images

NSString *const kEvstTestImagePathColorfulVan = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/van.jpg";
NSString *const kEvstTestImagePathElephant = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/elephants.jpg";
NSString *const kEvstTestImagePathKitten = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/kitten.jpg";
NSString *const kEvstTestImagePathLeopard = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/leopard.jpg";
NSString *const kEvstTestImagePathJourneyCover = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/journeyCover.jpg";
NSString *const kEvstTestImagePathRobInCar = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/robInCar.jpg";
NSString *const kEvstTestImagePathShark = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/shark.jpg";
NSString *const kEvstTestImageForMoment = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/moment.jpg";
NSString *const kEvstTestImageFlowerHead = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/flowerHead.jpg";
NSString *const kEvstTestFacebookUserImage = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/fbUserImage.jpg";

#pragma mark - Journeys

NSString *const kEvstTestJourneyCreatedUUID = @"kEvstTestJourneyCreatedUUID";
NSString *const kEvstTestJourneyCreatedName = @"Newly created journey";
NSString *const kEvstTestJourneyEditedName = @"We just edited this journey!";
NSString *const kEvstTestWebURL = @"http://everest.com/test";

#pragma mark - Moments

NSUInteger const kEvstMockMomentRowCount = 3;
NSString *const kEvstTestMomentRow1CreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRow1UUID = @"kEvstTestMomentRow1UUID";
NSString *const kEvstTestMomentRow1Name = @"I'm a real moment and I matter!";
NSString *const kEvstTestMomentRow1Tag1 = @"testingout";
NSString *const kEvstTestMomentRow1Tag2 = @"tagstomake";
NSString *const kEvstTestMomentRow1Tag3 = @"verysurethey";
NSString *const kEvstTestMomentRow1Tag4 = @"aredisplayed";
NSString *const kEvstTestMomentRow1Tag5 = @"correctlyinview";
NSString *const kEvstTestMomentRow2CreatedAt = @"2013-12-20T05:32:56.970Z";
NSString *const kEvstTestMomentRow2UUID = @"kEvstTestMomentRow2UUID";
NSString *const kEvstTestMomentRow2Name = @"This is a second step.  It should be two lines long.  Is it?";
NSString *const kEvstTestMomentRow3CreatedAt = @"2013-12-20T05:31:56.970Z";
NSString *const kEvstTestMomentRow3UUID = @"kEvstTestMomentRow3UUID";
NSString *const kEvstTestMomentRow3Name = @"Some amazing third journey step goes here, bitchachos. This is a really, really long step to see how the cell might or might not be growing with it.  The wonderful world of journey steps and attributed labels.";
NSString *const kEvstTestMomentRow4CreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRow4UUID = @"kEvstTestMomentRow4UUID";
NSString *const kEvstTestMomentRow4Name = @"Fourth row seats!";
NSString *const kEvstTestMomentRow5CreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRow5UUID = @"kEvstTestMomentRow5UUID";
NSString *const kEvstTestMomentRow5Name = @"Fifth place ain't half bad";
NSString *const kEvstTestMomentRow6CreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRow6UUID = @"kEvstTestMomentRow6UUID";
NSString *const kEvstTestMomentRow6Name = @"Sally sells six sea shells by the sea shore.";
NSString *const kEvstTestMomentRowReopenedCreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRowReopenedUUID = @"kEvstTestMomentRowReopenedUUID";
NSString *const kEvstTestMomentRowAccomplishedCreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRowAccomplishedUUID = @"kEvstTestMomentRowAccomplishedUUID";
NSString *const kEvstTestMomentRowStartedCreatedAt = @"2013-12-20T05:33:56.970Z";
NSString *const kEvstTestMomentRowStartedUUID = @"kEvstTestMomentRowStartedUUID";

NSString *const kEvstTestMomentEditedName = @"We just edited this moment!";
NSString *const kEvstTestMomentEditedTakenAt = @"2013-12-20T05:33:56Z";

NSUInteger const kEvstTestMomentRow1LikeCount = 0;
NSUInteger const kEvstTestMomentRow2LikeCount = 2;
NSUInteger const kEvstTestMomentRow3LikeCount = 10;

NSUInteger const kEvstTestMomentRow1CommentCount = 2;
NSUInteger const kEvstTestMomentRow2CommentCount = 5;
NSUInteger const kEvstTestMomentRow3CommentCount = 0;

NSString *const kEvstTestMomentLiker1UUID = @"kEvstTestMomentLiker1UUID";
NSString *const kEvstTestMomentLiker1FirstName = @"Test";
NSString *const kEvstTestMomentLiker1LastName = @"Liker1";
NSString *const kEvstTestMomentLiker1FullName = @"Test Liker1";
NSString *const kEvstTestMomentLiker2UUID = @"kEvstTestMomentLiker2UUID";
NSString *const kEvstTestMomentLiker2FirstName = @"Test";
NSString *const kEvstTestMomentLiker2LastName = @"Liker2";
NSString *const kEvstTestMomentLiker2FullName = @"Test Liker2";

NSString *const kEvstTestMomentCreatedUUID = @"kEvstTestMomentCreatedUUID";

NSString *const kEvstTestSpotlightedByUUID = @"kEvstTestSpotlightedByUUID";
NSString *const kEvstTestSpotlightedByName = @"Everest";
NSString *const kEvstTestSpotlightedByImageURL = @"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/spotlightedBy.png";

#pragma mark - Journeys List

NSUInteger const kEvstMockJourneyRowCount = 4;
NSString *const kEvstTestJourneyRow1UUID = @"kEvstTestJourneyRow1UUID";
NSString *const kEvstTestJourneyRow1Name = @"I'm a real, live journey!";
NSString *const kEvstTestJourneyRow2UUID = @"kEvstTestJourneyRow2UUID";
NSString *const kEvstTestJourneyRow2Name = @"Never eat yellow snow again";
NSString *const kEvstTestJourneyRow3UUID = @"kEvstTestJourneyRow3UUID";
NSString *const kEvstTestJourneyRow3Name = @"This is a super long journey name and then I had to add some more characters.";
NSString *const kEvstTestJourneyRow4UUID = @"kEvstTestJourneyRow4UUID";
NSString *const kEvstTestJourneyRow4Name = @"I'm a shark and I'll eat you!";
NSString *const kEvstTestJourneyRow4CompletedAt = @"2013-12-20T05:30:56Z";

#pragma mark - Comments

NSUInteger const kEvstMockCommentRowCount = 4;
NSString *const kEvstTestCommentRow1CreatedAt = @"2013-12-27T05:33:56.970Z";
NSString *const kEvstTestCommentRow1UUID = @"kEvstTestCommentRow1UUID";
NSString *const kEvstTestCommentRow1Text = @"I am the oldest comment";
NSString *const kEvstTestCommentRow2CreatedAt = @"2013-12-28T05:32:56.970Z";
NSString *const kEvstTestCommentRow2UUID = @"kEvstTestCommentRow2UUID";
NSString *const kEvstTestCommentRow2Text = @"I love lamp";
NSString *const kEvstTestCommentRow3CreatedAt = @"2013-12-28T05:32:56.970Z";
NSString *const kEvstTestCommentRow3UUID = @"kEvstTestCommentRow3UUID";
NSString *const kEvstTestCommentRow3Text = @"You're a hairy gorilla butt face";
NSString *const kEvstTestCommentRow4CreatedAt = @"2013-12-28T05:32:56.970Z";
NSString *const kEvstTestCommentRow4UUID = @"kEvstTestCommentRow4UUID";
NSString *const kEvstTestCommentRow4Text = @"A casual stroll through the lunatic asylum shows that faith does not prove anything";
NSString *const kEvstTestCommentRow5CreatedAt = @"2013-12-28T05:32:56.970Z";
NSString *const kEvstTestCommentRow5UUID = @"kEvstTestCommentRow5UUID";
NSString *const kEvstTestCommentRow5Text = @"As you walk and eat and travel, be where you are.  Otherwise you will miss most of your life.";
NSString *const kEvstTestCommentRow6CreatedAt = @"2013-12-28T05:32:56.970Z";
NSString *const kEvstTestCommentRow6UUID = @"kEvstTestCommentRow5UUID";
NSString *const kEvstTestCommentRow6Text = @"I am the more recent comment. I am a multiline comment.";

NSString *const kEvstTestCreateCommentUUID = @"kEvstTestCreateCommentUUID";
NSString *const kEvstTestCreateCommentCreatedAt = @"2013-12-20T05:33:56.970Z";

NSString *const kEvstTestUserOtherUUID = @"kEvstTestUserOtherUUID";
NSString *const kEvstTestUserOtherFirstName = @"Other";
NSString *const kEvstTestUserOtherLastName = @"User";
NSString *const kEvstTestUserOtherFullName = @"Other User";
NSString *const kEvstTestUserOtherUsername = @"other_user";

#pragma mark - Facebook

NSString *const kEvstTestFacebookAccessToken = @"kTestFacebookAccessToken";
