//
//  SDAppDelegate.h
//  SketchDiary
//
//  Created by Jun Xiao on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>
{
     MBProgressHUD *HUD;
}

@property (strong, nonatomic) UIWindow *window;

@end
