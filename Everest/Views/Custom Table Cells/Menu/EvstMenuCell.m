//
//  EvstMenuCell.m
//  Everest
//
//  Created by Rob Phillips on 1/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMenuCell.h"

@implementation EvstMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.menuItemLabel.textColor = kColorPanelBlack;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

@end
