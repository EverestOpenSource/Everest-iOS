//
//  NSDate+EvstAdditions.m
//  Everest
//
//  Created by Rob Phillips on 1/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "NSDate+EvstAdditions.h"

@implementation NSDate (EvstAdditions)

#pragma mark - Calendars

+ (NSCalendar *)evstGregorianCalendar {
  static NSCalendar *gregorian;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  });
  return gregorian;
}

#pragma mark - Formatters

+ (NSDateFormatter *)evstDayMonthDateFormatter {
  static NSDateFormatter *dayMonthDateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dayMonthDateFormatter = [[NSDateFormatter alloc] init];
    [dayMonthDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMM" options:0 locale:[NSLocale currentLocale]];
    [dayMonthDateFormatter setDateFormat:dateFormat];
  });
  return dayMonthDateFormatter;
}

+ (NSDateFormatter *)evst_yearDayMonthDateFormatter {
  static NSDateFormatter *yearDayMonthDateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    yearDayMonthDateFormatter = [[NSDateFormatter alloc] init];
    [yearDayMonthDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyddMMM" options:0 locale:[NSLocale currentLocale]];
    [yearDayMonthDateFormatter setDateFormat:dateFormat];
  });
  return yearDayMonthDateFormatter;
}

#pragma mark - Relative Time

- (NSString *)relativeTimeLongString {
  return [self relativeTimeStringFromDate:[NSDate date]];
}

- (NSString *)relativeTimeShortString {
  return [self relativeTimeStringFromDate:[NSDate date] withBorderDate:nil longStyle:NO];
}

- (NSString *)relativeTimeStringFromDate:(NSDate *)date {
  return [self relativeTimeStringFromDate:date withBorderDate:nil];
}

- (NSString *)relativeTimeStringWithBorderDate:(NSDate *)borderDate longStyle:(BOOL)longStyle {
  return [self relativeTimeStringFromDate:[NSDate date] withBorderDate:borderDate longStyle:longStyle];
}

- (NSString *)relativeTimeStringFromDate:(NSDate *)date withBorderDate:(NSDate *)borderDate {
  return [self relativeTimeStringFromDate:date withBorderDate:borderDate longStyle:YES];
}

- (NSString *)relativeTimeStringFromDate:(NSDate *)date withBorderDate:(NSDate *)borderDate longStyle:(BOOL)longStyle {
  if (borderDate) {
    NSCalendar *gregorian = [NSDate evstGregorianCalendar];
    NSDateComponents *selfComponents = [gregorian components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit fromDate:date];
    // If we're no longer within this year, return a longer format with the year included
    if (selfComponents.year != nowComponents.year) {
      return [[NSDate evst_yearDayMonthDateFormatter] stringFromDate:self];
    }
    // If we're still within this year, return a shorter format without the year included
    if ([self compare:borderDate] == NSOrderedAscending) {
      return [[NSDate evstDayMonthDateFormatter] stringFromDate:self];
    }
  }

  static NSUInteger kSecPerMin = 60;
  static NSUInteger kMinPerHour = 60;
  static NSUInteger kHourPerDay = 24;

  // TODO (EVENTUALLY) Convert this to use NSCalendar for support of leap years, DST, etc.
  NSUInteger secondsAgo = (NSUInteger)fabs(lroundf((float)[self timeIntervalSinceDate:date]));
  NSUInteger minutes = secondsAgo / kSecPerMin;
  NSUInteger hours = secondsAgo / (kMinPerHour * kSecPerMin);
  NSUInteger days = secondsAgo / (kHourPerDay * kMinPerHour * kSecPerMin);
  
  // Note: Per design, we don't show a short form version of year and month
  if (longStyle && days > 365) {
    NSUInteger years = days / 365;
    return [NSString stringWithFormat: (years == 1) ? kLocaleXYearFormat : kLocaleXYearsFormat, years];
  } else if (longStyle && days > 30) {
    NSUInteger months = days / 30;
    return [NSString stringWithFormat: (months == 1) ? kLocaleXMonthFormat : kLocaleXMonthsFormat, months];
  } else if (days >= 7) {
    NSUInteger weeks = days / 7;
    NSString *singularOrPlural = weeks == 1 ? kLocaleXWeekFormat : kLocaleXWeeksFormat;
    return [NSString stringWithFormat:longStyle ? singularOrPlural : kLocaleShortXWeeksFormat, weeks];
  } else if (days >= 1) {
    NSString *singularOrPlural = days == 1 ? kLocaleXDayFormat : kLocaleXDaysFormat;
    return [NSString stringWithFormat:longStyle ? singularOrPlural : kLocaleShortXDaysFormat, days];
  } else if (hours >= 1) {
    NSString *singularOrPlural = hours == 1 ? kLocaleXHourFormat : kLocaleXHoursFormat;
    return [NSString stringWithFormat:longStyle ? singularOrPlural : kLocaleShortXHoursFormat, hours];
  } else if (minutes >= 1) {
    NSString *singularOrPlural = minutes == 1 ? kLocaleXMinuteFormat : kLocaleXMinutesFormat;
    return [NSString stringWithFormat:longStyle ? singularOrPlural : kLocaleShortXMinutesFormat, minutes];
  } else {
    NSString *singularOrPlural = secondsAgo == 1 ? kLocaleXSecondFormat : kLocaleXSecondsFormat;
    return [NSString stringWithFormat:longStyle ? singularOrPlural : kLocaleShortXSecondsFormat, secondsAgo];
  }
}

@end
