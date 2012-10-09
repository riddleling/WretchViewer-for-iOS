//
//  ShowPhotoViewController.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 12/9/23.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RAWretchPhotoURL.h"

@interface ShowPhotoViewController : UIViewController
<UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    float photoScaleFitValue;
}
@property (strong, nonatomic) RAWretchPhotoURL *photoURL;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) UIBarButtonItem *prevButton;
@property (strong, nonatomic) UIBarButtonItem *actionButton;
@property (strong, nonatomic) NSData *photoData;


- (id)initWithPhotoURL:(RAWretchPhotoURL *)aPhotoURL;

@end
