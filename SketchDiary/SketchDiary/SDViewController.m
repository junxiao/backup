//
//  SDViewController.m
//  SketchDiary
//
//  Created by Jun Xiao on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import "PopUpMenuController.h"
#import "UIImage+Resize.h"

enum {
    small_size = 5,
    middle_size = 20,
    large_size = 50
};

enum {
    nothing_draw= 0,
    pencil_draw = 1,
    eraser_draw = 2,
    crayon_draw =3,
    marker_draw = 4
};





@implementation SDViewController
{
    NSMutableArray *velocities;
    NSMutableArray *paintBrushes;
    NSArray *pencilColors;
}

@synthesize canvasView;
@synthesize currentColor;
@synthesize colorBar;
@synthesize buttonBar;

@synthesize previousPoint1;
@synthesize previousPoint2;
@synthesize currentPoint;

//@synthesize lastDate;
@synthesize dateButton;
@synthesize checkButton;
@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    canvasView.layer.borderColor = [UIColor grayColor].CGColor;
//    canvasView.layer.borderWidth = 3.0f;
    draw_tool = pencil_draw;
    
    fileCount=-1;
    [self setupImagedata];
   
    velocities = [NSMutableArray array];
    
    [self setUpBrush];

/*    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
 
   [self.view addGestureRecognizer:panGestureRecognizer]; 
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(receiveSwapColorNotification:) 
 name:@"pickedColor"
 object:nil];
 
 
 
 PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
 [testObject setObject:@"bar" forKey:@"foo"];
 [testObject save];


 */


}

/*- (void) receiveSwapColorNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *selectedColor = [userInfo objectForKey:@"color"];
    draw_tool_color = selectedColor.intValue;
}
*/


-(void) setupImagedata
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filelist.plist"]; 
    NSMutableDictionary *savedStock;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: path]) //first time
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"filelist" ofType:@"plist"]; 
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; 
    }
    savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    fileCount = [[savedStock objectForKey:@"fileCount"] intValue];

    //NSString *lastDate = [savedStock objectForKey:@"lastDate"];
    
    filePointer = fileCount;
    
    fileCount ++;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];    
    [format setDateFormat:@"MMMM d, yyyy"];    
    NSDate *now = [[NSDate alloc] init];    
    NSString *dateString = [format stringFromDate:now];    
    
    //    if( ![lastDate isEqualToString:dateString]);
     
    canvasView.image = nil;
    [dateButton setTitle:dateString forState:UIControlStateNormal];
 
}


-(void) setUpBrush
{
    paintBrushes = [NSMutableArray array];
    NSArray *colorArray;
    NSArray *colorTextArray;

    colorArray = [NSMutableArray array];
    colorArray = [[NSArray alloc] initWithObjects: 
                       [UIColor blackColor], 
                       [UIColor redColor], 
                       [UIColor greenColor], 
                       [UIColor blueColor], 
                       [UIColor purpleColor], 
                       [UIColor yellowColor],
                       [UIColor brownColor],
                       [UIColor cyanColor],
                       [UIColor orangeColor],
                       [UIColor lightGrayColor],
                       nil]; 
    
    pencilColors = [NSArray arrayWithArray:colorArray]; // auto


   colorTextArray = [[NSArray alloc] initWithObjects: 
                               @"Black", 
                               @"Red", 
                               @"Green", 
                               @"Blue", 
                               @"Purple", 
                               @"Yellow", 
                               @"Brown", 
                               @"Cyan", 
                               @"Orange", 
                               @"Gray", 
                               nil];
    
    NSString *filename;
    int numberofColors = [colorArray count];
    
    for (int i = 0; i < numberofColors; i ++)
    {
        for (int j=0; j<4; j++)
        {
            filename = [NSString stringWithFormat:@"crayon%@%d.png", [colorTextArray objectAtIndex:i], j+1];
            [paintBrushes addObject:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:filename]]];
        }
        
    }
    float xPos = 0;
    float buttonSize = 60;
    

    for (int i=0; i<numberofColors; i++) {
        xPos = i * (buttonSize+10);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(xPos, 0, buttonSize, buttonSize-25);
        [button addTarget:self 
                   action:@selector(colorSelectClick:)
         forControlEvents:UIControlEventTouchDown];

    //       UIImage *image = [UIImage imageNamed: @"Crayon_1.png"];
 //       [button setImage:[UIImage imageNamed:@"Crayon_button_icon.png"] forState:UIControlStateNormal];        
        [button setTitle:[colorTextArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[colorArray objectAtIndex:i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Chalkduster" size:13.0]];
 //       [button setTitleEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -20)];
        button.tag = i;
        [colorBar addSubview:button];
    } 
}



- (void)viewDidUnload
{
    [super viewDidUnload];
     // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // return YES;
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);

}



- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Saved"
                              message: @"Your diary of the day has been saved in the Photo Gallery."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
         [alert show];
        [self forwardButtonClick:nil];
    }
}

