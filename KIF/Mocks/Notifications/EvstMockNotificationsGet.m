//
//  EvstMockNotificationsGet.m
//  Everest
//
//  Created by Chris Cornelis on 02/26/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockNotificationsGet.h"

@implementation EvstMockNotificationsGet

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointGetNotifications]];
  return self;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  if (self.options == EvstMockGeneralOptionEmptyResponse) {
    return [self responseForDictionary:@{ } statusCode:200];
  }
  
  NSDictionary *response = @{ kJsonNotifications : @[
                                  @{
                                    kJsonDestinationType:kJsonMoment,
                                    kJsonDestinationId:@"51a3e946577625a44070",
                                    kJsonCreatedAt:@"2014-04-08T22:18:16+00:00",
                                    kJsonMessage1: @{
                                      kJsonContent:@"Joshie Wa",
                                      kJsonType:kJsonUser,
                                      kJsonId:@"f113a9c6b528c980e2c8",
                                      kJsonImage:@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/standardAvatar.jpg"
                                    },
                                    kJsonMessage2: @{
                                      kJsonContent:@"commented on your moment"
                                    },
                                    kJsonMessage3: @{
                                      kJsonContent:@""
                                    }
                                  },
                                  @{
                                    kJsonDestinationType:kJsonMoment,
                                    kJsonDestinationId:@"51a3e946577625a44070",
                                    kJsonCreatedAt:@"2014-04-08T22:17:59+00:00",
                                    kJsonMessage1: @{
                                      kJsonContent:@"Joshie Wa",
                                      kJsonType:kJsonUser,
                                      kJsonId:@"f113a9c6b528c980e2c8",
                                      kJsonImage:@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/standardAvatar.jpg"
                                    },
                                    kJsonMessage2: @{
                                      kJsonContent:@"liked your moment"
                                    },
                                    kJsonMessage3:@{
                                      kJsonContent:@""
                                    }
                                  },
                                  @{
                                    kJsonDestinationType: kJsonMoment,
                                    kJsonDestinationId:@"5123d946a9c9a5510105",
                                    kJsonCreatedAt:@"2014-04-08T22:11:55+00:00",
                                    kJsonMessage1: @{
                                      kJsonContent:@"Joshie Wa",
                                      kJsonType:kJsonUser,
                                      kJsonId:@"f113a9c6b528c980e2c8",
                                      kJsonImage:@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/standardAvatar.jpg"
                                    },
                                    kJsonMessage2:@{
                                      kJsonContent:@"just posted a milestone moment!"
                                    },
                                    kJsonMessage3:@{
                                      kJsonContent:@""
                                    }
                                  },
                                  @{
                                    kJsonDestinationType: kJsonUser,
                                    kJsonDestinationId:@"5123d946a9c9a5510105",
                                    kJsonCreatedAt:@"2014-04-08T22:11:55+00:00",
                                    kJsonMessage1: @{
                                        kJsonContent:@"Joshie Wa",
                                        kJsonType:kJsonUser,
                                        kJsonId:@"f113a9c6b528c980e2c8",
                                        kJsonImage:@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/standardAvatar.jpg"
                                        },
                                    kJsonMessage2:@{
                                        kJsonContent:@"just followed you!"
                                        },
                                    kJsonMessage3:@{
                                        kJsonContent:@""
                                        }
                                    },
                                  @{
                                    kJsonDestinationType: kJsonJourney,
                                    kJsonDestinationId:@"5123d946a9c9a5510105",
                                    kJsonCreatedAt:@"2014-04-08T22:11:55+00:00",
                                    kJsonMessage1: @{
                                        kJsonContent:@"Joshie Wa",
                                        kJsonType:kJsonUser,
                                        kJsonId:@"f113a9c6b528c980e2c8",
                                        kJsonImage:@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/standardAvatar.jpg"
                                        },
                                    kJsonMessage2:@{
                                        kJsonContent:@"accomplished their journey!"
                                        },
                                    kJsonMessage3:@{
                                        kJsonContent:@""
                                        }
                                    }
                                ]
                              };
  
  return [self responseForDictionary:response statusCode:200];
}

@end
