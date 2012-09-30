//
//  ShowPhotoViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/23.
//
//

#import "ShowPhotoViewController.h"


@interface ShowPhotoViewController (PrivateMethods)
- (void)photoDisplay;
- (void)nextPage:(id)sender;
- (void)prevPage:(id)sender;
- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView;
@end



@implementation ShowPhotoViewController

@synthesize photoURL;
@synthesize indicator;
@synthesize photoScrollView;
@synthesize photoImageView;
@synthesize nextButton;
@synthesize prevButton;


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
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@">"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextPage:)];
    self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(prevPage:)];
    
    NSMutableArray *tbitems = [[NSMutableArray alloc] init];
    
    // setup Space BarButtonItem
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = 5.0f;
    UIBarButtonItem *spaceButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton2.width = 20.0f;
    
    // add BarButtonItems
    [tbitems addObject:self.nextButton];
    [tbitems addObject:spaceButton1];
    [tbitems addObject:self.prevButton];
    [tbitems addObject:spaceButton2];
    self.navigationItem.rightBarButtonItems = tbitems;
    
    
    //setup imageView and scrollView
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-20-44)];
    self.photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-20-44)];

    [self.photoScrollView setDelegate:self];
    [photoScrollView addSubview:photoImageView];
    
    [self.view addSubview:photoScrollView];
    
    // setup indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 64, 320, 25)];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.8f];
    [self.navigationController.view addSubview:self.indicator];
    
    //setup title
    //self.title = @"Photo";

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    [self photoDisplay];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.photoURL = nil;
    self.indicator = nil;
    self.photoScrollView = nil;;
    self.photoImageView = nil;
    self.nextButton = nil;
    self.prevButton = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


- (void)prevPage:(id)sender
{
    RAWretchPhotoURL *prevPhotoURL = [[RAWretchPhotoURL alloc] initWithURL:self.photoURL.prevPageURL withThumbnailURL:nil];
    self.photoURL = prevPhotoURL;
    [self photoDisplay];
    
}


- (void)nextPage:(id)sender
{
    RAWretchPhotoURL *nextPhotoURL = [[RAWretchPhotoURL alloc] initWithURL:self.photoURL.nextPageURL withThumbnailURL:nil];
    self.photoURL = nextPhotoURL;
    [self photoDisplay];
}


- (void)photoDisplay
{
    [self.indicator startAnimating];
    self.photoImageView.image = nil;
    self.photoScrollView.zoomScale = 1.0f;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:[self.photoURL convertToFileURL]];
        NSData *data;
        if (url != nil) {
            data = [[NSData alloc] initWithContentsOfURL:url];
        }
        else {
            //NSURL *turl = [NSURL URLWithString:[self.photoURL thumbnailURL]];
            //data = [[NSData alloc] initWithContentsOfURL:turl];
            data = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                self.photoImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                self.photoImageView.image = image;
            }
            else {
                self.photoImageView.frame = CGRectMake(0, 0, 320, 480-20-44);
                self.photoImageView.image = nil;
            }
            
            //self.photoImageView.backgroundColor = [UIColor whiteColor];
            //self.photoScrollView.backgroundColor = [UIColor greenColor];
            
            self.photoScrollView.contentSize = self.photoImageView.frame.size;
            self.photoScrollView.minimumZoomScale = self.photoScrollView.frame.size.width / self.photoImageView.frame.size.width;
            //NSLog(@"min zoom => %f", self.photoScrollView.minimumZoomScale);
            self.photoScrollView.maximumZoomScale = 5.0f;
            self.photoScrollView.zoomScale = self.photoScrollView.minimumZoomScale;
            
            
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
            
        });
    });
}


@end
