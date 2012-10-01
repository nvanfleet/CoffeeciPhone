//
//  SavedDataManager.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedDataManager : NSObject

-(NSMutableDictionary *) serverDict;
-(void) addServer:(NSDictionary *)dictionary;
-(void) deleteServer:(NSString *)dictionary;

@end
