//
//  EvstLanguageSettingCell.m
//  Everest
//
//  Created by Rob Phillips on 2/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLanguageSettingCell.h"

@implementation EvstLanguageSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.font = kFontHelveticaNeueLight15;
  }
  return self;
}

@end
