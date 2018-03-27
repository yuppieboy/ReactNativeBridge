/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <UserNotifications/UserNotifications.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import "PassingManager.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate, RCTBridgeModule>

@end

@implementation AppDelegate

RCT_EXPORT_MODULE();

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (granted) {
        NSLog(@"register success");
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
          NSLog(@"%@", settings);
        }];
      } else {
        NSLog(@"register failed");
      }
    }];
  }else if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0){
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge categories:nil]];
  }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
  }
  // 注册获得device Token
  [[UIApplication sharedApplication] registerForRemoteNotifications];
  [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
  
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"AwesomeProject"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  return YES;
}

// 获得Device Token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"Device Token : %@", [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                stringByReplacingOccurrencesOfString: @">" withString: @""]
                               stringByReplacingOccurrencesOfString: @" " withString: @""]);
}

// 获得Device Token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
  
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  UNNotificationRequest *request = response.notification.request; // 收到推送的请求
  UNNotificationContent *content = request.content; // 收到推送的消息内容
  NSNumber *badge = content.badge;  // 推送消息的角标
  NSString *body = content.body;    // 推送消息体
  UNNotificationSound *sound = content.sound;  // 推送消息的声音
  NSString *subtitle = content.subtitle;  // 推送消息的副标题
  NSString *title = content.title;  // 推送消息的标题
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    NSLog(@"Receive Remote Notification Response:%@", userInfo);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notification Response" message:[self convertDictionaryToJsonString: userInfo] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [[PassingManager shareInstance] tellJS:@"normal"];
  }
  else {
    NSLog(@"Receive Local Notification Response:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
  }
  
  // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
  completionHandler();  // 系统要求执行这个
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  NSDictionary * userInfo = notification.request.content.userInfo;
  NSLog(@"Receive Remote Notification Response when App in foreground / Active :%@", userInfo);
  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Foreground Notification Response" message:[self convertDictionaryToJsonString: userInfo] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [alert show];
  [[PassingManager shareInstance] tellJS:@"foreground"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  NSLog(@"Receive Remote Notification Response when App in Background :%@", userInfo);
  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Background Notification Response" message:[self convertDictionaryToJsonString: userInfo] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
  [alert show];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_TEST" object:nil];
  [[PassingManager shareInstance] tellJS:@"Background"];
  completionHandler(UIBackgroundFetchResultNewData);
}

-(void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_TEST" object:nil];
  [[PassingManager shareInstance] tellJS:@"BackgroundFetch"];
  completionHandler(UIBackgroundFetchResultNewData);
}

- (NSString *)convertDictionaryToJsonString:(NSDictionary *)userInfo {
  NSError *err;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&err];
  NSString *message = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  return [NSString stringWithFormat:@"%@, \n time --> %@", message, [self currentTime]];
}

- (NSString *)currentTime{
  NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
  [formatter setDateFormat:@"MM-dd HH:mm:ss"];
  NSString *dateTime = [formatter stringFromDate:[NSDate date]];
  return dateTime;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
