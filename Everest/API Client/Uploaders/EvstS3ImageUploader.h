//
//  EvstS3ImageUploader.h
//  Everest
//
//  Created by Rob Phillips on 2/28/13.
//  Copyright (c) 2014 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>

typedef NS_ENUM(NSUInteger, EvstS3ImageUploadType) {
  EvstS3JourneyCoverImageUploadType,
  EvstS3MomentImageUploadType,
  EvstS3UserCoverImageUploadType,
  EvstS3UserAvatarImageUploadType
};

@interface EvstS3ImageUploader : NSObject <AmazonServiceRequestDelegate>

+ (instancetype)sharedUploader;

- (void)uploadToS3WithImage:(UIImage *)image forType:(EvstS3ImageUploadType)uploadType success:(void (^)(NSString *s3absoluteURLString))successHandler failure:(void (^)(NSString *errorMsg))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler;

- (void)clearSuccessfulUploadWithAbsoluteURLString:(NSString *)absoluteURLStringKey;

@end
