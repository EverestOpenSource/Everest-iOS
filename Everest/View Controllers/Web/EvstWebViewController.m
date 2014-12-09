//
//  EvstWebViewController.m
//  Everest
//
//  Created by Rob Phillips on 2/27/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstWebViewController.h"

@implementation EvstWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[self cancelButtonImage] style:UIBarButtonItemStylePlain target:self action:@selector(didPressDismiss:)];
  cancelButton.accessibilityLabel = kLocaleCancel;
  self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Convenience Methods

+ (void)presentWithURL:(NSURL *)url inViewController:(UIViewController *)viewController {
  EvstWebViewController *webVC = [[EvstWebViewController alloc] init];
  webVC.URL = url;
  EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:webVC];
  [viewController presentViewController:navVC animated:YES completion:nil];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewWebLink];
}

+ (void)presentWithURLString:(NSString *)urlString inViewController:(UIViewController *)viewController {
  [self presentWithURL:[NSURL URLWithString:urlString] inViewController:viewController];
}

#pragma mark - Navigation Button

// Draws an X in a similar line-style as the web view controls
- (UIImage *)cancelButtonImage {
  static UIImage *image;
  
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    static CGFloat edgeSize = 16.f;
    CGSize size = CGSizeMake(edgeSize, edgeSize);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.5f;
    path.lineCapStyle = kCGLineCapButt;
    path.lineJoinStyle = kCGLineJoinMiter;
    [path moveToPoint:CGPointMake(0.f, 0.f)];
    [path addLineToPoint:CGPointMake(edgeSize / 2.f, edgeSize / 2.f)];
    [path addLineToPoint:CGPointMake(0.f, edgeSize)];
    [path stroke];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    path2.lineWidth = 1.5f;
    path2.lineCapStyle = kCGLineCapButt;
    path2.lineJoinStyle = kCGLineJoinMiter;
    [path2 moveToPoint:CGPointMake(edgeSize, 0.f)];
    [path2 addLineToPoint:CGPointMake(edgeSize / 2.f, edgeSize / 2.f)];
    [path2 addLineToPoint:CGPointMake(edgeSize, edgeSize)];
    [path2 stroke];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  });
  
  return image;
}

#pragma mark - IBActions

- (IBAction)didPressDismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}


@end
