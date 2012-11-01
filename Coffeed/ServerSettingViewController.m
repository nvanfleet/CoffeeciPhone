//
//  ServerSettingViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "ServerSettingViewController.h"
#import "DataRequestManager.h"

@interface ServerSettingViewController ()

@end

@implementation ServerSettingViewController

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	self.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	self.statusImage.image = [UIImage imageNamed:@"13-target"];
}

-(void) checkServer
{
	if(self.address.text == nil || [self.address.text isEqualToString:@" "])
		return;
	
	if(self.port.text == nil || [self.port.text isEqualToString:@" "])
		return;
	
	ServerConfiguration *tconfig = [[ServerConfiguration alloc] init];
	
	tconfig.servername = @"placeholder";
	tconfig.address = self.address.text;

	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	
	tconfig.port = [f numberFromString:self.port.text];

	[[DataRequestManager sharedInstance] checkServerOnline:tconfig key:@"x" caller:self];
}

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
	
	[self checkServer];
	
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

-(IBAction)shutdownSystem:(id)sender
{
	[[DataRequestManager sharedInstance] queueCommand:@"SHUTD" caller:self key:@"shutdown"];
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
		
		// Save what is in the text boxes
		[[[DataRequestManager sharedInstance] savedDataManager] addServer:dictionary];
		
		// Delete the duplicate (happens only if the name changes)
		if(self.configuration && ![self.configuration.servername isEqualToString:self.serverName.text])
			[[[DataRequestManager sharedInstance] savedDataManager] deleteServer:self.configuration.servername];
	}
	else
	{
		NSLog(@"Entry ERROR: Configuration not saved");
	}
}

-(void) viewWillAppear:(BOOL)animated
{
	if(self.configuration)
	{
		self.serverName.text = self.configuration.servername;
		self.address.text = self.configuration.address;
		self.port.text = [self.configuration.port stringValue];
	}
	else
		self.port.text = @"4949";
	
	// Shiny shutdown image
	UIImage *shutButtonImage = [UIImage imageNamed:@"CellButtonRed"];
	shutButtonImage = [shutButtonImage stretchableImageWithLeftCapWidth:floorf(shutButtonImage.size.width/2) topCapHeight:floorf(shutButtonImage.size.height/2)];
	[self.shutdownButton setBackgroundImage:shutButtonImage forState:UIControlStateNormal];
	[self.shutdownButton setBackgroundImage:shutButtonImage forState:UIControlStateHighlighted];
	
	// Shiny Okay image
	UIImage *okayImage = [UIImage imageNamed:@"CellButtonBlue"];
	okayImage = [okayImage stretchableImageWithLeftCapWidth:floorf(okayImage.size.width/2) topCapHeight:floorf(okayImage.size.height/2)];
	[self.okayButton setBackgroundImage:okayImage forState:UIControlStateNormal];
	[self.okayButton setBackgroundImage:okayImage forState:UIControlStateHighlighted];
	
	// Shiny shutdown image
	UIImage *cancelImage = [UIImage imageNamed:@"CellButtonGrey"];
	cancelImage = [cancelImage stretchableImageWithLeftCapWidth:floorf(cancelImage.size.width/2) topCapHeight:floorf(cancelImage.size.height/2)];
	[self.cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:cancelImage forState:UIControlStateHighlighted];
	
	[self checkServer];
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
