//
//  EvstImagePickerController.m
//  Everest
//
//  Created by Chris Cornelis on 01/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstImagePickerController.h"
#import "EvstImageEditorViewController.h"
#import "UIImage+EvstAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EvstImagePickerController()

@property (nonatomic, weak) UIViewController *showFromViewController;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) DZNPhotoPickerController *searchInternetImagePicker;
@property (nonatomic, copy) void(^completionBlock)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics);
@property (nonatomic, copy) void(^cancelledBlock)();
@property (nonatomic, strong) NSString *sourceForAnalytics;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, strong) NSDate *takenAtDate;
@end

@implementation EvstImagePickerController

#pragma mark - Class methods

- (void)pickImageFromViewController:(UIViewController *)fromViewController completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler {
  [self pickImageFromViewController:fromViewController completion:completionHandler cancelled:nil];
}

- (void)pickImageFromViewController:(UIViewController *)fromViewController completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler cancelled:(void (^)())cancelledHandler {
  self.showFromViewController = fromViewController;
  self.completionBlock = completionHandler;
  self.cancelledBlock = cancelledHandler;
  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    if (self.searchInternetPhotosOption) {
      [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleTakePhoto, kLocaleChooseExisting, kLocaleSearchTheWeb, nil] showInView:fromViewController.view];
    } else {
      [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle: self.removePhotoOption ? kLocaleRemovePhoto : nil otherButtonTitles:kLocaleTakePhoto, kLocaleChooseExisting, nil] showInView:fromViewController.view];
    }
  } else {
    if (self.searchInternetPhotosOption) {
      [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleChooseExisting, kLocaleSearchTheWeb, nil] showInView:fromViewController.view];
    } else {
      if (self.removePhotoOption) {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleRemovePhoto otherButtonTitles:kLocaleChooseExisting, nil] showInView:fromViewController.view];
      } else {
        [self showWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
      }
    }
  }
}

- (void)pickImageFromViewController:(UIViewController *)fromViewController sourceType:(UIImagePickerControllerSourceType)sourceType completion:(void (^)(UIImage *editedImage, NSDate *takenAtDate, NSString *sourceForAnalytics))completionHandler {
  self.showFromViewController = fromViewController;
  self.completionBlock = completionHandler;
  [self showWithSource:sourceType];
}

#pragma mark - Convenience methods

- (void)showWithSource:(UIImagePickerControllerSourceType)sourceType {
  self.imagePicker = [[UIImagePickerController alloc] init];
  self.imagePicker.sourceType = sourceType;
  self.imagePicker.delegate = self;
  
  [self.showFromViewController presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    if (self.cancelledBlock) {
      self.cancelledBlock();
    }
    return;
  }
  
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleTakePhoto]) {
    self.sourceForAnalytics = kEvstAnalyticsTakePhoto;
    
    [self showWithSource:UIImagePickerControllerSourceTypeCamera];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleChooseExisting]) {
    self.sourceForAnalytics = kEvstAnalyticsChooseExisting;
    
    [self showWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleSearchTheWeb]) {
    self.sourceForAnalytics = kEvstAnalyticsSearchWeb;
    
    self.searchInternetImagePicker = [[DZNPhotoPickerController alloc] init];
    self.searchInternetImagePicker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
    self.searchInternetImagePicker.allowsEditing = NO;
    self.searchInternetImagePicker.delegate = self;
    self.searchInternetImagePicker.initialSearchTerm = self.searchInternetPhotosSearchTerm;
    [self.showFromViewController presentViewController:self.searchInternetImagePicker animated:YES completion:nil];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleRemovePhoto]) {
    self.completionBlock(nil, nil, nil);
  }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    // Meta data
    self.metaData = [info objectForKey:UIImagePickerControllerMediaMetadata];
    
    // Save the original image and meta data to the Camera Roll if user took a photo
    [library writeImageToSavedPhotosAlbum:originalImage.CGImage metadata:self.metaData completionBlock:nil];
    [self editImage:originalImage picker:picker];
  } else {
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
      self.metaData = asset.defaultRepresentation.metadata;
      self.takenAtDate = [asset valueForProperty:ALAssetPropertyDate];
      [self editImage:originalImage picker:picker];
    } failureBlock:^(NSError *error) {
      [self editImage:originalImage picker:picker];
    }];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self.showFromViewController dismissViewControllerAnimated:YES completion:^{
    if (self.cancelledBlock) {
      self.cancelledBlock();
    }
  }];
}

#pragma mark - DZNPhotoPickerControllerDelegate

- (void)photoPickerController:(DZNPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)userInfo {
  UIImage *originalImage = (UIImage *)[userInfo objectForKey:UIImagePickerControllerOriginalImage];
  [self editImage:originalImage picker:picker];
}

- (void)photoPickerControllerDidCancel:(DZNPhotoPickerController *)picker {
  [self.showFromViewController dismissViewControllerAnimated:YES completion:^{
    if (self.cancelledBlock) {
      self.cancelledBlock();
    }
  }];
}

#pragma mark - Image editing

- (void)editImage:(UIImage *)image picker:(UINavigationController *)picker {
  EvstImageEditorViewController *imageEditor = [[EvstImageEditorViewController alloc] initWithNibName:@"EvstImageEditor" bundle:nil];
  imageEditor.sourceImage = image;
  imageEditor.cropShape = self.cropShape;
  imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled) {
    if (canceled) {
      [picker dismissViewControllerAnimated:YES completion:nil]; // Dismiss the editor but keep showing the standard image picker
      return;
    }
    
    // Image resizing should be done on a background thread to avoid UI stuttering
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      // The images we send to the server should have a maximum resolution of 1000x1000. Since they are square or rectangular, the width shouldn't exceed 1000 pixels.
      UIImage *resizedImage = [editedImage resizeWithMaxWidth:kEvstImageMaxResolution];
      dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:^{ // Dismiss the editor
          [picker dismissViewControllerAnimated:YES completion:^{ // Dismiss the picker
            if (self.completionBlock) {
              self.completionBlock(resizedImage, self.takenAtDate, self.sourceForAnalytics);
            }
          }];
        }];
      });
    });
  };
  
  // Ensure this is always called on the main thread http://crashes.to/s/f462ca468e2
  dispatch_async(dispatch_get_main_queue(), ^{
    [picker presentViewController:imageEditor animated:YES completion:nil];
  });
}

@end
