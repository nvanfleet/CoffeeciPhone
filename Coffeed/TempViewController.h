// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  TempViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-09-27.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataRequestManager.h"

@interface TempViewController : UIViewController <DataRequestDelegate>

@property (assign) IBOutlet UILabel *setLabel;
@property (assign) IBOutlet UILabel *tempLabel;
@property (assign) IBOutlet UIStepper *tempStepper;
@property (assign) IBOutlet UISwitch *activeSwitch;
@property (assign) IBOutlet UISwitch *steamSwitch;

@property (assign) IBOutlet UIProgressView *power;

@property (assign) IBOutlet UIImageView *statusImage;

-(IBAction)stepperChanged:(id)sender;
-(IBAction)sleepSwitchChanged:(id)sender;
-(IBAction)steamSwitchChanged:(id)sender;

@end
