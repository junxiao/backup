//
//  SDViewController.h
//  SketchDiary
//
//  Created by Jun Xiao on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface SDViewController : UIViewController <UIGestureRecognizerDelegate, UIPopoverControllerDelegate,MBProgressHUDDelegate>
{
    int draw_tool;

    int brush_tool_size;
    
    int draw_tool_color;
    
    int fileCount;
    int filePointer;
    

    IBOutlet UIImageView *canvasView;
    IBOutlet UIButton *dateButton;
    
    IBOutlet UIView *colorBar;
    IBOutlet UIView *buttonBar;

   
    UIPopoverController *popoverController;
    
    IBOutlet UIButton *checkButton;

    MBProgressHUD *refreshHUD;

    
}
@property (nonatomic,assign) CGPoint previousPoint1;
@property (nonatomic,assign) CGPoint previousPoint2;
@property (nonatomic,assign) CGPoint currentPoint;
CGPoint midPoint(CGPoint p1, CGPoint p2);

@property (strong) UIColor *currentColor;

@property(strong) UIImageView *canvasView;
@property(strong) UIButton *dateButton;
@property(strong) UIButton *checkButton;
@property(strong)  UIView *colorBar;
@property(strong)  UIView *buttonBar;

@property (nonatomic, retain) UIPopoverController *popoverController; 

-(void)photoMenuClick;
-(void)webMenuClick;
-(void)syncFiles;
-(void)newPageMenuClick;

-(IBAction)syncButtonClick:(id)sender;
-(IBAction)emptyButtonClick:(id)sender;
-(IBAction)pencilButtonClick:(id)sender;
-(IBAction)eraserButtonClick:(id)sender;
-(IBAction)crayonButtonClick:(id)sender;

-(IBAction)forwardButtonClick:(id)sender;
-(IBAction)backButtonClick:(id)sender;



-(void) setUpBrush;

-(void) saveImage;
-(void) loadImage;
-(void) uploadImage:(int)counter withDate:dateString;

-(void) setupImagedata;

-(void) updateFileList;

-(void) showToolbar:(UIView *) toolbarView;
-(void) hideToolbar:(UIView *) toolbarView;
-(void) hideAlllToolbar;

@end
