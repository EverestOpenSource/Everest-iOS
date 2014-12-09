//
//  EvstKnockoutLabel.h
//  Everest
//
//  Created by Chris Cornelis on 03/03/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

@interface EvstKnockoutLabel : UILabel

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSString *knockoutText;
@property (nonatomic, strong) NSDictionary *knockoutTextAttributes;
@property (nonatomic, strong) NSAttributedString *knockoutAttributedText;

@end
