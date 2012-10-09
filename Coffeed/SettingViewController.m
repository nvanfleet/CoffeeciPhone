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
    _serverOutput.text = object;
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
    NSLog(@"%@",(NSString *)object);
    
    _serverOutput.text = (NSString *)object;
}

#pragma  mark - Actions

-(IBAction)shutdownSystem:(id)sender
{
}

//-(IBAction)switchMoved:(UISwitch *)sender
//{
//    NSString *command = nil;
//    
//    if([sender isOn])
//    {
//        command = @"AWAKE";
//    }
//    else
//    {
//        command = @"SLEEP";
//    }
//    
//    NSLog(@"Command %@",command);
//    
//    [[DataRequestManager sharedInstance] queueCommand:command caller:self key:@"nokey"];
//}

# pragma  mark - Basic

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



# pragma  mark - Basic

-(void) updateViewData
{
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
