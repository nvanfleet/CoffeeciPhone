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
	
	self.autotuneButton.enabled = set;
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
	
//	if(rdict[@"AUTOT"]!=nil)
//	{
//		int status = [rdict[@"AUTOT"] intValue];
//		
//		//If the autotune is in progress the button stays disabled.
//		if(status == 1)
//		{
//			[self.autotuneButton setTitle:@"Stop PID Autotune" forState:UIControlStateNormal];
//			[self.autotuneButton setTitle:@"Stop PID Autotune" forState:UIControlStateHighlighted];
//			self.autotuneButton.tag = 0;
//		}
//		else
//		{
//			[self.autotuneButton setTitle:@"Start PID Autotune" forState:UIControlStateNormal];
//			[self.autotuneButton setTitle:@"Start PID Autotune" forState:UIControlStateHighlighted];
//			self.autotuneButton.tag = 1;
//		}
//	}
	
	self.statusImage.image = [UIImage imageNamed:@"13-target"];
}

#pragma  mark - Actions

-(IBAction) autotuneButtonPushed:(id)sender
{
	self.autotuneButton.enabled = FALSE;
	NSString *comm = [NSString stringWithFormat:@"AUTOT=%d",self.autotuneButton.tag];
	[[DataRequestManager sharedInstance] queueCommand:comm caller:self key:@"autotune"];
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
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
	
	[self changeSetting:textField];
	
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
	[[DataRequestManager sharedInstance] queueCommand:@"BPOINT,SPOINT,PGAIN,IGAIN,DGAIN,OFFSET,AUTOT" caller:self key:@"updateView"];
}

-(void) viewWillAppear:(BOOL)animated
{
	[self updateViewData];
	
	[self scheduleUpdate];
	
	// Shiny Okay image
	UIImage *autoImage = [UIImage imageNamed:@"CellButtonBlue"];
	autoImage = [autoImage stretchableImageWithLeftCapWidth:floorf(autoImage.size.width/2) topCapHeight:floorf(autoImage.size.height/2)];
	[self.autotuneButton setBackgroundImage:autoImage forState:UIControlStateNormal];
	[self.autotuneButton setBackgroundImage:autoImage forState:UIControlStateHighlighted];
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
