//
//  AppDelegate.h
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-12-11.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NATabBarController.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NATabBarController *tabBarController;

@end
