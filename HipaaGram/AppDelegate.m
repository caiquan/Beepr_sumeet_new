/*
 * Copyright (C) 2014 Catalyze, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "AppDelegate.h"
#import "Catalyze.h"

//--------------------------------------
#import "AppConstant.h"
#import "RecentView.h"
#import "GroupsView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import "NavigationController.h"
#import "common.h"
#import "ProgressHUD.h"
#import <UbertestersSDK/Ubertesters.h>

@interface AppDelegate()
@property (strong, nonatomic) SignInViewController *signInViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    [UAirship push].userNotificationTypes = (UIUserNotificationTypeBadge|
                                             UIUserNotificationTypeSound|
                                             UIUserNotificationTypeAlert);
    
    [UAirship push].userPushNotificationsEnabled = YES;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [Catalyze setApiKey:@"58302dcc-ff28-4a79-973e-b03c594066c5" applicationId:@"76ea4a58-be5c-45bc-acc5-f23a159da6dd"];
    [Catalyze setLoggingLevel:kLoggingLevelDebug];
    
    //----------------------------------------------------------------------------------------------------------------
    self.recentView = [[RecentView alloc] init];
    self.groupsView = [[GroupsView alloc] init];
    self.peopleView = [[PeopleView alloc] init];
    self.settingsView = [[SettingsView alloc] init];
    
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.recentView];
    NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
    NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
    NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.settingsView];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.selectedIndex = DEFAULT_TAB;
    
    self.window.rootViewController = self.tabBarController;
   	[self.window makeKeyAndVisible];
    
//    [[Ubertesters shared] initialize];
    //----------------------------------------------------------------------------------------------------------------
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PostNotification(NOTIFICATION_APP_STARTED);
    [self locationManagerStart];
    // Set the icon badge to zero on resume (optional)
    [[UAirship push] resetBadge];
//    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (_handler) {
        [_handler handleNotification:[[userInfo objectForKey:@"notification"] valueForKey:@"alert"]];
    }
    
    // Reset the badge after a push is received in a active or inactive state
    if (application.applicationState != UIApplicationStateBackground) {
        [[UAirship push] resetBadge];
    }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - UAPushNotificationDelegate

- (void)displayNotificationAlert:(NSString *)alertMessage {//"You have a new message on Beepr"
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [[[UIAlertView alloc] initWithTitle:@"Beepr" message:@"You have a new message on Beepr" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else if (_handler) {
        [_handler handleNotification:alertMessage];
    }
}

- (void)receivedForegroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)launchedFromNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - Location manager methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManagerStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self.coordinate = newLocation.coordinate;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
}

@end
