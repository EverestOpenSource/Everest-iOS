//
//  EvstUserViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentTableViewController.h"
#import "EverestUser.h"

@interface EvstUserViewController : EvstMomentTableViewController

@property (nonatomic, strong) EverestUser *user;
@property (nonatomic, assign) BOOL showWithMenuIcon;

@end
