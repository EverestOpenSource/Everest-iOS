//
//  EvstS3ImageUploader.m
//  Everest
//
//  Created by Rob Phillips on 2/28/13.
//  Copyright (c) 2014 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import "EvstS3ImageUploader.h"

// Base S3 URL
static NSString *const kEvstBaseS3URLFormat = @"https://s3.amazonaws.com";

// Access (this user has *only* upload privileges to this bucket)
static NSString *const kEvstS3UploaderAccessKey = @"key-goes-here";
static NSString *const kEvstS3UploaderSecretKey = @"key-goes-here";

// Relative Paths within Bucket
static NSString *const kEvstS3JourneyImageRelativePathFormat = @"tmp/journey/image/%@";
static NSString *const kEvstS3MomentImageRelativePathFormat = @"tmp/moment/image/%@";
static NSString *const kEvstS3UserCoverImageRelativePathFormat = @"tmp/user/cover/%@";
static NSString *const kEvstS3UserAvatarImageRelativePathFormat = @"tmp/user/avatar/%@";

@interface EvstS3ImageUploader ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;
@property (nonatomic, strong) AmazonS3Client *amazonS3Client;
@property (nonatomic, strong) S3PutObjectResponse *putObjectResponse;

@property (nonatomic, copy) void (^successHandler)(NSString *s3absoluteURLString);
@property (nonatomic, copy) void (^failureHandler)(NSString *errorMsg);
@property (nonatomic, copy) void (^progressHandler)(CGFloat percentUploaded);

@property (nonatomic, strong) NSString *keyPathWithFilename;
@property (nonatomic, strong) NSData *jpgData;
@property (nonatomic, assign) NSUInteger jpgFileSizeInBytes;
@property (nonatomic, assign) long long transferProgressInBytes;

@property (nonatomic, strong) NSMutableDictionary *successfulUploads;
@end

@implementation EvstS3ImageUploader

#pragma mark - Singleton

+ (instancetype)sharedUploader {
  static id sharedUploader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedUploader = [[self alloc] init];
  });
  return sharedUploader;
}

- (id)init {
  self = [super init];
  if (self) {
    self.amazonS3Client = [[AmazonS3Client alloc] initWithAccessKey:kEvstS3UploaderAccessKey withSecretKey:kEvstS3UploaderSecretKey];
    self.amazonS3Client.endpoint = [AmazonEndpoints s3Endpoint:US_EAST_1];
    
    self.successfulUploads = [[NSMutableDictionary alloc] initWithCapacity:0];
  }
  return self;
}

#pragma mark - S3 Uploader Methods

- (void)uploadToS3WithImage:(UIImage *)image forType:(EvstS3ImageUploadType)uploadType success:(void (^)(NSString *))successHandler failure:(void (^)(NSString *))failureHandler progress:(void (^)(CGFloat percentUploaded))progressHandler {
  ZAssert(image, @"Image must not be nil when we try to upload it to S3");
  
#ifdef TESTING
  if (self.progressHandler) {
    self.progressHandler(1.f);
  }
  
  if (successHandler) {
    successHandler(@"https://s3-us-west-1.amazonaws.com/everest-testing-images/client/journeyCover.jpg");
  }
  return;
#endif

  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  self.successHandler = successHandler;
  self.failureHandler = failureHandler;
  self.progressHandler = progressHandler;
  
  self.jpgData = UIImageJPEGRepresentation(image, 1.0);
  self.jpgFileSizeInBytes = self.jpgData.length;
  self.transferProgressInBytes = 0;
  
  NSString *relativePath = [self generateRelativePathForImageData:self.jpgData uploadType:uploadType];
  self.keyPathWithFilename = [NSString stringWithFormat:@"%@/%@", relativePath, @"originalImage.jpeg"];
  
  // In the scenario that the original request to the Everest API may have failed, let's check if we had a
  // previously successful upload for this image data so we don't needlessly upload it again
  NSString *absoluteURLString = [self absoluteURLStringForImage];
  // Note: we cache @YES with the key absoluteURLString, so we really just want to return the key name, not the object
  if ([self.successfulUploads objectForKey:absoluteURLString]) {
    if (successHandler) {
      successHandler(absoluteURLString);
    }
    [self resetState];
    return;
  }
  
  // Set the content type and upload the image data
  S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:self.keyPathWithFilename inBucket:[EvstEnvironment s3Bucket]];
  putObjectRequest.contentType = @"image/jpeg";
  putObjectRequest.data = self.jpgData;
  putObjectRequest.delegate = self;
  self.putObjectResponse = [self.amazonS3Client putObject:putObjectRequest];
  
  // Enable background uploading
  self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    if (self.backgroundTaskID == UIBackgroundTaskInvalid) {
      return;
    }
    
    DLog(@"Background network operation time has expired so we cancelled the existing data upload.");
    // Cancel the connection
    [putObjectRequest cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.failureHandler) {
        self.failureHandler(kLocaleUploadImageBackgroundError);
      }
    });
    
    // Send the user a local notification to let them know as well
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = kLocaleUploadImageBackgroundError;
    notification.fireDate = [NSDate date];
    [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
    
    // Be sure to end the background task or iOS can kill the app
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
    self.backgroundTaskID = UIBackgroundTaskInvalid;
  }];
}

