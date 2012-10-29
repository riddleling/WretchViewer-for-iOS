//
//  AlbumsTableViewController.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/12.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RAWretchAlbumList.h"

@interface AlbumsTableViewController : UITableViewController

@property (strong, nonatomic) RAWretchAlbumList *albums;
@property (strong, nonatomic) NSArray *currentAlbumsList;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (id)initWithStyle:(UITableViewStyle)style albums:(RAWretchAlbumList *)albumsListObj;

@end
