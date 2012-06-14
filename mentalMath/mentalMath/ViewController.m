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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadSettings];
    [self resetQuestion];
    startTime = [NSDate timeIntervalSinceReferenceDate];
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
    
    //load from savedStock example int value
   
    level = [[savedStock objectForKey:@"level"] intValue];
    questionNumber = [[savedStock objectForKey:@"questionNumber"] intValue];
    penaltyOn = [[savedStock objectForKey:@"penalty"] boolValue];
    
    [savedStock release];

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
    // Release any retained subviews of the main view.
    
//    [self saveSettings];
}


/*
 - (void) setLevel: (int) i 
{
    level = i;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(IBAction)userDoneEnteringText:(id)sender
{
    UITextField *theField = (UITextField*)sender;
    
    if ([self checkAnswerOK:theField.text])
    {
        theField.text = @"";
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
        [alert release];
    }
    
}
    
    
-(void) endTest
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval interval = now - startTime;
    int seconds = (int)interval;
    int minutes = seconds/60;
    seconds = seconds%60;
    NSString *message = [NSString stringWithFormat:@"You took %d minutes to complete all the questions!", minutes];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Congratulations"
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
        questionNumber --;
        return TRUE;
    }
    else {
        if (penaltyOn)
        {
            questionNumber +=2;
        }
        else {
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
    if (level == 1)
    {
        sum = arc4random() % 90 + 9;
        
        op2 = (arc4random() % (sum - 1)) + 1;
        
        operation = arc4random () % 2;
        
        
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
    if (level == 2)
    {
        op1 = arc4random() % 6 + 1;
        
        op2 = arc4random() % 9 + 1;
        answerNumber = op1 * op2;
        operationString = @"*";
    }
    
    [variable1Lbl setText:[NSString stringWithFormat:@"%d", op1]];
    [variable2Lbl setText:[NSString stringWithFormat:@"%d", op2]];
    [operatorLbl setText:operationString];
    questionNumber --;
}

-(BOOL) isFinal
{
    return TRUE;
    return FALSE;
}

@end