- (void)resetState {
  // AFNetworking handles hiding the network activity indicator after it POSTs/PUTs the photo URL to the server
  self.successHandler = nil;
  self.failureHandler = nil;
  self.progressHandler = nil;
  self.jpgData = nil;
  self.jpgFileSizeInBytes = 0;
  self.transferProgressInBytes = 0;
  self.keyPathWithFilename = nil;
  self.putObjectResponse = nil;
}

#pragma mark - Successful Upload Cache

- (void)clearSuccessfulUploadWithAbsoluteURLString:(NSString *)absoluteURLStringKey {
  // If the Everest API request was successful, we should remove the item from cache since
  // we can safely assume the API server will delete the tmp S3 image when it's done processing the file
  [self.successfulUploads removeObjectForKey:absoluteURLStringKey];
}

#pragma mark - Absolute URLs

- (NSString *)absoluteURLStringForImage {
  return [NSString stringWithFormat:@"%@/%@/%@", kEvstBaseS3URLFormat, [EvstEnvironment s3Bucket], self.keyPathWithFilename];
}

#pragma mark - Relative Paths

- (NSString *)generateRelativePathForImageData:(NSData *)imageData uploadType:(EvstS3ImageUploadType)uploadType {
  NSString *hash = [self generateMD5HashForImageData:imageData];
  switch (uploadType) {
    case EvstS3JourneyCoverImageUploadType:
      return [NSString stringWithFormat:kEvstS3JourneyImageRelativePathFormat, hash];
      break;
      
    case EvstS3MomentImageUploadType:
      return [NSString stringWithFormat:kEvstS3MomentImageRelativePathFormat, hash];
      break;
      
    case EvstS3UserAvatarImageUploadType:
      return [NSString stringWithFormat:kEvstS3UserAvatarImageRelativePathFormat, hash];
      break;
      
    case EvstS3UserCoverImageUploadType:
      return [NSString stringWithFormat:kEvstS3UserCoverImageRelativePathFormat, hash];
      break;
      
    default:
      ALog(@"Unexpected upload type so we could not generate a relative upload path.");
      return nil;
      break;
  }
}

- (NSString *)generateMD5HashForImageData:(NSData *)imageData {
  // Create a byte array of unsigned chars
  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
  
  // Create a 16 byte MD5 hash value and store in the buffer
  CC_MD5(imageData.bytes, (CC_LONG)imageData.length, md5Buffer);
  
  // Convert the unsigned char buffer to an NSString of hex values
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [output appendFormat:@"%02x", md5Buffer[i]];
  }
  
  return output;
}

#pragma mark - AmazonServiceRequestDelegate

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  NSString *absoluteURLString = [self absoluteURLStringForImage];
  [self.successfulUploads setObject:@YES forKey:absoluteURLString];
  if (self.successHandler) {
    self.successHandler(absoluteURLString);
  }
  [self resetState];
  [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  if (self.failureHandler) {
    self.failureHandler(error.localizedDescription);
  }
  [self resetState];
  [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
}

- (void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite {
  if ([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] == NO) {
    // Note: This is necessary for resetting the indicator after backgrounding the app
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  }
  
  if (self.progressHandler) {
    self.transferProgressInBytes += bytesWritten;
    CGFloat percentUploaded = (CGFloat)(self.transferProgressInBytes) / (CGFloat)(self.jpgFileSizeInBytes);
    self.progressHandler(percentUploaded);
  }
}

@end
