//
//  ServerConfiguration.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "ServerConfiguration.h"

@implementation ServerConfiguration

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_servername forKey:@"servername"];
	[encoder encodeObject:_address forKey:@"address"];
	[encoder encodeObject:_port forKey:@"port"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		self.servername = [decoder decodeObjectForKey:@"servername"];
		self.address = [decoder decodeObjectForKey:@"address"];
		self.port = [decoder decodeObjectForKey:@"port"];
	}
	
	return self;
}

#pragma mark Basic

+(id) configurationWithDictionary:(NSDictionary *)dict
{
	return [ServerConfiguration configurationWithName:dict[@"servername"] address:dict[@"address"] port:dict[@"port"]];
}

+(id) configurationWithName:(NSString*)name address:(NSString*)address port:(NSString *)port
{
	ServerConfiguration *sConf = [[ServerConfiguration alloc] init];
	
	sConf.servername = name;
	sConf.address = address;
	sConf.port = port;
	
	return sConf;
}
@end
