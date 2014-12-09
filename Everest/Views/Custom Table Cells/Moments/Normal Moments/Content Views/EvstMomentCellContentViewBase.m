//
//  EvstMomentCellContentViewBase.m
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellContentViewBase.h"

@interface EvstMomentCellContentViewBase ()
@property (nonatomic, assign) dispatch_once_t onceToken;
@end

@implementation EvstMomentCellContentViewBase

#pragma mark - Class Init

- (id)init {
  return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonSetup];
  }
  return self;
}

#pragma mark - Setup

- (void)commonSetup {
  // Ensure this is only called once per instance, otherwise duplicate content
  // will be displayed in the cell
  dispatch_once(&_onceToken, ^{
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self setupView];
  });
}

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  ZAssert(NO, @"Subclasses should override this method and provide their own implementation.");
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  ZAssert(NO, @"Subclasses should override this method and provide their own implementation.");
}

- (void)prepareForReuse {
  ZAssert(NO, @"Subclasses should override this method and provide their own implementation.");
}

@end
