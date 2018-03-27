//
//  PassingManager.m
//  AwesomeProject
//
//  Created by Paul on 3/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "PassingManager.h"

@implementation PassingManager

RCT_EXPORT_MODULE();

+ (id)allocWithZone:(NSZone *)zone {
  static PassingManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [super allocWithZone:zone];
  });
  return sharedInstance;
}

+ (instancetype)shareInstance {
  return [self allocWithZone:nil];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"EventReminder"];
}


- (void)tellJS:(NSString *)message
{
  [self sendEventWithName:@"EventReminder" body:message];
}

RCT_EXPORT_METHOD(tellClient)
{
  NSLog(@"yahaha");
}

@end
