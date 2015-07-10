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

#import <UIKit/UIKit.h>
#import "SignInViewController.h"
#import "ConversationListViewController.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "ConversationViewController.h"

#import "RecentView.h"
#import "GroupsView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,  CLLocationManagerDelegate, UAPushNotificationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<PushNotificationHandler> handler;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) RecentView *recentView;
@property (strong, nonatomic) GroupsView *groupsView;
@property (strong, nonatomic) PeopleView *peopleView;
@property (strong, nonatomic) SettingsView *settingsView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
