//
//  EvstMenuCell.h
//  Everest
//
//  Created by Rob Phillips on 1/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstMenuCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *menuItemBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *menuItemIcon;
@property (nonatomic, weak) IBOutlet UILabel *menuItemLabel;

@end
