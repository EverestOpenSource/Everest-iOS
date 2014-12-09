//
//  EvstSocialAccountsViewController.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface EvstSocialAccountsViewController : UITableViewController

@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, copy) void (^didChooseAccountHandler)(ACAccount *chosenAccount);
@property (nonatomic, copy) void (^didCancelHandler)();

@end
