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

- (void) dataManagerDidFail:(DataRequest *)nm message:(NSString *)message
{
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
}

#pragma mark Actions

-(IBAction)stepperChanged:(id)sender
{
}

-(IBAction)switchMoved:(id)sender
{
}

-(void) updateViewData
{
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
