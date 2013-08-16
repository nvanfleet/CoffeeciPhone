// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  ServerSettingViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConfiguration.h"

@interface ServerSettingViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>
@property (assign) IBOutlet UITextField *serverName;
@property (assign) IBOutlet UITextField *address;
@property (assign) IBOutlet UITextField *port;
@property (strong) ServerConfiguration *configuration;
@property (assign) IBOutlet UIButton *cancelButton;
@property (assign) IBOutlet UIButton *okayButton;
@property (assign) IBOutlet UIButton *shutdownButton;

@property (assign) IBOutlet UIImageView *statusImage;

-(IBAction) okayButtonPushed:(id)sender;
-(IBAction) cancelButtonPushed:(id)sender;
-(IBAction) shutdownSystem:(id)sender;
@end
