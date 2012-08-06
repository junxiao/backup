//
//  PopUpMenuController.m
//  SketchDiary
//
//  Created by Jun Xiao on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopUpMenuController.h"

@interface PopUpMenuController ()

@end

@implementation PopUpMenuController

@synthesize mycontroller, loginButton;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)photoMenuClick:(id)sender
{
    [mycontroller photoMenuClick];
}
-(IBAction)webMenuClick:(id)sender
{
    [mycontroller webMenuClick];
    
}

-(IBAction)newPageMenuClick:(id)sender;
{
    [mycontroller newPageMenuClick];
}

-(void) setLoginButtonText:(NSString *)text
{
    [loginButton setTitle:text forState:UIControlStateNormal];
}


@end
