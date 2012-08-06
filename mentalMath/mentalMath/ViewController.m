//
//  ViewController.m
//  mentalMath
//
//  Created by Jun Xiao on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#include "ViewController_setting.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize variable1Lbl;
@synthesize variable2Lbl;
@synthesize operatorLbl;
@synthesize textField;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadSettings];
    [self resetQuestion];
    startTime = [NSDate timeIntervalSinceReferenceDate];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];		
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;


}

- (void)addButtonToKeyboard {
	// create custom button
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0, 163, 106, 53);
	doneButton.adjustsImageWhenHighlighted = NO;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
		[doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
	} else {        
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
	}
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
	// locate keyboard view
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
				[keyboard addSubview:doneButton];
		} else {
			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
				[keyboard addSubview:doneButton];
		}
	}
}
- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[self addButtonToKeyboard];
    }
}


- (void)doneButton:(id)sender {
    [textField resignFirstResponder];
    
    if ([self checkAnswerOK:textField.text])
    {
        textField.text = @"";
        if(questionNumber > 0)
        {
            [self resetQuestion];
        }
        else {
            [self endTest];
        }
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Wrong"
                              message: @"Check your answer again!"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        NSString *mistake = [NSString stringWithFormat:@"%@ %@ %@ = %@;", variable1Lbl.text, operatorLbl.text, variable2Lbl.text, textField.text];
        
        [mistakeString appendString:mistake];
        
        [alert release];
    }

}


-(void) loadSettings
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) 
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; 
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; 
    }
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //load from savedStock example int value
   
    level = [[savedStock objectForKey:@"level"] intValue];
    questionNumber = [[savedStock objectForKey:@"questionNumber"] intValue];
    questionNumberTotal = questionNumber;
    mistakeNumber = 0;
    penaltyOn = [[savedStock objectForKey:@"penalty"] boolValue];
    
    [savedStock release];
    
    path = [documentsDirectory stringByAppendingPathComponent:@"log.plist"]; 
     
    if (![fileManager fileExistsAtPath: path]) 
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"log" ofType:@"plist"]; 
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; 
    }
    
    logArray = [[NSMutableArray alloc] initWithContentsOfFile: path];
    mistakeString = [[NSMutableString alloc] initWithString:@""];
    


}

/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"settingSeq"]){
        ViewController_setting *cvc = (ViewController_setting *)[segue destinationViewController];
        [cvc setLevel:level];
    }
} */

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (logArray) [logArray release];
    
//    [self saveSettings];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

    
-(void) endTest
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval interval = now - startTime;
    int seconds = (int)interval;
    int minutes = seconds/60;
    seconds = seconds%60;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];    
    [format setDateFormat:@"MMMM d, yyyy"];    
    NSDate *datenow = [[NSDate alloc] init];    
    NSString *dateString = [format stringFromDate:datenow];   
    NSString *message ;  
    if( minutes > 1){
        message = [NSString stringWithFormat:@"Completion time: %d minutes\n Score: %d/%d", minutes, questionNumberTotal-mistakeNumber, questionNumberTotal];
    }
    else {
        message = [NSString stringWithFormat:@"Completion time: %d minute\n Score: %d/%d", minutes, questionNumberTotal-mistakeNumber, questionNumberTotal];
    }
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    [saveDict setValue:dateString forKey:@"date"];
    [saveDict setValue:message forKey:@"summary"];
    [saveDict setValue:mistakeString forKey:@"mistakes"];
    [logArray addObject:saveDict];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"log.plist"]; 

    [logArray writeToFile:path atomically:NO];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Exercise complete"
                          message: message
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    alert.tag = 100; //exit
    [alert setDelegate:self];
    [alert show];
    [alert release];
   
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100) {
    exit(0);
    } 
}
    
-(BOOL) checkAnswerOK:(NSString *) answerText
{
    int i = [answerText intValue];
    if (answerNumber == i)
    {
        return TRUE;
    }
    else {
        mistakeNumber ++;
        if (penaltyOn)
        {
            questionNumber ++;
        }
        return FALSE;
    }
}


-(void) resetQuestion
{
    int op1, op2, sum, operation;
    NSString *operationString;
    if (level == 0)
    {
        op1 = arc4random() % 9 + 1;
        
        op2 = arc4random() % 9 + 1;
        
        sum = op1 + op2;
        
            answerNumber = sum;
            operationString = @"+";
    }
    if (level == 1)
    {
        op1 = arc4random() % 9 + 1;
        
        op2 = arc4random() % 9 + 1;
        
        sum = op1 + op2;
        
        operation = arc4random () % 2;
        
        if (operation == 0) //+
        {
            answerNumber = sum;
            operationString = @"+";
            
        }
        if (operation == 1) // -
        {
            op1 = sum;
            answerNumber = sum - op2;
            operationString = @"-";
        }
    }
    if (level == 2)
    {
        sum = arc4random() % 50 + 50;
        
        op2 = arc4random() % 9 + 1;
        
        int byTen =  arc4random () % 2;
        if (byTen == 0)
        {
            op2 = ((arc4random() % 5) +1) * 10;
        }

            op1 = sum - op2;
            answerNumber = sum;
            operationString = @"+";

    }
    if (level == 3)
    {
        sum = arc4random() % 50 + 50;
        
        op2 = arc4random() % 9 + 1;
        
        operation = arc4random () % 2;
        
        int byTen =  arc4random () % 2;
        if (byTen == 0)
        {
            op2 = ((arc4random() % 5) +1) * 10;
        }
        
        if (operation == 0) //+
        {
            op1 = sum - op2;
            answerNumber = sum;
            operationString = @"+";
            
        }
        if (operation == 1) // -
        {
            op1 = sum;
            answerNumber = sum - op2;
            operationString = @"-";
        }
    }
    if (level == 4)
    {
        sum = arc4random() % 60 + 39;
        
        op2 = (arc4random() % (sum - 11)) + 11;
        
            op1 = sum - op2;
            if (arc4random () % 2 == 0) // exchange
            {
                op2 = op1;
                op1 = sum - op2;
            }
            
            answerNumber = sum;
            operationString = @"+";
            
    }
    if (level == 5)
    {
        sum = arc4random() % 60 + 39;
        
        op2 = (arc4random() % (sum - 11)) + 11;
        
        operation = arc4random () % 2;
        
        
        if (operation == 0) //+
        {
            op1 = sum - op2;
            if (arc4random () % 2 == 0) // exchange
            {
                op2 = op1;
                op1 = sum - op2;
            }
            
            answerNumber = sum;
            operationString = @"+";
            
        }
        if (operation == 1) // -
        {
            op1 = sum;
            answerNumber = sum - op2;
            operationString = @"-";
        }
    }
    if (level == 6)
    {
        op1 = arc4random() % 5 + 1;
        
        op2 = arc4random() % 9 + 1;
        answerNumber = op1 * op2;
        if (arc4random () % 2 == 0) // exchange
        {
            op2 = op1;
            op1 = answerNumber / op2;
        }
        
        operationString = @"*";
    }
    if (level == 7)
    {
        op1 = arc4random() % 5 + 5;
        
        op2 = arc4random() % 5 + 5;
        answerNumber = op1 * op2;
        if (arc4random () % 2 == 0) // exchange
        {
            op2 = op1;
            op1 = answerNumber / op2;
        }
        
        operationString = @"*";
    }
    
    [variable1Lbl setText:[NSString stringWithFormat:@"%d", op1]];
    [variable2Lbl setText:[NSString stringWithFormat:@"%d", op2]];
    [operatorLbl setText:operationString];
    questionNumber --;
}


@end
