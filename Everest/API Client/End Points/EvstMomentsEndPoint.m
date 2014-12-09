//
//  EvstMomentsEndPoint.m
//  Everest
//
//  Created by Chris on 12/27/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstMomentsEndPoint.h"
#import "EverestMoment.h"
#import "EverestJourney.h"
#import "EvstCustomMapper.h"
#import "EvstCacheBase.h"
#import "EvstS3ImageUploader.h"

@implementation EvstMomentsEndPoint

#pragma mark - ADMIN METHODS

+ (void)spotlight:(BOOL)shouldSpotlight moment:(EverestMoment *)moment success:(void (^)(EverestMoment *updatedMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  if ([EvstAPIClient currentUser].isYeti == NO) {
    return; // Only let yeti's spotlight / unspotlight
  }
  ZAssert(moment, @"Moment must not be nil when we attempt to spotlight/unspotlight it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, moment.uuid];
  [[EvstAPIClient objectManager] patchObject:moment path:path parameters:@{kJsonMoment : @{ kJsonSpotlighted : [NSNumber numberWithBool:shouldSpotlight]}} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    EverestMoment *mappedMoment = [[EvstCustomMapper mappedMomentsToJourneysUsersAndLikersUsingDictionary:mappingResult.dictionary] firstObject];
    mappedMoment = [[EvstCacheBase sharedCache] cacheOrAlwaysOverwriteExistingFullObject:mappedMoment];
    successHandler(mappedMoment);
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - PUBLIC METHODS

#pragma mark - CREATE

+ (void)createMoment:(EverestMoment *)moment image:(UIImage *)image onJourney:(EverestJourney *)journey success:(void (^)(EverestMoment *createdMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat))progressHandler {
  ZAssert(moment, @"Moment must not be nil when we attempt to CREATE it.");
  ZAssert(journey, @"Journey must not be nil when we attempt to CREATE a step on it.");
  
  NSString *path = [NSString stringWithFormat:kEndPointCreateListJourneyMomentsFormat, journey.uuid];
  [self requestForPath:path httpMethod:RKRequestMethodPOST image:image moment:moment success:successHandler failure:failureHandler progress:progressHandler];
}

#pragma mark - DELETE

+ (void)deleteMoment:(EverestMoment*)moment success:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(moment, @"Moment must not be nil when we attempt to DELETE it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, moment.uuid];
  [[EvstAPIClient objectManager] deleteObject:moment path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    [[EvstCacheBase sharedCache] deleteCachedFullObject:moment];
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

+ (void)getMomentsForJourney:(EverestJourney *)journey beforeDate:(NSDate *)beforeDate success:(void (^)(NSArray *moments))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(journey, @"Journey must not be nil when we attempt to GET moments.");
  NSString *momentsPath = [NSString stringWithFormat:kEndPointCreateListJourneyMomentsFormat, journey.uuid];
  NSString *iso8601String = RKStringFromDate(beforeDate);
  [[EvstAPIClient objectManager] getObjectsAtPath:momentsPath parameters:@{kJsonCreatedBefore : iso8601String} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Caching handled in table batch update
    if (successHandler) {
      successHandler([EvstCustomMapper mappedMomentsToJourneysUsersAndLikersUsingDictionary:mappingResult.dictionary]);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

+ (void)getLikersForMomentWithUUID:(NSString *)uuid page:(NSUInteger)page success:(void (^)(NSArray *likers))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(uuid, @"Moment UUID must not be nil when we attempt to get likers for it.");
  NSNumber *offset = [NSNumber numberWithInteger:(page - 1) * kEvstDefaultPagingOffset];
  NSString *path = [NSString stringWithFormat:kEndPointGetLikersForMomentFormat, uuid];
  NSDictionary *parameters = @{kJsonOffset : offset};
  [[EvstAPIClient objectManager] getObjectsAtPath:path parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    if (successHandler) {
      successHandler(mappingResult.array);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - SHOW

+ (void)getMomentWithUUID:(NSString *)uuid success:(void (^)(EverestMoment *moment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  ZAssert(uuid, @"Moment UUID must not be nil when we attempt to SHOW it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, uuid];
  EverestMoment *moment = [[EverestMoment alloc] init];
  moment.uuid = uuid;
  [[EvstAPIClient objectManager] getObject:moment path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    EverestMoment *mappedMoment = [[EvstCustomMapper mappedMomentsToJourneysUsersAndLikersUsingDictionary:mappingResult.dictionary] firstObject];
    mappedMoment = [[EvstCacheBase sharedCache] cacheOrAlwaysOverwriteExistingFullObject:mappedMoment];
    if (successHandler) {
      successHandler(mappedMoment);
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    if ([EvstCommon showUserError:error] && failureHandler) {
      failureHandler([EvstCommon messageForOperation:operation error:error]);
    }
  }];
}

#pragma mark - PATCH

+ (void)patchMoment:(EverestMoment *)moment image:(id)image success:(void (^)(EverestMoment *createdMoment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler {
  ZAssert(moment, @"Moment must not be nil when we attempt to PATCH it.");
  NSString *path = [NSString stringWithFormat:kEndPointGetPutPatchDeleteMomentFormat, moment.uuid];
  [self requestForPath:path httpMethod:RKRequestMethodPATCH image:image moment:moment success:successHandler failure:failureHandler progress:progressHandler];
}

#pragma mark - Private Methods

+ (void)requestForPath:(NSString *)path httpMethod:(RKRequestMethod)method image:(id)image moment:(EverestMoment *)moment success:(void (^)(EverestMoment *moment))successHandler failure:(void (^)(NSString *errorMsg))failureHandler  progress:(void (^)(CGFloat))progressHandler {
  ZAssert(moment, @"Moment must not be nil when we attempt to send a request for it.");

  // Setup a block to perform the Everest API request
  void (^momentRequestBlock)(NSString *imageURLString) = ^void(NSString *imageURLString) {
    // If the user didn't change or add an image, imageURLString will be nil
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (imageURLString) {
      [parameters setObject:imageURLString forKey:kJsonRequestMomentImageKey];
    }
    
    // Check if the user removed the image during an edit
    BOOL removingImage = [image isEqual:[NSNull null]];
    if (removingImage) {
      [parameters setObject:@YES forKey:kJsonRequestMomentRemoveImageKey];
    }
    
    // Note: The takenAt field should never be set to nil since it turns the moment into a "planned" moment
    moment.takenAt = moment.takenAt ?: moment.createdAt;

    // Save these here since the server doesn't have these attributes
    BOOL shouldShareOnFacebook = moment.shareOnFacebook;
    BOOL shouldShareOnTwitter = moment.shareOnTwitter;
    
    NSURLRequest *request = [[EvstAPIClient objectManager] requestWithObject:moment method:method path:path parameters:parameters];
    RKObjectRequestOperation *operation = [[EvstAPIClient objectManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      EverestMoment *mappedMoment = [[EvstCustomMapper mappedMomentsToJourneysUsersAndLikersUsingDictionary:mappingResult.dictionary] firstObject];
      mappedMoment = [[EvstCacheBase sharedCache] cacheOrUpdateFullObject:mappedMoment];
      successHandler(mappedMoment);
      
      if (imageURLString) {
        [[EvstS3ImageUploader sharedUploader] clearSuccessfulUploadWithAbsoluteURLString:imageURLString];
      }
      
      // Check if we need to share a newly created moment
      if (method & RKRequestMethodPOST) {
        if (shouldShareOnFacebook) {
          [EvstFacebook silentlyShareMessage:mappedMoment.name withLink:mappedMoment.webURL momentImage:image];
        }
        if (shouldShareOnTwitter) {
          [EvstTwitter silentlyShareMessage:mappedMoment.name withLink:mappedMoment.webURL momentImage:image];
        }
      }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
      if ([EvstCommon showUserError:error] && failureHandler) {
        failureHandler([EvstCommon messageForOperation:operation error:error]);
      }
    }];
    [[EvstAPIClient objectManager] enqueueObjectRequestOperation:operation];
  };
  
  // If we have an attached image, upload it to S3 before making the Everest request
  if (image && ![image isEqual:[NSNull null]]) {
    [[EvstS3ImageUploader sharedUploader] uploadToS3WithImage:image forType:EvstS3MomentImageUploadType success:^(NSString *s3absoluteURLString) {
      momentRequestBlock(s3absoluteURLString);
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
    momentRequestBlock(nil);
  }
}

@end
