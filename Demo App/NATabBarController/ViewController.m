//
//  ViewController.m
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-12-11.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[self randomColor]];
    
    if([[self.navigationController viewControllers] count] == 0) return;
    
    if([[self.navigationController viewControllers] objectAtIndex:0] == self) {
        if(arc4random() % 2 == 0) {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Push" style:UIBarButtonItemStyleBordered target:self action:@selector(push)]];
        }
        else {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Push & Hide" style:UIBarButtonItemStyleBordered target:self action:@selector(pushAndHide)]];
        }
        
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Toggle Badge" style:UIBarButtonItemStyleBordered target:self action:@selector(badge)]];        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)push
{
    ViewController *vc = [[ViewController alloc] init];
    [vc.view setBackgroundColor:[UIColor whiteColor]];
    [vc setTitle:@"Pushed VC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushAndHide
{
    ViewController *vc = [[ViewController alloc] init];
    [vc.view setBackgroundColor:[UIColor whiteColor]];
    [vc setTitle:@"Pushed VC"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)badge
{
    if(self.tabBarItem.badgeValue) {
        [self.tabBarItem setBadgeValue:nil];
    }
    else {
        [self.tabBarItem setBadgeValue:@"99"];
    }
}

- (UIColor *)randomColor
{
    CGFloat r = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat g = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat b = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end
