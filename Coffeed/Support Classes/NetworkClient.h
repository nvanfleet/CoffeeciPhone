//
//  NetworkClient.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-23.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h> 
#include <netinet/in.h>

@interface NetworkClient : NSObject {
}
-(NSString *) sendCommand:(NSString *)command domain:(NSString *)domain port:(NSNumber *)port;
@end
