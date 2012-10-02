//
//  ServerViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "ServerViewController.h"
#import "SavedDataManager.h"
#import "ServerConfiguration.h"
#import "ServerConfigurationCell.h"

@interface ServerViewController ()
@property (strong) NSDictionary *serverConfigurations;
@end

@implementation ServerViewController

#pragma mark TableView Delegate and Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_serverConfigurations count];
}

-(ServerConfigurationCell *) createNewCell
{
    ServerConfigurationCell *cell = nil;
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ServerConfigurationCell" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[ServerConfigurationCell class]])
        {
            cell = (ServerConfigurationCell *)currentObject;
            break;
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *keys = [_serverConfigurations allKeys];
	
	ServerConfiguration *sConfig = [_serverConfigurations objectForKey:keys[[indexPath row]]];
	
    ServerConfigurationCell *cell = (ServerConfigurationCell *) [tableView dequeueReusableCellWithIdentifier:@"ServerConfigurationCell"];
    
    if (cell == nil)
    {
        cell = [self createNewCell];
    }
    
	cell.title.text = sConfig.servername;
	cell.address.text = [NSString stringWithFormat:@"%@:%@",sConfig.address,sConfig.port];
    
    return cell;
}

#pragma mark Actions

-(IBAction) addServerEntry:(id)sender
{
	[self performSegueWithIdentifier:@"AddServerIdentifier" sender:sender];
}

#pragma mark Basic

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.serverConfigurations = [[[SavedDataManager alloc] init] serverDict];
		
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