#pragma mark - popup menu selection

-(IBAction)syncButtonClick:(id)sender
{
    
    
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        //Thanks to @chrisonhismac
        
        [self.popoverController dismissPopoverAnimated:YES];
        return;
    }

    if (self.popoverController == nil) {
        PopUpMenuController *menu = 
        [[PopUpMenuController alloc] 
         initWithNibName:@"PopUpMenuController" 
         bundle:[NSBundle mainBundle]]; 
       
        UIPopoverController *popover = 
        [[UIPopoverController alloc] initWithContentViewController:menu]; 
        
        popover.delegate = self;
        menu.mycontroller = self;
        
        self.popoverController = popover;
    }
 

    [self.popoverController setPopoverContentSize:CGSizeMake(228, 200)];
     [self.popoverController 
     presentPopoverFromRect:checkButton.frame 
     inView:self.view 
     permittedArrowDirections:UIPopoverArrowDirectionAny 
     animated:YES];  
    
}

-(void)newPageMenuClick
{
    [self forwardButtonClick:nil];
    [self.popoverController dismissPopoverAnimated:YES];
    
}



-(void)photoMenuClick
{
    UIImageWriteToSavedPhotosAlbum(canvasView.image,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL); // you generally won't need a contextInfo here 
    [self.popoverController dismissPopoverAnimated:YES];

}

-(void)webMenuClick
{
    [self.popoverController dismissPopoverAnimated:YES];
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *ourPath; 
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        //ourPath = @"http://endlessdots.com/sketchdiary/login.html";
        
/*        UIView *myview = [self view];
        HUD = [[MBProgressHUD alloc] initWithView:myview];
        HUD.labelText = @"Sychronzing the diary...";
        HUD.detailsLabelText = @"Just relax";
        HUD.mode = MBProgressHUDModeAnnularDeterminate;
        [myview addSubview:HUD];
        
        [HUD showWhileExecuting:@selector(syncFiles) onTarget:self withObject:nil animated:YES]; */
        
        refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
        refreshHUD.labelText = @"Sychronzing the diary ...";
        [self.view addSubview:refreshHUD];
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        refreshHUD.delegate = self;

        [refreshHUD showWhileExecuting:@selector(syncFiles) onTarget:self withObject:nil animated:YES];
//        [self syncFiles];
        return;
        
    } else {
        ourPath = @"http://endlessdots.com/sketchdiary/signup.html";

    }
    NSURL *ourURL = [NSURL URLWithString:ourPath];
    if ([ourApplication canOpenURL:ourURL]) {
        [ourApplication openURL:ourURL];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Website Not Found" message:@"Error at accessing the web site" 
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } 
    
}


