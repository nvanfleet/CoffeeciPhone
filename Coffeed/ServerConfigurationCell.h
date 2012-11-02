//
//  ServerConfigurationCell.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerConfigurationCell : UITableViewCell
@property (assign) IBOutlet UILabel *title;
@property (assign) IBOutlet UILabel *address;
@property (assign) IBOutlet UIImageView *statusImage;
@property (assign) IBOutlet UIButton *selectedButton;
@end
