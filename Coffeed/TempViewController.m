// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  TempViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-09-27.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "TempViewController.h"

@interface TempViewController () {
	int lastTemp;
}
@property (strong) NSTimer *timer;
@end

@implementation TempViewController

#pragma mark Request Delegate

-(void) setControls:(BOOL)set
{
	self.steamSwitch.enabled = set;
	self.activeSwitch.enabled = set;
	self.tempStepper.enabled = set;
}

-(void) enableDisplay:(BOOL)set
{
	if(set == FALSE)
	{
		self.setLabel.text = @"-";
		self.tempLabel.text = @"-";
		self.power.progress = 0.0f;
	}
}


- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	if([nm.key isEqualToString:@"updateView"])
		[self scheduleUpdate:2.0f];
	
	if([nm.key isEqualToString:@"updateView"])
	{
		[self enableDisplay:FALSE];
	}
	else if([nm.key isEqualToString:@"sleep"])
	{
	}
	else if([nm.key isEqualToString:@"smode"])
	{
	}
	
	self.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	if([nm.key isEqualToString:@"updateView"])
		[self scheduleUpdate:1.0f];
	
	NSDictionary *rdict = object;
	
	if(rdict[@"SETPOINT"] != nil)
		self.setLabel.text = rdict[@"SETPOINT"];
	
	if(rdict[@"TPOINT"] != nil)
	{
		int newTemp = (int) [rdict[@"TPOINT"] floatValue] * 10;
		
		self.tempLabel.text = rdict[@"TPOINT"];
	
		if(newTemp > lastTemp)
			self.tempLabel.textColor = [UIColor redColor];
		else if(newTemp < lastTemp)
			self.tempLabel.textColor = [UIColor blueColor];
		else
			self.tempLabel.textColor = [UIColor grayColor];
		
		lastTemp = newTemp;
	}
	
	if(rdict[@"POW"] != nil)
	{
		float power = ([rdict[@"POW"] floatValue])/100.0f;
		self.power.progress = power;
	}

	if(rdict[@"SMODE"] != nil)
	{
		if(!self.steamSwitch.enabled)
		{
			self.steamSwitch.enabled = TRUE;
		}
		else if(!self.steamSwitch.isHighlighted)
		{
			BOOL anim = TRUE;
			BOOL status;
			
			if([rdict[@"SMODE"] boolValue])
				status = TRUE;
			else
				status = FALSE;
			
			[self.steamSwitch setOn:status animated:anim];
		}
	}
	
	if(rdict[@"ACTIVE"] != nil)
	{
		if(!self.activeSwitch.enabled)
		{
			self.activeSwitch.enabled = TRUE;
		}
		else if(!self.activeSwitch.isHighlighted)
		{
			BOOL anim = TRUE;
			BOOL status;
			
			if([rdict[@"ACTIVE"] boolValue])
				status = TRUE;
			else
				status = FALSE;
			
			[self.activeSwitch setOn:status animated:anim];
		}
	}

	// Control surface settings
	self.statusImage.image = [UIImage imageNamed:@"23-bird"];
	[self enableDisplay:TRUE];
}

#pragma mark Actions

-(IBAction)stepperChanged:(UIStepper *)sender
{
	float currentValue = [self.setLabel.text floatValue];
	
	currentValue += (sender.value - 50)/4;
	
	NSString *command = [NSString stringWithFormat:@"SETPOINT=%f",currentValue];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"sleep"];
	
	sender.value = 50;
}

-(IBAction)sleepSwitchChanged:(UISwitch *)sender
{
	NSString *command;

	sender.enabled = FALSE;
	
	if([sender isOn])
		command = @"ACTIVE=1,SETPOINT";
	else
		command = @"ACTIVE=0,SETPOINT";
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"sleep"];
}

-(IBAction)steamSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	sender.enabled = FALSE;
	
	if([sender isOn])
		command = @"SMODE=1,SETPOINT";
	else
		command = @"SMODE=0,SETPOINT";
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"steam"];
}

#pragma mark Basic

-(void) scheduleUpdate:(float)timeInterval
{
	if(self.isViewLoaded && self.view.window)
	{
		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateViewData) userInfo:nil repeats:NO];
	}
}

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"SETPOINT,TPOINT,SMODE,ACTIVE,POW" caller:self key:@"updateView"];
}

-(void) viewWillAppear:(BOOL)animated
{
	lastTemp = 0;
	[self updateViewData];
	
	[self scheduleUpdate:1.0f];
}

-(void) viewWillDisappear:(BOOL)animated
{
	[self.timer invalidate];
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
