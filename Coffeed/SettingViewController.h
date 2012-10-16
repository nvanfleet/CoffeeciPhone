//
//  AskViewController.h
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-09.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataRequestManager.h"

@interface SettingViewController : UIViewController <UITextFieldDelegate,DataRequestDelegate>

@property (assign) IBOutlet UITextField *brewPointField;
@property (assign) IBOutlet UITextField *steamPointField;
@property (assign) IBOutlet UITextField *pgainField;
@property (assign) IBOutlet UITextField *igainField;
@property (assign) IBOutlet UITextField *dgainField;
@property (assign) IBOutlet UITextField *boilerOffset;
@property (assign) IBOutlet UITextField *tempOffset;
@property (assign) IBOutlet UISwitch *celsiusSwitch;

@property (assign) IBOutlet UIImageView *statusImage;

-(IBAction)shutdownSystem:(id)sender;
-(IBAction)celsiusSwitchChanged:(id)sender;

@end
