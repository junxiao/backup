//
//  PopUpMenuController.h
//  SketchDiary
//
//  Created by Jun Xiao on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDViewController.h"

@interface PopUpMenuController : UIViewController
{
    SDViewController *mycontroller;
    IBOutlet UIButton *loginButton;
}

@property(strong) UIButton *loginButton;

-(IBAction)photoMenuClick:(id)sender;
-(IBAction)newPageMenuClick:(id)sender;
-(IBAction)webMenuClick:(id)sender;
@property(strong) SDViewController *mycontroller;

-(void) setLoginButtonText:(NSString *)text;

@end
