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
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	NSLog(@"success message %@ key %@",object,[nm key]);
}

#pragma mark Actions

-(IBAction)stepperChanged:(id)sender
{
}

-(IBAction)sleepSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	if([sender isOn])
		command = [NSString stringWithFormat:@"SLEEP=TRUE"];
	else
		command = [NSString stringWithFormat:@"BMODE=FALSE"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"SLEEP"];
}

-(IBAction)steamSwitchChanged:(UISwitch *)sender
{
	NSString *command;
	
	if(![sender isOn])
		command = [NSString stringWithFormat:@"BMODE=TRUE"];
	else
		command = [NSString stringWithFormat:@"BMODE=FALSE"];
	
	[[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"BMODE"];
}

#pragma mark Basic

-(void) updateViewData
{
	[[DataRequestManager sharedInstance] queueCommand:@"SPOINT,TPOINT,BMODE,SLEEP" caller:self key:@"CONFIG"];
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
