//
//  EvstJourneysListViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/22/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCoverListViewController.h"
#import "EverestUser.h"

@interface EvstJourneysListViewController : EvstJourneyCoverListViewController <UIActionSheetDelegate>

@property (nonatomic, strong) EverestUser *user;
@property (nonatomic, assign) BOOL showWithMenuIcon;

@end
