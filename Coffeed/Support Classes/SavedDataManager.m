//
//  SavedDataManager.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "SavedDataManager.h"
#import "ServerConfiguration.h"

@interface SavedDataManager ()
@property (nonatomic) NSMutableDictionary *serverDict;
@end

@implementation SavedDataManager

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *) savedFilePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ServerList"];
}

-(void) saveServerDict
{
//	[self.serverDict writeToFile:[self savedFilePath] atomically:YES];
//
	
	BOOL success = [NSKeyedArchiver archiveRootObject:self.serverDict toFile:[self savedFilePath]];
	
	if(!success)
		NSLog(@"No success archiving");
}

-(void) loadServerDict
{
	//	NSDictionary *savedServerDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[self savedFilePath]];
	//	NSArray *allValues = [savedServerDictionary allValues];
	//
	//	self.serverDict = [NSMutableDictionary dictionary];
	//
	//	for(int i=0; i<[allValues count]; i++)
	//	{
	//		NSDictionary *d = allValues[i];
	//		self.serverDict[d[@"servername"]] = [ServerConfiguration configurationWithDictionary:d];
	//	}
	
	if(_serverDict)
		self.serverDict = nil;
	
	self.serverDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[self savedFilePath]];
	
	if(!_serverDict)
	{
		NSLog(@"no archive -- creating blank dictionary");
		self.serverDict = [NSMutableDictionary dictionary];
	}
}

-(NSMutableDictionary *) serverDict
{
	return _serverDict;
}

-(void) addServer:(NSDictionary *)dictionary
{
	self.serverDict[dictionary[@"servername"]] = [ServerConfiguration configurationWithDictionary:dictionary];
	
	[self saveServerDict];
}

-(void) deleteServer:(NSDictionary *)dictionary
{
	[self.serverDict removeObjectForKey:dictionary[@"servername"]];
	
	[self saveServerDict];
}



-(id) init
{
	if((self = [super init]))
	{
		[self loadServerDict];
	}
	
	return self;
}

@end
