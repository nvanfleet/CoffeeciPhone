//
//  ServerConfiguration.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerConfiguration : NSObject <NSCoding>
@property (nonatomic) NSString *servername;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *port;
+(id) configurationWithDictionary:(NSDictionary *)dictionary;
+(id) configurationWithName:(NSString*)name address:(NSString*)address port:(NSString *)port;
-(NSDictionary *) configurationDictionary;
@end
