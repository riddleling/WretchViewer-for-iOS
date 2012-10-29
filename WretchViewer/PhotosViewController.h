//
//  PhotosViewController.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/13.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RAWretchAlbum.h"
#import "ShowPhotoViewController.h"

@interface PhotosViewController : UIViewController <ShowPhotoViewControllerDelegate>
{
    CGRect thumbnailRect;
}
@property (strong, nonatomic) RAWretchAlbum *album;
@property (strong, nonatomic) NSArray *currentPhotosList;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *transitionImages;
@property (strong, nonatomic) UIView *transitionView;

- (id)initWithAlbum:(RAWretchAlbum *)aAlbum;

@end
