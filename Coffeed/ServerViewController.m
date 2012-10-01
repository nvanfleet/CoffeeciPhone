//
//  ServerViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "ServerViewController.h"

@interface ServerViewController ()

@end

@implementation ServerViewController

#pragma mark TableView Delegate and Datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark Actions

-(IBAction) addServerEntry:(id)sender
{
}

#pragma mark Basic

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
