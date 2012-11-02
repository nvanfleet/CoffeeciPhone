//
//  TempViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-09-27.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "TempViewController.h"

@interface TempViewController ()
@property (strong) NSTimer *timer;
@end

@implementation TempViewController

#pragma mark Request Delegate

-(void) enableDisplay:(BOOL)set
{
	if(set == FALSE)
	{
		self.setLabel.text = @"-";
		self.tempLabel.text = @"-";
		self.power.progress = 0.0f;
		self.powLabel.text = @"-";
	}
	
	self.steamSwitch.enabled = set;
	self.activeSwitch.enabled = set;
	self.tempStepper.enabled = set;
}


- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	if([nm.key isEqualToString:@"updateView"])
		[self scheduleUpdate];
	
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
		[self scheduleUpdate];
	
	NSDictionary *rdict = object;
	
	
	[self enableDisplay:TRUE];
	
	if(rdict[@"SETPOINT"] != nil)
		self.setLabel.text = rdict[@"SETPOINT"];
	
	if(rdict[@"TPOINT"] != nil)
		self.tempLabel.text = rdict[@"TPOINT"];
	
	if(rdict[@"POW"] != nil)
	{
		float power = ([rdict[@"POW"] floatValue])/100.0f;
		self.power.progress = power;
		self.powLabel.text = rdict[@"POW"];
	}

	if(rdict[@"SMODE"] != nil)
	{
		if(!self.steamSwitch.enabled)
			self.steamSwitch.enabled = TRUE;
		else
		{
			if([rdict[@"SMODE"] boolValue])
				[self.steamSwitch setOn:TRUE animated:TRUE];
			else
				[self.steamSwitch setOn:FALSE animated:TRUE];
		}
	}
	
	if(rdict[@"ACTIVE"] != nil)
	{
		if(!self.activeSwitch.enabled)
			self.activeSwitch.enabled = TRUE;
		else
		{
			if([rdict[@"ACTIVE"] boolValue])
				[self.activeSwitch setOn:TRUE animated:TRUE];
			else
				[self.activeSwitch setOn:FALSE animated:TRUE];
		}
	}
	
	self.statusImage.image = [UIImage imageNamed:@"13-target"];
}

#pragma mark Actions

-(IBAction)stepperChanged:(UIStepper *)sender
{
	float currentValue = [self.setLabel.text floatValue];
	
	NSLog(@"current %f",currentValue);
	
	currentValue += (sender.value - 50)/10;
	
	NSLog(@"new value %f",currentValue);
	
	NSString *command = [NSString stringWithFormat:@"SETPOINT=%f",currentValue];
	
	NSLog(@"command %@",command);
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"sleep"];
	
	sender.value = 50;
}

-(IBAction)sleepSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	sender.enabled = FALSE;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"ACTIVE=1,SETPOINT"];
	else
		command = [NSString stringWithFormat:@"ACTIVE=0,SETPOINT"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"sleep"];
}

-(IBAction)steamSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	sender.enabled = FALSE;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"SMODE=1,SETPOINT"];
	else
		command = [NSString stringWithFormat:@"SMODE=0,SETPOINT"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"steam"];
}

#pragma mark Basic

-(void) scheduleUpdate
{
	if(self.isViewLoaded && self.view.window)
	{
		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:NO];
	}
}

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"SETPOINT,TPOINT,SMODE,ACTIVE,POW" caller:self key:@"updateView"];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateViewData];
	
	[self scheduleUpdate];
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
