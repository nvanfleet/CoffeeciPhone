//
//  SavedDataManager.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "SavedDataManager.h"


@interface SavedDataManager ()
@property (nonatomic) NSMutableDictionary *serverConfigurations;
@property (nonatomic) NSString *selectedServerString;
@end

@implementation SavedDataManager

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *) savedFilePath:(NSString *)fileElement
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileElement];
}

-(void) saveConfigurations
{
	BOOL success = [NSKeyedArchiver archiveRootObject:self.serverConfigurations toFile:[self savedFilePath:@"ServerList"]];
	
	if(!success)
		NSLog(@"No success archiving");
}

#pragma mark Selected Server

-(ServerConfiguration *) selectedServer
{
	return self.configurations[[self selectedServerName]];
}

-(void) setSelectedServer:(ServerConfiguration *)server
{
	[self setSelectedServerName:server.servername];
}

-(NSString *) selectedServerName
{
	// Already loaded
	if(_selectedServerString)
		return _selectedServerString;
	
	// Loading
	NSString *server = [NSString stringWithContentsOfFile:[self savedFilePath:@"SelectedServer"] encoding:NSStringEncodingConversionAllowLossy error:nil];
	
	// Default selected server if none is selected
	if(server == nil && [self.configurations count] > 0)
		server = [[self.configurations allValues] objectAtIndex:0];
	
	self.selectedServerString = server;
	
	return server;
}

-(void) setSelectedServerName:(NSString *)servername
{
	self.selectedServerString = servername;
	[servername writeToFile:[self savedFilePath:@"SelectedServer"] atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
}

#pragma mark Server Dict

-(void) loadConfigurations
{
	if(_serverConfigurations)
		self.serverConfigurations = nil;
	
	self.serverConfigurations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self savedFilePath:@"ServerList"]];
	
	if(!_serverConfigurations)
	{
		NSLog(@"no archive -- creating blank dictionary");
		self.serverConfigurations = [NSMutableDictionary dictionary];
	}
}

-(NSMutableDictionary *) configurations
{
	return _serverConfigurations;
}

-(void) addServer:(NSDictionary *)dictionary
{
	self.serverConfigurations[dictionary[@"servername"]] = [ServerConfiguration configurationWithDictionary:dictionary];
	
	[self saveConfigurations];
}

-(void) deleteServer:(NSString *)servername
{
	[self.serverConfigurations removeObjectForKey:servername];
	
	[self saveConfigurations];
}

-(id) init
{
	if((self = [super init]))
	{
		_selectedServerString = nil;
		[self loadConfigurations];
	}
	
	return self;
}

@end
