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
#import "ServerSettingViewController.h"
#import "DataRequestManager.h"

@interface ServerViewController ()
@property (assign) NSDictionary *serverConfigurations;
@end

@implementation ServerViewController

#pragma mark TableView Delegate and Datasource

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"AddServerIdentifier"])
    {
        // Get reference to the destination view controller
        ServerSettingViewController *vc = [segue destinationViewController];
		
        // Pass any objects to the view controller here, like...
        vc.configuration = sender;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	ServerConfiguration *sc = [[self.serverConfigurations allValues] objectAtIndex:[indexPath row]];
	
	[self performSegueWithIdentifier:@"AddServerIdentifier" sender:sc];
}

// Set active configuration
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ServerConfiguration *sc = [[self.serverConfigurations allValues] objectAtIndex:[indexPath row]];
	[[[DataRequestManager sharedInstance] savedDataManager] setSelectedServer:sc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_serverConfigurations count];
}

-(ServerConfigurationCell *) createNewCell
{
    ServerConfigurationCell *cell = nil;
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ServerCell" owner:nil options:nil];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"delete");
	
	ServerConfiguration *sc = [[self.serverConfigurations allValues] objectAtIndex:[indexPath row]];
	
	[[[DataRequestManager sharedInstance] savedDataManager] deleteServer:sc.servername];
	
	[self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *keys = [_serverConfigurations allKeys];
	
	ServerConfiguration *sConfig = [_serverConfigurations objectForKey:keys[[indexPath row]]];
	
    ServerConfigurationCell *cell = (ServerConfigurationCell *) [tableView dequeueReusableCellWithIdentifier:@"ServerCell"];
    
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
	[self performSegueWithIdentifier:@"AddServerIdentifier" sender:nil];
}

#pragma mark Basic

-(void) setActiveServer
{
	if([self.serverConfigurations count] <= 0)
	{
		return;
	}
	
	ServerConfiguration *sc = [[[DataRequestManager sharedInstance] savedDataManager] selectedServer];
	
	
	int i =0;
	
	if(sc!=nil)
	{
		for(i=0; i < [self.serverConfigurations count]; i++)
		{
			NSString *c = [[self.serverConfigurations allKeys] objectAtIndex:i];
			if([c isEqualToString:sc.servername])
			{
				break;
			}
		}
	}
	
	NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
	
	[self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

-(void) loadViewData
{
}

-(void) viewWillAppear:(BOOL)animated
{
	self.serverConfigurations = [[[DataRequestManager sharedInstance] savedDataManager] configurations];
	
	[self setActiveServer];							 

	[self.tableView reloadData];
	
	[self loadViewData];
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
