//
//  NATabBarItem.h
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-12.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NATabBarItem : UIButton {
    __weak UIButton *_badge;
}

- (void)setBadgeValue:(NSString *)badgeValue;
- (void)becomeObserverForObject:(id)object;

@property (nonatomic, assign) BOOL isInMoreMenu;
@property (nonatomic, retain) id observedObject;

@end
