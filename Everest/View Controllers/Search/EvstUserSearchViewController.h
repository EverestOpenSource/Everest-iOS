//
//  EvstUserSearchViewController.h
//  Everest
//
//  Created by Rob Phillips on 2/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserTableView.h"
#import <MessageUI/MessageUI.h>

@interface EvstUserSearchViewController : UIViewController <UISearchBarDelegate, EvstUserTableViewDatasource, EvstUserTableViewDelegate, UIScrollViewDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) BOOL wasShownFromSettings;

@end
