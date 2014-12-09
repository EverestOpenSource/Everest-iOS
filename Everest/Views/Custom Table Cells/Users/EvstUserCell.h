//
//  EvstUserCell.h
//  Everest
//
//  Created by Chris Cornelis on 02/06/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface EvstUserCell : UITableViewCell

+ (CGFloat)fullNameTextXOffset;

- (void)configureWithUser:(EverestUser *)user;

@end
