//
//  EvstFollowersViewController.h
//  Everest
//
//  Created by Chris Cornelis on 02/04/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserTableView.h"

@interface EvstFollowersViewController : UIViewController <EvstUserTableViewDatasource, EvstUserTableViewDelegate>

@property (nonatomic, strong) EverestUser *user;

@end
