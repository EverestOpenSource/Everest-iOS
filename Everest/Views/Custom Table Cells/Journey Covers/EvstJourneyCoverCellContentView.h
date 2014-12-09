//
//  EvstJourneyCoverCellContentView.h
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestJourney.h"

@interface EvstJourneyCoverCellContentView : UIView

@property (nonatomic, strong) UIImageView *coverPhotoImageView;

- (void)prepareForReuse;
- (void)configureWithJourney:(EverestJourney *)journey showingInList:(BOOL)showingInList;

@end
