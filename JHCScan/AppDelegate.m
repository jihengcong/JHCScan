//
//  AppDelegate.m
//  JHCScan
//
//  Created by mac on 2020/10/21.
//

#import "AppDelegate.h"
#import "ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    
    UITabBarController *rootController = [[UITabBarController alloc] init];
    rootController.viewControllers = @[nav];
    
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
