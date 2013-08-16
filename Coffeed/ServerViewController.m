// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
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

@interface ServerViewController ()
@property (assign) NSDictionary *serverConfigurations;
@property (strong) NSTimer *timer;
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
	// Set Datamanager selected
	ServerConfiguration *sc = [[self.serverConfigurations allValues] objectAtIndex:[indexPath row]];
	[[[DataRequestManager sharedInstance] savedDataManager] setSelectedServer:sc];
	
	[self.tableView reloadData];
	[self setActiveServer];
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
	ServerConfiguration *sConfig = [[_serverConfigurations allValues] objectAtIndex:[indexPath row]];

    ServerConfigurationCell *cell = (ServerConfigurationCell *) [tableView dequeueReusableCellWithIdentifier:@"ServerCell"];
    
    if (cell == nil)
    {
		NSLog(@"Create new cell");
        cell = [self createNewCell];
    }
    
	cell.title.text = sConfig.servername;
	cell.address.text = [NSString stringWithFormat:@"%@:%@",sConfig.address,sConfig.port];
	
	// Set selected
	ServerConfiguration *sc = [[[DataRequestManager sharedInstance] savedDataManager] selectedServer];
	if([sConfig.servername isEqualToString:sc.servername])
		cell.selectedButton.selected = TRUE;
	
    return cell;
}

#pragma mark Actions

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
	
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

-(IBAction) addServerEntry:(id)sender
{
	[self performSegueWithIdentifier:@"AddServerIdentifier" sender:nil];
}


#pragma mark Request Delegate

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
//	NSLog(@"failure message %@ key %@",object,[nm key]);
	
	int keyIndex = [[nm key]integerValue];
	NSIndexPath *index = [NSIndexPath indexPathForRow:keyIndex inSection:0];
	ServerConfigurationCell *cell = (ServerConfigurationCell *) [self.tableView cellForRowAtIndexPath:index];
	cell.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	int keyIndex = [[nm key]integerValue];
	NSIndexPath *index = [NSIndexPath indexPathForRow:keyIndex inSection:0];
	ServerConfigurationCell *cell = (ServerConfigurationCell *) [self.tableView cellForRowAtIndexPath:index];
	cell.statusImage.image = [UIImage imageNamed:@"23-bird"];
}

#pragma mark Basic

-(void) setActiveServer
{	
	if([self.serverConfigurations count] <= 0)
	{
		return;
	}
	
	ServerConfiguration *sc = [[[DataRequestManager sharedInstance] savedDataManager] selectedServer];
	
	BOOL isSelected;
	int i =0;
	NSIndexPath *index;
	
	if(sc!=nil)
	{
		for(i=0; i < [self.serverConfigurations count]; i++)
		{
			isSelected = NO;
			NSString *c = [[self.serverConfigurations allKeys] objectAtIndex:i];
			if([c isEqualToString:sc.servername])
			{
				isSelected = YES;
			}
			
			index = [NSIndexPath indexPathForRow:i inSection:0];
			
			ServerConfigurationCell *scc = (ServerConfigurationCell*) [self.tableView cellForRowAtIndexPath:index];
			scc.selectedButton.selected = isSelected;
		}
	}
	
	[[DataRequestManager sharedInstance] flushAllRequests];
}

-(void) updateViewData
{
	// Send off commands
	for(int i=0; i < [[self.serverConfigurations allValues] count]; i++)
	{
		ServerConfiguration *sc = [[self.serverConfigurations allValues] objectAtIndex:i];
		[[DataRequestManager sharedInstance] checkServerOnline:sc key:[NSString stringWithFormat:@"%d",i] caller:self];
	}
}

-(void) viewWillAppear:(BOOL)animated
{
	self.serverConfigurations = [[[DataRequestManager sharedInstance] savedDataManager] configurations];
	
	[self.tableView reloadData];
	
	[self setActiveServer];
	
	[self updateViewData];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateViewData) userInfo:nil repeats:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
	[self.timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
