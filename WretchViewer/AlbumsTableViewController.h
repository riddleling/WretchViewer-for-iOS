//
//  AlbumsTableViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *albums;

- (id)initWithStyle:(UITableViewStyle)style albums:(NSArray *)array;

@end
