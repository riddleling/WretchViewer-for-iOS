//
//  AlbumsTableViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAWretchAlbumList.h"

@interface AlbumsTableViewController : UITableViewController

@property (strong, nonatomic) RAWretchAlbumList *albums;
@property (strong, nonatomic) NSArray *currentAlbumsList;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (id)initWithStyle:(UITableViewStyle)style albums:(RAWretchAlbumList *)albumsListObj;

@end
