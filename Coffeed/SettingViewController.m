//
//  AskViewController.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-09.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "SettingViewController.h"
#import "DataManager.h"

@implementation SettingViewController

# pragma  mark - DataRequest

- (void) dataManagerDidFail:(DataRequest *)nm message:(NSString *)message
{
    _serverOutput.text = message;
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
    NSLog(@"%@",(NSString *)object);
    
    _serverOutput.text = (NSString *)object;
}

# pragma  mark - Basic

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)updateButtonPressed:(id)sender
{
}

-(IBAction)switchMoved:(UISwitch *)sender
{
    NSString *command = nil;
    
    if([sender isOn])
    {
        command = @"AWAKE";
    }
    else
    {
        command = @"SLEEP";
    }
    
    NSLog(@"Command %@",command);
    
    [[DataManager sharedInstance] sendCommand:command callback:self];
}

# pragma  mark - Basic

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

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
