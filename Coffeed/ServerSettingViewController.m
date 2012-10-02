//
//  ServerSettingViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "ServerSettingViewController.h"
#import "SavedDataManager.h"

@interface ServerSettingViewController ()

@end

@implementation ServerSettingViewController

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	if([self.serverName isFirstResponder])
		[self.serverName resignFirstResponder];
	else if([self.address isFirstResponder])
		[self.address resignFirstResponder];
	else if([self.port isFirstResponder])
		[self.port resignFirstResponder];
}

#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark Actions

-(IBAction) okayButtonPushed:(id)sender
{
	[self updateConfiguration];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancelButtonPushed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Basic

- (void)updateConfiguration
{
	BOOL success = YES;
	
	if(self.serverName.text == nil)
		success = NO;
	else if(self.address.text == nil)
		success = NO;
	else if(self.port.text == nil)
		success = NO;
	
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * number = [f numberFromString:self.port.text];
	
	if(number == nil)
		success = NO;
	
	if(success)
	{
		NSDictionary *dictionary = @{
		@"servername":self.serverName.text,
		@"address":self.address.text,
		@"port":number 
		};
		
		SavedDataManager *sdm = [[SavedDataManager alloc] init];
		
		[sdm addServer:dictionary];
	}
	else
	{
		NSLog(@"Entry ERROR: Configuration not saved");
	}
}

-(void) viewWillAppear:(BOOL)animated
{
	self.port.text = @"4949";
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
