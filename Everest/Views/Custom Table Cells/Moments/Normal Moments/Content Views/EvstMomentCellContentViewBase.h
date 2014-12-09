//
//  EvstMomentCellContentViewBase.h
//  Everest
//
//  Created by Rob Phillips on 2/5/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestMoment.h"

@protocol EvstMomentCellContentViewProtocol <NSObject>
- (void)setupView;
- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options;
- (void)prepareForReuse;
@end

@interface EvstMomentCellContentViewBase : UIView <EvstMomentCellContentViewProtocol>

@property (nonatomic, strong) EverestMoment *moment;

@end
