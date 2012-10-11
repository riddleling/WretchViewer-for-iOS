//
//  ShowPhotoViewController.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 12/9/23.
//


#import "ShowPhotoViewController.h"


@interface ShowPhotoViewController (PrivateMethods)
- (void)photoDisplay;
- (void)nextPage:(id)sender;
- (void)prevPage:(id)sender;
- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView;
- (void)tap2;
- (void)otherAction:(id)sender;
- (void)openWeb;
- (void)mailPhoto;
- (void)savePhoto;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end



@implementation ShowPhotoViewController

@synthesize photoURL;
@synthesize indicator;
@synthesize photoScrollView;
@synthesize photoImageView;
@synthesize nextButton;
@synthesize prevButton;
@synthesize actionButton;
@synthesize photoData;


- (id)initWithPhotoURL:(RAWretchPhotoURL *)aPhotoURL
{
    self = [super init];
    if (self != nil)
    {
        self.photoURL = aPhotoURL;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    // setup BarButtonItem
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"▼"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextPage:)];
    self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"▲"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(prevPage:)];
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(otherAction:)];
    
    NSMutableArray *tbitems = [[NSMutableArray alloc] init];
    
    // add BarButtonItems
    [tbitems addObject:self.actionButton];
    [tbitems addObject:self.nextButton];
    [tbitems addObject:self.prevButton];
    self.navigationItem.rightBarButtonItems = tbitems;
    
    // get screen size
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    // setup imageView and scrollView
    CGRect viewFrame = CGRectMake(0, 0, screenSize.width, screenSize.height-20-44);
    self.photoImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    //self.photoImageView.userInteractionEnabled = YES;
    
    self.photoScrollView = [[UIScrollView alloc] initWithFrame:viewFrame];

    [self.photoScrollView setDelegate:self];
    [photoScrollView addSubview:photoImageView];
    
    [self.view addSubview:photoScrollView];
    
    // setup indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 64, screenSize.width, 30)];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.8f];
    [self.navigationController.view addSubview:self.indicator];
    
    //setup title
    //self.title = @"Photo";
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap2)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap];
    

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    [self.actionButton setEnabled:NO];
    
    [self photoDisplay];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.indicator = nil;
    self.photoScrollView = nil;;
    self.photoImageView = nil;
    self.nextButton = nil;
    self.prevButton = nil;
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.indicator isAnimating]) {
        [self.indicator stopAnimating];
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Tap gesture Methods

- (void)tap2
{
    //NSLog(@"tap 2!");
    if (self.photoScrollView.zoomScale == photoScaleFitValue){
        [self.photoScrollView setZoomScale:1.0f animated:YES];
    }
    else {
        [self.photoScrollView setZoomScale:photoScaleFitValue animated:YES];
    }
    
}


#pragma mark - Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    switch (buttonIndex) {
        case 0:
            [self performSelector:@selector(openWeb)];
            break;
        case 1:
            [self performSelector:@selector(mailPhoto)];
            break;
        case 2:
            [self performSelector:@selector(savePhoto)];
            break;
        default:
            break;
    }
}


#pragma mark - Scroll View delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{    
    self.photoImageView.frame = [self centeredFrameForScrollView:scrollView andUIView:self.photoImageView];
}


#pragma mark - Mail compose delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Private Methods

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView
{
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}


- (void)otherAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open to Safari", @"Mail Photo", @"Svae Photo", nil];
    [actionSheet showInView:self.view];
}


- (void)openWeb
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.photoURL.urlValue]];
}


- (void)mailPhoto
{    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        
        NSString *mailContent = [[NSString alloc] initWithFormat:@"Photo URL: %@", self.photoURL.urlValue];
        [mailController setMessageBody:mailContent isHTML:NO];
        [mailController setSubject:@"WretchViewer App sent a photo to you"];
        if (self.photoData != nil) {
            [mailController addAttachmentData:self.photoData mimeType:@"image/jpeg" fileName:self.photoURL.fileName];
        }
        
        [self presentModalViewController:mailController animated:YES];
    }
}

- (void)savePhoto
{
    if (self.photoData != nil) {
        UIImage *image = [[UIImage alloc] initWithData:self.photoData];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UILabel *saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2 , [[UIScreen mainScreen] bounds].size.width, 40)];
    saveLabel.backgroundColor = [UIColor darkGrayColor];
    saveLabel.textAlignment = NSTextAlignmentCenter;
    saveLabel.textColor = [UIColor whiteColor];
    
    if(!error) {
        //NSLog(@"Saved!");
        saveLabel.text = @"Saved!";
    }
    else {
        //NSLog(@"Error: %@",[error description]);
        saveLabel.text = @"Save Failed!";
    }
    
    [self.navigationController.view addSubview:saveLabel];
    
    [UIView animateWithDuration:2.0 animations:^{
        saveLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [saveLabel removeFromSuperview];
    }];
}


- (void)prevPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    RAWretchPhotoURL *prevPhotoURL = [[RAWretchPhotoURL alloc] initWithURL:self.photoURL.prevPageURL withThumbnailURL:nil];
    self.photoURL = prevPhotoURL;
    [self photoDisplay];
}


- (void)nextPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    RAWretchPhotoURL *nextPhotoURL = [[RAWretchPhotoURL alloc] initWithURL:self.photoURL.nextPageURL withThumbnailURL:nil];
    self.photoURL = nextPhotoURL;
    [self photoDisplay];
}


- (void)photoDisplay
{
    [self.indicator startAnimating];
    self.photoImageView.image = nil;
    [self.actionButton setEnabled:NO];
    // Reset zoomScale.
    self.photoScrollView.zoomScale = 1.0f;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:[self.photoURL convertToFileURL]];
        if (url != nil) {            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                    timeoutInterval:30];
            NSURLResponse *urlResponse;
            NSError *error;
            self.photoData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&urlResponse
                                                                     error:&error];
        }
        else {
            self.photoData = nil;
        }
        
        // update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.photoData != nil) {
                UIImage *image = [[UIImage alloc] initWithData:self.photoData];
                self.photoImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                self.photoImageView.image = image;
            }
            else {
                self.photoImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20-44);
                self.photoImageView.image = nil;
            }
            
                        
            self.photoScrollView.contentSize = self.photoImageView.frame.size;
            if (self.photoScrollView.frame.size.width < self.photoImageView.frame.size.width) {
                self.photoScrollView.minimumZoomScale = self.photoScrollView.frame.size.width / self.photoImageView.frame.size.width;
            }
            else {
                self.photoScrollView.minimumZoomScale = 1.0f;
            }
            
            
            self.photoScrollView.maximumZoomScale = 5.0f;
            self.photoScrollView.zoomScale = self.photoScrollView.frame.size.width / self.photoImageView.frame.size.width;
            photoScaleFitValue = self.photoScrollView.zoomScale;
            
            // centered photoImageView
            if (self.photoScrollView.zoomScale == 1.0f) {
                self.photoImageView.frame = [self centeredFrameForScrollView:self.photoScrollView andUIView:self.photoImageView];
            }
            
            // stop indicator
            [self.indicator stopAnimating];
            
            // setup prevButton
            if (self.photoURL.isPrevPage) {
                [self.prevButton setEnabled:YES];
            }
            else {
                [self.prevButton setEnabled:NO];
            }
            
            // setup nextButton
            if (self.photoURL.isNextPage) {
                [self.nextButton setEnabled:YES];
            }
            else {
                [self.nextButton setEnabled:NO];
            }
            
            // setup actionButton
            [self.actionButton setEnabled:YES];
        });
    });
}


@end
