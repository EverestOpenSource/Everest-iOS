//
//  EvstImagePickerController.h
//  Everest
//
//  Created by Chris Cornelis on 01/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "DZNPhotoPickerController.h"

typedef NS_ENUM(NSUInteger, EvstImagePickerCropShape) {
  EvstImagePickerCropShapeSquare,
  EvstImagePickerCropShapeRectangle3x2,
  EvstImagePickerCropShapeCircle
};

@interface EvstImagePickerController : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, DZNPhotoPickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) EvstImagePickerCropShape cropShape;
@property (nonatomic, assign) BOOL searchInternetPhotosOption;
@property (nonatomic, assign) BOOL removePhotoOption;
@property (nonatomic, strong) NSString *searchInternetPhotosSearchTerm;

- (void)pickImageFromViewController:(UIViewController *)fromViewController completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler cancelled:(void (^)())cancelledHandler;
- (void)pickImageFromViewController:(UIViewController *)fromViewController completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler;
- (void)pickImageFromViewController:(UIViewController *)fromViewController sourceType:(UIImagePickerControllerSourceType)sourceType completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler;

@end
