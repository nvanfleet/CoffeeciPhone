//
//  AskViewController.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-09.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (strong) NSTimer *timer;
@end

@implementation SettingViewController

# pragma  mark - DataRequest

-(void) enableDisplay:(BOOL)set
{
	self.brewPointField.enabled = set;
	self.steamPointField.enabled = set;
	self.pgainField.enabled = set;
	self.igainField.enabled = set;
	self.dgainField.enabled = set;
	self.boilerOffset.enabled = set;
	self.tempOffset.enabled = set;
	
	self.celsiusSwitch.enabled = set;
}

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	NSLog(@"failure message %@ key %@",object,[nm key]);
	[self enableDisplay:FALSE];
	
	self.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	NSDictionary *rdict = object;
	
	[self enableDisplay:TRUE];
	
	if([nm.key isEqualToString:@"config"])
	{
		self.brewPointField.text = rdict[@"BPOINT"];
		self.steamPointField.text = rdict[@"SPOINT"];
		self.pgainField.text = rdict[@"PGAIN"];
		self.igainField.text = rdict[@"IGAIN"];
		self.dgainField.text = rdict[@"DGAIN"];
		self.boilerOffset.text = rdict[@"OFFSET"];
		self.tempOffset.text = rdict[@"TOFFSET"];
		
		if(rdict[@"CELSIUS"] != nil)
		{
			if([rdict[@"CELSIUS"] boolValue])
				self.celsiusSwitch.on = TRUE;
			else
				self.celsiusSwitch.on = FALSE;
		}
	}
	else if([nm.key isEqualToString:@"celcius"])
	{
	}
	else if([nm.key isEqualToString:@"shutdown"])
	{
	}
	
	self.statusImage.image = [UIImage imageNamed:@"13-target"];
}

#pragma  mark - Actions

-(IBAction)celsiusSwitchChanged:(id)sender
{
	NSString *command;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"CELSIUS=1"];
	else
		command = [NSString stringWithFormat:@"CELSIUS=0"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"celcius"];
}

-(IBAction)shutdownSystem:(id)sender
{
	[[DataRequestManager sharedInstance] queueCommand:@"SHUTD" caller:self key:@"shutdown"];
}

# pragma  mark - Basic

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

# pragma  mark - Basic

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"BPOINT,SPOINT,PGAIN,IGAIN,DGAIN,OFFSET,TOFFSET,CELSIUS" caller:self key:@"config"];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateViewData];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
	[self.timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