-(void) syncFiles
{
    NSLog(@"Showing Refresh HUD");
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
	
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];
    

    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"DiaryEntry"];
    [query whereKey:@"user" equalTo:currentUser];

    [query orderByDescending:@"Counter"];
    
    PFObject *firstObject = [query getFirstObject];
    NSNumber *lastNumber = [firstObject objectForKey:@"Counter"];
    int lastCounter = [lastNumber intValue];
    NSLog(@"last counter on the web %d\n", lastCounter);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *diaryDirectoryPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"diaryImages"];

    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filelist.plist"]; 
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    int numberofEntries = [[savedStock objectForKey:@"fileCount"] intValue];
    NSLog(@"last counter at local %d\n", numberofEntries);
    
    for (int i = lastCounter+1; i<=numberofEntries; i++){
        NSString *filename;
        filename = [NSString stringWithFormat: @"%d-s.png", i];
        NSString *diaryPath = [diaryDirectoryPath stringByAppendingPathComponent:filename]; 

        NSString *keyString = [NSString stringWithFormat: @"%d", i];
        NSString *dateString = [savedStock objectForKey:keyString];
        UIImage *img = [UIImage imageWithContentsOfFile:diaryPath];
        NSData *imageData = UIImagePNGRepresentation(img);
        PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
        [imageFile save];
        PFObject *userPhoto = [PFObject objectWithClassName:@"DiaryEntry"];
        [userPhoto setObject:[NSNumber numberWithInt:i] forKey:@"Counter"];
        [userPhoto setObject:dateString forKey:@"Date"];
        [userPhoto setObject:imageFile forKey:@"imageFile"];
        [userPhoto setObject:currentUser forKey:@"user"];
        [userPhoto save];
        
    }
    
    [refreshHUD hide:YES];
}



- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[refreshHUD removeFromSuperview];
//	[HUD release];
	refreshHUD = nil;
}


#pragma mark - Change View and Save Data

-(void) updateFileList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filelist.plist"]; 
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString *keyString = [NSString stringWithFormat: @"%d", fileCount];
 /*   
    NSDateFormatter *format = [[NSDateFormatter alloc] init];    
    [format setDateFormat:@"MMMM d, yyyy"];    
    NSDate *now = [[NSDate alloc] init];    
    NSString *dateString = [format stringFromDate:now];    */
    
    NSString *dateString = dateButton.titleLabel.text;

    
    [savedStock setObject:dateString forKey:@"lastDate"];
    [savedStock setObject:[NSNumber numberWithInt:fileCount] forKey:@"fileCount"];        
    
    [savedStock setObject:dateString forKey:keyString];
    
    [savedStock writeToFile: path atomically:YES];
    
    fileCount ++;    
}


-(void) saveImage
{
    if(canvasView.image==nil)
    {
        NSLog(@"saving image error!\n");

        return;
    }
    
    NSString *filename = [NSString stringWithFormat: @"%d.png", fileCount];
    NSLog(@"file counter:%d\n", fileCount);
    NSString *filename_small = [NSString stringWithFormat: @"%d-s.png", fileCount];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diaryDirectoryPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"diaryImages"];
    NSString *diaryPath = [diaryDirectoryPath stringByAppendingPathComponent:filename]; 
    NSString *diaryPath_small = [diaryDirectoryPath stringByAppendingPathComponent:filename_small]; 
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:diaryDirectoryPath isDirectory:&isDir]) 
	{
        if (![[NSFileManager defaultManager] createDirectoryAtPath:diaryDirectoryPath					   withIntermediateDirectories:YES attributes:nil error:nil]) 
        {
            NSLog(@"Error: Create folder failed");      
            return;
        }
	}
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:diaryPath]) 
    {
        //TO-DO: overwrite existing files
        //return; 
    }
    else {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(canvasView.image)];
        BOOL success = [imageData writeToFile:diaryPath atomically:YES];
        
        UIImage *resizedImage = [canvasView.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit 
                                                                       bounds:CGSizeMake(560.0f, 560.0f) 
                                                         interpolationQuality:kCGInterpolationHigh];
        imageData = [NSData dataWithData:UIImagePNGRepresentation(resizedImage)];
        success = [imageData writeToFile:diaryPath_small atomically:YES];
        
        
        if (!success)
        {
            NSLog(@"Error:write image failed"); 
            return;
        }    
        [self uploadImage:fileCount withDate:dateButton.titleLabel.text];
        [self updateFileList];
    }
    
    
}

