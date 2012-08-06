//
//  SDAppDelegate.m
//  SketchDiary
//
//  Created by Jun Xiao on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDAppDelegate.h"
#import <Parse/Parse.h>
#include "SDViewController.h"
#include "UIImage+Resize.h"
#include "MBProgressHUD.h"

@implementation SDAppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"L9e5Z4XhWhPVonpP5d9q7eZGgEndi9XF8XGndjHE"
                  clientKey:@"W3VkpwMdWtY6cBzq6kjrMytU9t9ySgb6iPhmAH35"];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSNumber *val = nil;
    
	if (standardUserDefaults) 
    {
		val = [standardUserDefaults objectForKey:@"logOut_preference"];
    }
    else {
        NSLog(@"Unable to save user defaults");
        return  YES;
    }
    if(val)
    {
        if([val boolValue] == YES)
        {
            [PFUser logOut];
        }
        else {
            PFUser *currentUser = [PFUser currentUser];
            if(!currentUser)
            {
                NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"name_preference"];
                NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password_preference"]; 
                [PFUser logInWithUsernameInBackground:username password:password];
            }
        }

    }

    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
 //   NSString *rawText = [url host];
    
 //   NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *text = [url host];
    
    NSLog(@"%@", text);
 //   NSLog(@"%@, %@", rawText, text);
    NSString *username = [[text componentsSeparatedByString:@"+-*8"] objectAtIndex:0];
    NSString *password = [text substringFromIndex:[username length]+4];
    
    NSLog(@"%@, %@", username, password);
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	if (standardUserDefaults) {
		[standardUserDefaults setObject:username forKey:@"name_preference"];
		[standardUserDefaults setObject:password forKey:@"password_preference"];
		[standardUserDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"logOut_preference"];
		[standardUserDefaults synchronize];
	} else {
		NSLog(@"Unable to save user defaults");
	}


    [PFUser logInWithUsernameInBackground:username password:password 
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {

                                            NSLog(@"login successful\n");
                                            UIAlertView *alertView;
                                            alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Share account with your family or friends." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            alertView.tag = 100;
                                            [alertView setDelegate:self];
                                            [alertView show];
                                            
                                           
                                        } else {
                                            NSLog(@"login failed\n");
                                            
                                            UIAlertView *alertView;
                                            alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alertView show];

                                            // The login failed. Check error to see why.
                                        }
                                    }];
    return YES;
} 


- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100) {
        
        UIView *myview = [[[self window] rootViewController] view];
        HUD = [[MBProgressHUD alloc] initWithView:myview];
        HUD.labelText = @"Uploading diary...";
        [myview addSubview:HUD];
        
        [HUD showWhileExecuting:@selector(uploadFiles) onTarget:self withObject:nil animated:YES];


    //   [self uploadFiles];
    } 
}

- (void) uploadFiles
{
    SDViewController *myviewcontroller = (SDViewController *)[[self window] rootViewController];
    [myviewcontroller syncFiles];
}

/*-(void) uploadFiles
{
    NSString *filename;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diaryDirectoryPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"diaryImages"];
    NSString *diaryPath;
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filelist.plist"]; 
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    int numberofEntries = [[savedStock objectForKey:@"fileCount"] intValue];
    HUD.progress = 0;
    float progressDelta =  1.0/ numberofEntries;
 
    for (int i=1; i <= numberofEntries; i++) 
    {
        filename = [NSString stringWithFormat: @"%d-s.png", i];
        diaryPath = [diaryDirectoryPath stringByAppendingPathComponent:filename]; 
        if ([[NSFileManager defaultManager] fileExistsAtPath:diaryPath]) 
        {
            PFQuery *query = [PFQuery queryWithClassName:@"DiaryEntry"];
            [query whereKey:@"user" equalTo:currentUser];
            [query whereKey:@"Counter" equalTo:[NSString stringWithFormat: @"%d", i]];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    if (count == 0)
                    {
                        UIImage *img = [UIImage imageWithContentsOfFile:diaryPath];
                        NSData *imageData = UIImagePNGRepresentation(img);
                        PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                        [imageFile saveInBackground];
                        PFObject *userPhoto = [PFObject objectWithClassName:@"DiaryEntry"];
                        [userPhoto setObject:[NSNumber numberWithInt:i] forKey:@"Counter"];
                        NSString *keyString = [NSString stringWithFormat: @"%d", i];
                        NSString *dateString = [savedStock objectForKey:keyString];
                        [userPhoto setObject:dateString forKey:@"Date"];
                        [userPhoto setObject:imageFile forKey:@"imageFile"];
                        [userPhoto setObject:currentUser forKey:@"user"];
                        [userPhoto saveInBackground];

                    }
                } else {
                    // The request failed
                }
            }];
            HUD.progress = HUD.progress + progressDelta;
        }
        else {
            //file does not exist
        }
    }
    
    HUD.progress = 1.0;
} */
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  //  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
  //  [defaults setObject:firstName forKey:@"firstName"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
/*    SDViewController *controller = (SDViewController *)[[self window] rootViewController];
    [controller forwardButtonClick:nil]; */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
