//
//  EvstLikersViewController.h
//  Everest
//
//  Created by Rob Phillips on 6/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserTableView.h"

@interface EvstLikersViewController : UIViewController <EvstUserTableViewDatasource, EvstUserTableViewDelegate>

@property (nonatomic, strong) EverestMoment *moment;

@end
