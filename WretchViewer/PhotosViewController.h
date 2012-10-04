//
//  PhotosViewController.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 12/9/13.
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