-(void) uploadImage:(int)counter withDate:dateString
{

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:refreshHUD];
        
        // Set determinate mode
        refreshHUD.mode = MBProgressHUDModeDeterminate;
        refreshHUD.delegate = self;
        refreshHUD.labelText = @"Saving ...";
        [refreshHUD show:YES];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *diaryDirectoryPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"diaryImages"];
        NSString *filename_small = [NSString stringWithFormat: @"%d-s.png", counter];
        NSLog(@"uploading file %@", filename_small);
        NSString *diaryPath_small = [diaryDirectoryPath stringByAppendingPathComponent:filename_small]; 
        UIImage *img = [UIImage imageWithContentsOfFile:diaryPath_small];
        NSData *imageData = UIImagePNGRepresentation(img);

        PFFile *imageFile = [PFFile fileWithName:filename_small data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [refreshHUD hide:YES];
                
                // Show checkmark
                refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:refreshHUD];
                
                // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
                refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                
                // Set custom view mode
                refreshHUD.mode = MBProgressHUDModeCustomView;
                
                refreshHUD.delegate = self;
                
                PFObject *userPhoto = [PFObject objectWithClassName:@"DiaryEntry"];
                [userPhoto setObject:dateString forKey:@"Date"];
                [userPhoto setObject:[NSNumber numberWithInt:counter] forKey:@"Counter"];
                [userPhoto setObject:imageFile forKey:@"imageFile"];
                [userPhoto setObject:currentUser forKey:@"user"];
                [userPhoto saveInBackground];
                
            }
            else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            refreshHUD.progress = (float)percentDone/100;
        }];

    } 

}


-(void) loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filelist.plist"]; 
    NSMutableDictionary *savedStock;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString *filename = [NSString stringWithFormat: @"%d.png", filePointer+1];
    NSString *diaryDirectoryPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"diaryImages"];
    NSString *diaryPath = [diaryDirectoryPath stringByAppendingPathComponent:filename]; 
    
    if (![fileManager fileExistsAtPath: diaryPath]) 
    {
        canvasView.image = nil;
        NSLog(@"new entry!\n");
        NSDateFormatter *format = [[NSDateFormatter alloc] init];    
        [format setDateFormat:@"MMMM d, yyyy"];    
        NSDate *now = [[NSDate alloc] init];    
        NSString *dateString = [format stringFromDate:now];    
        
        [dateButton setTitle:dateString forState:UIControlStateNormal];

    }
    else {
        NSData *imageData = [NSData dataWithContentsOfFile:diaryPath];
        canvasView.image = [UIImage imageWithData:imageData];

        NSString *keyString = [NSString stringWithFormat: @"%d", filePointer+1];
        NSString *lastDate = [savedStock objectForKey:keyString];

        [dateButton setTitle:lastDate forState:UIControlStateNormal];
    }
    
 /*   
        if(fileCount <0) 
        {
            fileCount = [[savedStock objectForKey:@"fileCount"] intValue];
        }
    }
    if (lastDate == nil) 
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        [format setDateFormat:@"MMMM d, yyyy"];    
        NSDate *now = [[NSDate alloc] init];    
        lastDate = [format stringFromDate:now];    
    } */
}



