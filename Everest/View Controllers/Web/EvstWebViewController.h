//
//  EvstWebViewController.h
//  Everest
//
//  Created by Rob Phillips on 2/27/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "PBWebViewController.h"

@interface EvstWebViewController : PBWebViewController

+ (void)presentWithURL:(NSURL *)url inViewController:(UIViewController *)viewController;
+ (void)presentWithURLString:(NSString *)urlString inViewController:(UIViewController *)viewController;

@end
