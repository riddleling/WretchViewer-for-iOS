//
//  ShowPhotoViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/23.
//
//

#import <UIKit/UIKit.h>
#import "RAWretchPhotoURL.h"

@interface ShowPhotoViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) RAWretchPhotoURL *photoURL;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;


- (id)initWithPhotoURL:(RAWretchPhotoURL *)aPhotoURL;

@end
