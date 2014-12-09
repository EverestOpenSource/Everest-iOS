//
//  EvstBooleanTransformer.m
//  Everest
//
//  Created by Rob Phillips on 3/31/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstBooleanTransformer.h"

@implementation EvstBooleanTransformer

+ (instancetype)defaultTransformer {
  return [[EvstBooleanTransformer alloc] init];
}

- (BOOL)validateTransformationFromClass:(Class)inputValueClass toClass:(Class)outputValueClass {
  return ([inputValueClass isSubclassOfClass:NSClassFromString(@"__NSCFNumber")] &&
          [outputValueClass isSubclassOfClass:NSClassFromString(@"__NSCFBoolean")]);
}

- (BOOL)transformValue:(id)inputValue toValue:(id *)outputValue ofClass:(Class)outputValueClass error:(NSError **)error {
  RKValueTransformerTestInputValueIsKindOfClass(inputValue, (@[ NSClassFromString(@"__NSCFNumber") ]), error);
  RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, (@[ NSClassFromString(@"__NSCFBoolean") ]), error);
  
  if ([inputValue isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
    *outputValue = ([inputValue boolValue] == YES) ? @(YES) : @(NO);
  } else if ([inputValue isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
    *outputValue = [inputValue isEqual:@(YES)] ? @1 : @0;
  }
  return YES;
}

@end
