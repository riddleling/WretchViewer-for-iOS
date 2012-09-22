//
//  PhotosViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAWretchAlbum.h"

@interface PhotosViewController : UIViewController

@property (strong, nonatomic) RAWretchAlbum *album;
@property (strong, nonatomic) NSArray *currentPhotosList;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSMutableArray *images;

- (id)initWithAlbum:(RAWretchAlbum *)aAlbum;

@end
