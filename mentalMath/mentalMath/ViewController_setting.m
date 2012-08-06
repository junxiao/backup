//
//  ViewController_setting.m
//  mentalMath
//
//  Created by Jun Xiao on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController_setting.h"
#include "ViewController.h"

@interface ViewController_setting ()

@end

@implementation ViewController_setting

@synthesize questionNumberLbl, questionNumberStepper, switchView;

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
    
    [self loadSettings];
    
    arrayNo = [[NSMutableArray alloc] init];
    [arrayNo addObject:@"Level 1: 7+9=?"];
    [arrayNo addObject:@"Level 2: 17-9=?"];
    [arrayNo addObject:@"Level 3: 34+5=?"];
    [arrayNo addObject:@"Level 4: 76-9=?"];
    [arrayNo addObject:@"Level 5: 34+48=?"];
    [arrayNo addObject:@"Level 6: 95-38=?"];
    [arrayNo addObject:@"Level 7: 5*5=?"];
    [arrayNo addObject:@"Level 8: 7*9=?"];
    
    [pickerView selectRow:level inComponent:0 animated:NO];
    switchView.on = penaltyOn;
    questionNumberStepper.value = questionNumber;
    [questionNumberLbl setText:[NSString stringWithFormat:@"%d", questionNumber]];
    
    NSLog(@"show level: %d\n", level);
   

}

-(void) loadSettings
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
    level = [[savedStock objectForKey:@"level"] intValue];
    questionNumber = [[savedStock objectForKey:@"questionNumber"] intValue];
    penaltyOn = [[savedStock objectForKey:@"penalty"] boolValue];
    
    [savedStock release];
    
}


/*- (void) setLevel: (int) i 
{
    level = i;
} */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"backSeq"]){
        [self saveSettings];
        NSLog(@"set level: %d\n", level);
    }
}

-(void) saveSettings
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //here add elements to data file and write data to file
    
    [data setObject:[NSNumber numberWithInt:level] forKey:@"level"];
    [data setObject:[NSNumber numberWithInt:questionNumber] forKey:@"questionNumber"];
    [data setObject:[NSNumber numberWithBool:penaltyOn] forKey:@"penalty"];
    
    [data writeToFile: path atomically:YES];
    [data release];
    
}

-(IBAction)stepperPressed:(UIStepper *) sender
{
    
    double value = [sender value];
    [questionNumberLbl setText:[NSString stringWithFormat:@"%d", (int)value]];
    questionNumber = (int) value;

}

-(IBAction)switchPressed:(UISwitch *) sender
{
    penaltyOn = sender.on;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    level = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [arrayNo count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [arrayNo objectAtIndex:row];
}


@end
