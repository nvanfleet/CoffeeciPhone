//
//  TempViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-09-27.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "TempViewController.h"

@interface TempViewController ()

@end

@implementation TempViewController

#pragma mark Request Delegate

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	NSLog(@"failure message %@ key %@",object,[nm key]);
	if([nm.key isEqualToString:@"config"])
	{
		
	}
	else if([nm.key isEqualToString:@"sleep"])
	{
	}
	else if([nm.key isEqualToString:@"smode"])
	{
	}
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	NSDictionary *rdict = object;
	
	if(rdict[@"SETPOINT"] != nil)
		self.setLabel.text = rdict[@"SETPOINT"];
	
	if(rdict[@"TPOINT"] != nil)
		self.tempLabel.text = rdict[@"TPOINT"];
	
	if(rdict[@"SMODE"] != nil)
	{
		if([rdict[@"SMODE"] boolValue])
			self.steamSwitch.on = TRUE;
		else
			self.steamSwitch.on = FALSE;
	}
	
	if(rdict[@"ACTIVE"] != nil)
	{
		if([rdict[@"ACTIVE"] boolValue])
			self.activeSwitch.on = TRUE;
		else
			self.activeSwitch.on = FALSE;
	}
}

#pragma mark Actions

-(IBAction)stepperChanged:(id)sender
{
}

-(IBAction)sleepSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"ACTIVE=1,SETPOINT"];
	else
		command = [NSString stringWithFormat:@"ACTIVE=0,SETPOINT"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"sleep"];
}

-(IBAction)steamSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"SMODE=1,SETPOINT"];
	else
		command = [NSString stringWithFormat:@"SMODE=0,SETPOINT"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"steam"];
}

#pragma mark Basic

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"SETPOINT,TPOINT,SMODE,ACTIVE" caller:self key:@"config"];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateViewData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
