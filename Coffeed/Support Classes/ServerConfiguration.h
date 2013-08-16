// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
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
@property (nonatomic) NSString *resolvedAddress;
@property (nonatomic) NSNumber *port;
+(id) configurationWithDictionary:(NSDictionary *)dictionary;
@end
