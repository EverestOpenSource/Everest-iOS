//
//  EvstJourneyCoverCell.m
//  Everest
//
//  Created by Rob Phillips on 1/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstJourneyCoverCell.h"
#import "EvstJourneyCoverCellContentView.h"

@interface EvstJourneyCoverCell ()
@property (nonatomic, strong) EvstJourneyCoverCellContentView *cellContentView;
@end

@implementation EvstJourneyCoverCell

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)awakeFromNib {
  [self commonSetup];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  
  [self.cellContentView prepareForReuse];
}

- (void)commonSetup {
  // Cell defaults
  self.opaque = YES;
  self.backgroundColor = kColorWhite;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  
  // Add the content view where we do custom drawing
  self.cellContentView = [[EvstJourneyCoverCellContentView alloc] init];
  [self.contentView addSubview:self.cellContentView];
  UIView *superview = self.contentView;
  [self.cellContentView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview);
  }];
}

#pragma mark - Cover photo

- (UIImage *)coverPhotoImage {
  return self.cellContentView.coverPhotoImageView.image;
}

- (void)setCoverPhotoImage:(UIImage *)coverImage {
  self.cellContentView.coverPhotoImageView.image = coverImage;
}

#pragma mark - Configure

- (void)configureWithJourney:(EverestJourney *)journey showingInList:(BOOL)showingInList {
  [self.cellContentView configureWithJourney:journey showingInList:showingInList];
  self.accessibilityLabel = journey.name;
}

@end
