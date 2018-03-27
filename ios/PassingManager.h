//
//  PassingManager.h
//  AwesomeProject
//
//  Created by Paul on 3/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface PassingManager : RCTEventEmitter <RCTBridgeModule>
+ (instancetype)shareInstance;
- (void)tellJS:(NSString *)message;

@end
