//
//  ServerSettingViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerSettingViewController : UIViewController <UITextFieldDelegate>
@property (assign) IBOutlet UITextField *serverName;
@property (assign) IBOutlet UITextField *address;
@property (assign) IBOutlet UITextField *port;
-(IBAction) okayButtonPushed:(id)sender;
-(IBAction) cancelButtonPushed:(id)sender;
@end
