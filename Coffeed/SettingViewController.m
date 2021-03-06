// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
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
}

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	if([nm.key isEqualToString:@"updateView"])
		[self scheduleUpdate];
	
	[self enableDisplay:FALSE];
	
	self.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	if([nm.key isEqualToString:@"updateView"])
		[self scheduleUpdate];
	
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
		
	self.statusImage.image = [UIImage imageNamed:@"23-bird"];
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
	
	NSString *comm = [NSString stringWithFormat:@"%@=%@",key,field.text];
	
	[[DataRequestManager sharedInstance] queueCommand:comm caller:self key:@"fieldupdate"];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self.timer invalidate];
	self.timer = nil;
	
	// Offsets
	CGPoint location = textField.frame.origin;
	if(90-location.y < 0)
	{
		CGRect newFrame = CGRectMake(0.0f, 100-location.y, self.view.frame.size.width, self.view.frame.size.height);
		self.view.frame = newFrame;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:NO];
	
	// Offsets
	CGRect newFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
	self.view.frame = newFrame;
	
	[self changeSetting:textField];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

# pragma  mark - Basic

-(void) scheduleUpdate
{
	if(self.isViewLoaded && self.view.window)
	{
		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:NO];
	}
}

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"BPOINT,SPOINT,PGAIN,IGAIN,DGAIN,OFFSET" caller:self key:@"updateView"];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateViewData];
	
	[self scheduleUpdate];
}

-(void) viewWillDisappear:(BOOL)animated
{
	[self.timer invalidate];
	self.timer = nil;
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
