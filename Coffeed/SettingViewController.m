//
//  AskViewController.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-09.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

# pragma  mark - DataRequest

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{

}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	NSDictionary *rdict = object;
	
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
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
