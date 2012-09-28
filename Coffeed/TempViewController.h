//
//  TempViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-09-27.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TempViewController : UIViewController

@property (assign) IBOutlet UILabel *setLabel;
@property (assign) IBOutlet UILabel *tempLabel;
@property (assign) IBOutlet UIStepper *tempStepper;

@property (assign) IBOutlet UISwitch *activeSwitch;

@property (assign) IBOutlet UITextView *serverOutput;

-(IBAction)stepperChanged:(id)sender;
-(IBAction)switchMoved:(id)sender;

@end