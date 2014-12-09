//
//  EvstMockUserPut.h
//  Everest
//
//  Created by Chris Cornelis on 02/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockUserBase.h"

@interface EvstMockUserPut : EvstMockUserBase

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
