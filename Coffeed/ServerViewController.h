//
//  ServerViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-09-28.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataRequestManager.h"

@interface ServerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DataRequestDelegate>
@property (assign) IBOutlet UITableView *tableView;

-(IBAction) addServerEntry:(id)sender;
@end