-(IBAction)backButtonClick:(id)sender
{
    NSLog(@"filePoint:%d, fileCount:%d", filePointer, fileCount);
    //first page
    if(filePointer <=0) return;   
    
    //last page & not empty
    if(filePointer == (fileCount-1) && canvasView.image != nil)
    {
        [self saveImage];
    }
    
    filePointer --;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    buttonBar.alpha = 0;
    [UIView commitAnimations];
    
    draw_tool = nothing_draw;
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         canvasView.alpha = 0;
                         // dateButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         
                         [self loadImage];
                         
                         [UIView beginAnimations:nil context:nil];
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationDuration:0.5];
                         canvasView.alpha = 1;
                         [UIView commitAnimations];

                         //  dateButton.alpha = 1;
                     }];
    
}



-(IBAction)forwardButtonClick:(id)sender
{
    NSLog(@"filePoint:%d, fileCount:%d", filePointer, fileCount);
    
    //problem when press forward button continuious too fast.
    if (filePointer >= fileCount)
        filePointer = fileCount -1;
    
    // last page and empty
    if(filePointer == (fileCount-1) && canvasView.image == nil)
    {
        return;
    }
    
    //last page and not empty
    if(filePointer == (fileCount-1))
    {
        [self saveImage];

    }
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         canvasView.alpha = 0;
                       //  dateButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         filePointer ++;
                         [self loadImage];
                         [UIView beginAnimations:nil context:nil];
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationDuration:0.5];
                         if(filePointer == (fileCount -1))
                         {
                             draw_tool = pencil_draw;
                             buttonBar.alpha = 1;
                         }
                         canvasView.alpha = 1;
                         [UIView commitAnimations];
                     //    dateButton.alpha = 1;
                     }];
    
    
    
}

#pragma mark - Drawing
CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self hideAlllToolbar];

    UITouch *touch = [touches anyObject];
    
    previousPoint1 = [touch previousLocationInView:canvasView];
    previousPoint2 = [touch previousLocationInView:canvasView];
    brush_tool_size = 2;
    [velocities removeAllObjects];

    currentPoint = [touch locationInView:canvasView];
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (draw_tool == nothing_draw) return;
    UITouch *touch = [touches anyObject];
    
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:canvasView];
    currentPoint = [touch locationInView:canvasView];
    
    float d1 = (previousPoint1.x - previousPoint2.x)*(previousPoint1.x - previousPoint2.x)  + (previousPoint1.y - previousPoint2.y)*(previousPoint1.y - previousPoint2.y);
    float d2 = (previousPoint1.x - currentPoint.x)*(previousPoint1.x - currentPoint.x)  + (previousPoint1.y - currentPoint.y)*(previousPoint1.y - currentPoint.y);
   
    float delta = sqrt((d2-d1)*(d2-d1))/160;    
    int changes = (int)delta;
    
    if (changes < 1) changes = 1;
    if (changes > 20) changes = 20;
 //   NSLog(@"%d, change", changes);
    
    if ([velocities count] > 1) {
        brush_tool_size = changes * 0.2f + [[velocities objectAtIndex:[velocities count] - 1] floatValue] * 0.8f;
    } 
    
 /*   if (d2>d1*1.1) brush_tool_size ++;
    if (d2<d1*0.9) brush_tool_size --;
    
    if (brush_tool_size < 3) brush_tool_size = 3;
    if (brush_tool_size > 20) brush_tool_size = 20; */
    
    [velocities addObject:[NSNumber numberWithFloat:brush_tool_size]];

    // calculate mid point
    CGPoint mid1 = midPoint(previousPoint1, previousPoint2); 
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);
    
    UIGraphicsBeginImageContext(canvasView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [canvasView.image drawInRect:CGRectMake(0, 0, canvasView.frame.size.width, canvasView.frame.size.height)];
    
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y); 
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    
    if(draw_tool == pencil_draw)
    {
         
//        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        
        UIColor *selectedColor = [pencilColors objectAtIndex:(draw_tool_color)];
        CGContextSetStrokeColorWithColor(context, selectedColor.CGColor);

        CGContextSetLineWidth(context, brush_tool_size+2); 

    }
    
    if(draw_tool == eraser_draw)
    {
        CGContextSetBlendMode(context,kCGBlendModeClear);
        CGContextSetLineWidth(context, brush_tool_size*3);
    }
   
    if(draw_tool == crayon_draw)
    {

        CGContextSetBlendMode(context, kCGBlendModeDarken);

        int option = arc4random() % 4;
        UIColor *selectedColor = [paintBrushes objectAtIndex:(draw_tool_color*4 + option)];
        CGContextSetStrokeColorWithColor(context, selectedColor.CGColor);
           
            //CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);        
       CGContextSetLineWidth(context, brush_tool_size*2 + 5); 
 
 //       CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
 //       CGContextSetLineWidth(context, 10.0);

    }
    
    if(draw_tool == marker_draw)
    {
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextSetLineWidth(context, 10.0);
    }
    CGContextStrokePath(context);
    
    canvasView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext(); 
    
}



