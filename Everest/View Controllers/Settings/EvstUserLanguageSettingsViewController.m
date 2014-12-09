//
//  EvstUserLanguageSettingsViewController.m
//  Everest
//
//  Created by Rob Phillips on 2/25/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstUserLanguageSettingsViewController.h"
#import "EvstLanguageSettingCell.h"
#import "TTTAttributedLabel.h"

static NSString *cellIdentifier = @"LanguageNameCell";
static NSString *languageNameKey = @"LanguageName";
static NSString *languageCodeKey = @"ISO639-1_Code";
#define kFontLanguageSettingHeaderFont kFontHelveticaNeue13

@interface EvstUserLanguageSettingsViewController ()
@property (nonatomic, strong) NSArray *supportedLanguages;
@property (nonatomic, assign) CGFloat headerHeight;
@end

@implementation EvstUserLanguageSettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = kLocaleDiscoverLanguage;
  [self.tableView registerClass:[EvstLanguageSettingCell class] forCellReuseIdentifier:cellIdentifier];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
}

#pragma mark - Supported Languages

- (NSArray *)supportedLanguages {
  if (_supportedLanguages) {
    return _supportedLanguages;
  }
  return [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EvstLanguageCodes" ofType:@"plist"]];
}

#pragma mark - Header Calcs

- (CGFloat)headerHeight {
  if (_headerHeight) {
    return _headerHeight;
  }
  CGSize textSize = CGSizeMake([self headerContentWidth], CGFLOAT_MAX);
  CGRect textRect = [kLocaleLanguageSettingDescription boundingRectWithSize:textSize
                                                                    options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                 attributes:@{ NSFontAttributeName : kFontLanguageSettingHeaderFont }
                                                                    context:nil];
  CGSize size = textRect.size;
  _headerHeight = round(size.height + 4.f * kEvstDefaultPadding);
  return _headerHeight;
}

- (CGFloat)headerContentWidth {
  return kEvstMainScreenWidth - (4 * kEvstDefaultPadding);
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return [self headerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, [self headerHeight])];
  headerView.backgroundColor = kColorOffWhite;
  // Title
  TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(2 * kEvstDefaultPadding, 0.f, [self headerContentWidth], [self headerHeight])];
  titleLabel.font = kFontLanguageSettingHeaderFont;
  titleLabel.textColor = kColorBlack;
  titleLabel.numberOfLines = 0;
  titleLabel.textAlignment = NSTextAlignmentLeft;
  titleLabel.lineHeightMultiple = 1.2f;
  titleLabel.accessibilityLabel = kLocaleLanguageSettingDescription;
  [headerView addSubview:titleLabel];
  [titleLabel setText:kLocaleLanguageSettingDescription];
  // Bottom separator
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, headerView.frame.size.height - 0.5f, kEvstMainScreenWidth, 0.5f)];
  bottomSeparator.image = [EvstCommon tableSeparatorLine];
  [headerView addSubview:bottomSeparator];
  return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.supportedLanguages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  cell.textLabel.text = cell.textLabel.accessibilityLabel = [[self.supportedLanguages objectAtIndex:indexPath.row] objectForKey:languageNameKey];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstUserChosenLanguageDidChangeNotification object:[[self.supportedLanguages objectAtIndex:indexPath.row] objectForKey:languageCodeKey]];
  // JOSH We need server support for saving this setting and showing a "selected" state
  [self.navigationController popViewControllerAnimated:YES];
}

@end
