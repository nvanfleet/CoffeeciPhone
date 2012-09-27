//
//  AskViewController.h
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-09.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UITextFieldDelegate>

@property (assign) IBOutlet UITextField *setpointField;
@property (assign) IBOutlet UITextField *pgainField;
@property (assign) IBOutlet UITextField *igainField;
@property (assign) IBOutlet UITextField *dgainField;

@property (assign) IBOutlet UIButton *updateButton;
@property (assign) IBOutlet UISwitch *activeSwitch;
    
@property (assign) IBOutlet UITextView *serverOutput;

-(IBAction)updateButtonPressed:(id)sender;
-(IBAction)switchMoved:(id)sender;

@end
