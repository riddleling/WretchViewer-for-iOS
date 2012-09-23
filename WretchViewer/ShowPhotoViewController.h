//
//  ShowPhotoViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/23.
//
//

#import <UIKit/UIKit.h>
#import "RAWretchPhotoURL.h"

@interface ShowPhotoViewController : UIViewController

@property (strong, nonatomic) RAWretchPhotoURL *photoURL;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (id)initWithPhotoURL:(RAWretchPhotoURL *)aPhotoURL;

@end
