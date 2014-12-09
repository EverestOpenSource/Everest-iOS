//
//  EvstJourneysEndPoint.m
//  Everest
//
//  Created by Rob Phillips on 12/11/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstJourneysEndPoint.h"
#import "EverestJourney.h"
#import "EvstCustomMapper.h"
#import "EvstCacheBase.h"
#import "EvstS3ImageUploader.h"

@implementation EvstJourneysEndPoint

#pragma mark - CREATE

+ (void)createNewJourney:(EverestJourney *)journey withCoverImage:(UIImage *)coverImage success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  
  // Default all new journeys to order 1
  journey.order = EvstJourneyOrderNonEverestIndex;
  
  [self requestForPath:kEndPointCreateListJourneys httpMethod:RKRequestMethodPOST image:coverImage journey:journey success:successHandler failure:failureHandler progress:progressHandler];
}

#pragma mark - DELETE

+ (void)deleteJourney:(EverestJourney *)journey success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(journey, @"Journey must not be nil when we attempt to DELETE it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteJourneyFormat, journey.uuid];
  [[EvstAPIClient objectManager] deleteObject:journey path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    [[EvstCacheBase sharedCache] deleteCachedFullObject:journey];
    if (successHandler) {
      successHandler();
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - INDEX

+ (void)checkForActiveJourneyForUser:(EverestUser *)user success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [self getJourneysForUser:user page:1 limit:1 excludeAccomplished:YES success:^(NSArray *journeys) {
    EverestJourney *journey;
    if (journeys.count > 0) {
      // Ensure the returned journey is unaccomplished
      EverestJourney *journeyToCheck = journeys.firstObject;
      if (journeyToCheck.isActive) {
        journey = journeyToCheck;
      }
    }
    if (successHandler) {
      successHandler(journey);
    }
  } failure:failureHandler];
}

+ (void)getJourneysForUser:(EverestUser *)user page:(NSUInteger)page excludeAccomplished:(BOOL)excludeAccomplished success:(void (^)(NSArray *journeys))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [self getJourneysForUser:user page:page limit:kEvstJourneysListPagingOffset excludeAccomplished:excludeAccomplished success:successHandler failure:failureHandler];
}

+ (void)getJourneysForUser:(EverestUser *)user page:(NSUInteger)page limit:(NSUInteger)limit excludeAccomplished:(BOOL)excludeAccomplished success:(void (^)(NSArray *journeys))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(user, @"User must not be nil when we attempt to GET their journeys.");
  NSString *path = [NSString stringWithFormat:kEndPointGetUserJourneysFormat, user.uuid];
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstJourneysListPagingOffset]; // For the journeys list, let's get two pages at once (per feedback from team)
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kJsonOffset : offset}];
  if (excludeAccomplished) {
    [parameters setObject:kJsonActive forKey:kJsonType];
  }
  if (limit > 0) {
    [parameters setObject:[NSNumber numberWithInteger:limit] forKey:kJsonLimit];
  }
  [[EvstAPIClient objectManager] getObjectsAtPath:path parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Caching handled in table batch update
    if (successHandler) {
      successHandler([EvstCustomMapper mappedJourneysToUsersUsingDictionary:mappingResult.dictionary]);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - UPDATE

+ (void)updateJourney:(EverestJourney *)journey withCoverImage:(UIImage *)coverImage success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteJourneyFormat, journey.uuid];
  [self requestForPath:path httpMethod:RKRequestMethodPUT image:coverImage journey:journey success:successHandler failure:failureHandler progress:progressHandler];
}

#pragma mark - SHOW

+ (void)getJourneyWithUUID:(NSString *)uuid success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(uuid, @"Journey UUID must not be nil when we attempt to SHOW it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteJourneyFormat, uuid];
  EverestJourney *journey = [[EverestJourney alloc] init];
  journey.uuid = uuid;
  [[EvstAPIClient objectManager] getObject:journey path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    if (successHandler) {
      EverestJourney *mappedJourney = [[EvstCustomMapper mappedJourneysToUsersUsingDictionary:mappingResult.dictionary] firstObject];
      mappedJourney = [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:mappedJourney];
      successHandler(mappedJourney);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - Private Methods

+ (void)requestForPath:(NSString *)path httpMethod:(RKRequestMethod)method image:(UIImage *)image journey:(EverestJourney *)journey success:(void (^)(EverestJourney *journey))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  ZAssert(journey, @"Journey must not be nil when we attempt to send a request for it.");
  
  // Setup a block to perform the Everest API request
  void (^journeyRequestBlock)(NSString *) = ^void(NSString *imageURLString) {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (imageURLString) {
      [parameters setObject:imageURLString forKey:kJsonRequestJourneyCoverImageKey];
    }
    
    NSURLRequest *request = [[EvstAPIClient objectManager] requestWithObject:journey method:method path:path parameters:parameters];
    RKObjectRequestOperation *operation = [[EvstAPIClient objectManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      EverestJourney *mappedJourney = [EvstCustomMapper mappedJourneysToUsersUsingDictionary:mappingResult.dictionary].firstObject;
      mappedJourney = [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:mappedJourney];
      successHandler(mappedJourney);
      
      if (imageURLString) {
        [[EvstS3ImageUploader sharedUploader] clearSuccessfulUploadWithAbsoluteURLString:imageURLString];
      }
      
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }];
    [[EvstAPIClient objectManager] enqueueObjectRequestOperation:operation];
  };
  
  // If we have an attached image, upload it to S3 before making the Everest request
  if (image) {
    [[EvstS3ImageUploader sharedUploader] uploadToS3WithImage:image forType:EvstS3JourneyCoverImageUploadType success:^(NSString *s3absoluteURLString) {
      journeyRequestBlock(s3absoluteURLString);
    } failure:^(NSString *errorMsg) {
      if (failureHandler) {
        failureHandler(errorMsg);
      }
    } progress:^(CGFloat percentUploaded) {
      if (progressHandler) {
        progressHandler(percentUploaded);
      }
    }];
  } else {
    journeyRequestBlock(nil);
  }
}

@end
