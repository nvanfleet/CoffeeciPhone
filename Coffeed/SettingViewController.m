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
	UIColor *color;
	
	// Disabled
	self.brewPointField.enabled = set;
	self.steamPointField.enabled = set;
	self.pgainField.enabled = set;
	self.igainField.enabled = set;
	self.dgainField.enabled = set;
	self.boilerOffset.enabled = set;
	self.tempOffset.enabled = set;
	
	//Color
	if(set)
		color = [UIColor blackColor];
	else
		color = [UIColor lightGrayColor];
	
	self.brewPointField.textColor = color;
	self.steamPointField.textColor = color;
	self.pgainField.textColor = color;
	self.igainField.textColor = color;
	self.dgainField.textColor = color;
	self.boilerOffset.textColor = color;
	self.tempOffset.textColor = color;
	
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
	
	if(rdict[@"BPOINT"]!=nil)
		self.brewPointField.text = rdict[@"BPOINT"];
	
	if(rdict[@"SPOINT"]!=nil)
		self.steamPointField.text = rdict[@"SPOINT"];
	
	if(rdict[@"PGAIN"]!=nil)
		self.pgainField.text = rdict[@"PGAIN"];
	
	if(rdict[@"IGAIN"]!=nil)
		self.igainField.text = rdict[@"IGAIN"];
	
	if(rdict[@"DGAIN"]!=nil)
		self.dgainField.text = rdict[@"DGAIN"];
	
	if(rdict[@"OFFSET"]!=nil)
		self.boilerOffset.text = rdict[@"OFFSET"];
	
	if(rdict[@"TOFFSET"]!=nil)
		self.tempOffset.text = rdict[@"TOFFSET"];
	
	if(rdict[@"CELSIUS"] != nil)
	{
		if([rdict[@"CELSIUS"] boolValue])
			self.celsiusSwitch.on = TRUE;
		else
			self.celsiusSwitch.on = FALSE;
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
	
	[self updateViewData];
}

-(IBAction)shutdownSystem:(id)sender
{
	[[DataRequestManager sharedInstance] queueCommand:@"SHUTD" caller:self key:@"shutdown"];
}

# pragma  mark - Basic

-(void) changeSetting:(UITextField *) field
{
	NSString *key;
	
	if(self.brewPointField == field)
		key = @"BPOINT";
	else if(self.steamPointField == field)
		key = @"SPOINT";
	else if(self.pgainField == field)
		key = @"PGAIN";
	else if(self.igainField == field)
		key = @"IGAIN";
	else if(self.dgainField == field)
		key = @"DGAIN";
	else if(self.boilerOffset == field)
		key = @"OFFSET";
	else if(self.tempOffset == field)
		key = @"TOFFSET";
	
	NSString *comm = [NSString stringWithFormat:@"%@=%@",key,field.text];
	
	[[DataRequestManager sharedInstance] queueCommand:comm caller:self key:@"fieldupdate"];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
	
	[self changeSetting:textField];
	
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
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:NO];
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
