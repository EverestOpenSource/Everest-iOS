//
//  EvstAttributedLabel.h
//  Everest
//
//  Created by Rob Phillips on 2/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "TTTAttributedLabel.h"
#import "EverestJourney.h"

@interface EvstAttributedLabel : TTTAttributedLabel

@property (nonatomic, strong) EverestUser *user;
@property (nonatomic, strong) EverestJourney *journey;

@end
