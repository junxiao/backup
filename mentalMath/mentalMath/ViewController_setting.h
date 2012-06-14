//
//  ViewController_setting.h
//  mentalMath
//
//  Created by Jun Xiao on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController_setting : UIViewController
{
    NSMutableArray *arrayNo;
    IBOutlet UIPickerView *pickerView;
    int questionNumber;
    int level;
    bool penaltyOn;
    IBOutlet UILabel *questionNumberLbl;
    IBOutlet UIStepper *questionNumberStepper;

}
@property(nonatomic,retain) IBOutlet UILabel *questionNumberLbl;
@property(nonatomic,retain) IBOutlet UIStepper *questionNumberStepper;

//- (void) setLevel: (int) i;

-(void) saveSettings;
-(void) loadSettings;


-(IBAction)stepperPressed:(UIStepper *) sender;
-(IBAction)switchPressed:(UISwitch *) sender;


@end