-(IBAction)emptyButtonClick:(id)sender
{
    [self hideAlllToolbar];
    if (buttonBar.alpha == 0) return;
    NSString *message = @"Are you sure that you want to erase all content?";

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Erase all"
                          message: message
                          delegate: nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK",nil];
    alert.tag = 100; //exit
    [alert setDelegate:self];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
		NSLog(@"user pressed Cancel");
	}
	else {
        canvasView.image = nil;
		NSLog(@"user pressed OK");
	}
 
}


-(IBAction)pencilButtonClick:(id)sender
{
    [self hideAlllToolbar];
    draw_tool = pencil_draw;
    draw_tool_color = 0;
    [self showToolbar:colorBar];
}
-(IBAction)eraserButtonClick:(id)sender
{
    [self hideAlllToolbar];
    draw_tool = eraser_draw;
//    draw_tool_size = middle_size;
//    [self showToolbar:colorBar];
}


- (void) colorSelectClick:(id)sender 
{
    
    UIButton *button=sender;
    draw_tool_color = (int) [button tag];
    
  //  NSLog(@"Button %d clicked, %d color", button.tag, draw_tool_color);
    [self hideAlllToolbar];    
}

-(IBAction)crayonButtonClick:(id)sender
{
    [self hideAlllToolbar];
    draw_tool = crayon_draw;
    draw_tool_color = 0;
    [self showToolbar:colorBar];
}
-(IBAction)markerButtonClick:(id)sender
{
    [self hideAlllToolbar];
    draw_tool = marker_draw;
}

/*
- (float)extractSize:(UIPanGestureRecognizer *)panGestureRecognizer
{
    //! result of trial & error
    CGPoint velocityPoint = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    float vel = sqrtf((velocityPoint.x * velocityPoint.x) + (velocityPoint.y * velocityPoint.y));
    float size = vel / 166.0f;
    if (size < 1) size = 1;
    if (size > 40) size = 40;
    
    if ([velocities count] > 1) {
        size = size * 0.2f + [[velocities objectAtIndex:[velocities count] - 1] floatValue] * 0.8f;
    }
    [velocities addObject:[NSNumber numberWithFloat:size]];
    return size;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
} 

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{

    brush_tool_size = [self extractSize:panGestureRecognizer];
} */


-(void) hideAlllToolbar
{
    if(!colorBar.hidden)
        [self hideToolbar:colorBar];
    
}

-(void) showToolbar:(UIView *) toolbarView
{
//    CGRect frame = toolbarView.frame;
 //   frame.origin.y -=  frame.size.height;
    toolbarView.hidden = FALSE;
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         toolbarView.alpha = 1;
  //                       toolbarView.frame = frame;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void) hideToolbar:(UIView *) toolbarView
{
//    CGRect frame = toolbarView.frame;
//    frame.origin.y +=  frame.size.height;
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         toolbarView.alpha = 0;
  //                       toolbarView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         toolbarView.hidden = TRUE;
                         
                     }];
    
}






@end
