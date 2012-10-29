//
//  PhotosViewController.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/13.
//


#import "PhotosViewController.h"
#import "RAWretchPhotoURL.h"


@interface PhotosViewController (PrivateMethods)
- (void)updateImages;
- (void)prevPage:(id)sender;
- (void)nextPage:(id)sender;
- (void)showPhoto:(id)sender;
- (UIImage *)imageWithUIImage:(UIImage *)aImage withBorderWidth:(CGFloat)border;
- (UIImage *)imageWithShadow:(UIImage *)aImage;
- (CGRect)frameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView;
@end


@implementation PhotosViewController

@synthesize album;
@synthesize currentPhotosList;
@synthesize prevButton;
@synthesize nextButton;
@synthesize indicator;
@synthesize images;
@synthesize transitionImages;
@synthesize transitionView;


- (id)initWithAlbum:(RAWretchAlbum *)aAlbum
{
    self = [super init];
    if (self != nil)
    {
        self.album = aAlbum;
        self.images = [[NSMutableArray alloc] init];
        self.transitionImages = [[NSMutableArray alloc] init];
        [album addObserver:self forKeyPath:@"currentPageNumber" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    
    UIImage *backgroundTexture = [UIImage imageNamed:@"purty_wood.png"];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundTexture];
    [self.view setBackgroundColor:backgroundColor];
    
    // setup BarButtonItem
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"▼"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextPage:)];
    self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"▲"
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
    
    
    // setup title
    self.title = self.album.name;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    int i = 1;
    int x = 0;
    int y = 0;
    
    for (int tag=0; tag<=20; tag++) {
        UIImageView *imageView;
        UIImageView *transitionImageView;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
            transitionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
        }
        else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
            transitionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // setup transitionImageView
        transitionImageView.contentMode = UIViewContentModeScaleAspectFit;
        transitionImageView.autoresizesSubviews = YES;
        transitionImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleTopMargin;
        
        // add imageView to images array
        [images addObject:imageView];
        [transitionImages addObject:transitionImageView];
        
        int offsetX, offsetY;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offsetX = 50;
            offsetY = 60;
        }
        else {
            offsetX = 3;
            offsetY = 10;
        }
        
        CGSize imageViewSize = imageView.frame.size;
        UIControl *mask = [[UIControl alloc] initWithFrame:CGRectMake(offsetX+x, offsetY+y, imageViewSize.width, imageViewSize.height)];
        [mask addSubview:imageView];
        
        [mask addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
        mask.tag = tag;
        [self.view addSubview:mask];
        
        i++;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (i < 5) {
                x += 192;
            }
            if (i == 5) {
                i = 1;
                x = 0;
                y += 172;
            }
        }
        else {
            if (i < 5) {
                x += 80;
            }
            if (i == 5) {
                i = 1;
                x = 0;
                y += 81;
            }
        }

    }
    
    [self updateImages];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.currentPhotosList = nil;
    self.prevButton = nil;
    self.nextButton = nil;
    self.indicator = nil;
    [self.images removeAllObjects];
    [self.transitionImages removeAllObjects];
    self.transitionView = nil;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.indicator != nil) {
        if ([self.indicator isAnimating]) {
            [self.indicator stopAnimating];
        }
        [self.indicator removeFromSuperview];
        self.indicator = nil;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [album removeObserver:self forKeyPath:@"currentPageNumber"];    
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isMemberOfClass:[RAWretchAlbum class]]) {
        if ([keyPath isEqualToString:@"currentPageNumber"]) {
            //int pages = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
            //NSLog(@"pages: %d", pages);
            
            // get and update current images, and update nextButton.
            [self updateImages];
        }
    }
}


#pragma mark - ShowPhotoViewControllerDelegate Methods

- (void)showPhotoViewDidDisappear
{
    [UIView animateWithDuration:0.3 animations:^{
        self.transitionView.frame = thumbnailRect;
    } completion:^(BOOL finished) {
        [self.transitionView removeFromSuperview];
        for (UIImageView *imgView in images) {
            imgView.alpha = 1.0f;
        }
    }];
}


#pragma mark - Private Methods

- (void)updateImages
{
    // setup indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-25, [UIScreen mainScreen].bounds.size.height/2, 50, 50)];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicator.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.indicator.layer setShadowOffset:CGSizeMake(4, 4)];
    [self.indicator.layer setShadowOpacity:1.0f];
    
    [self.navigationController.view addSubview:self.indicator];
    [self.indicator startAnimating];
    
    
    for (int i=0; i<=20; i++) {
        UIImageView *imageView = [images objectAtIndex:i];
        [imageView setImage:nil];
        
        UIImageView *transitionImageView = [transitionImages objectAtIndex:i];
        [transitionImageView setImage:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // get photoURLs
        self.currentPhotosList = [album photoURLsOfCurrentPage];
        
        // update images
        int tag = 0;
        for (RAWretchPhotoURL *photo in self.currentPhotosList) {
            NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                    timeoutInterval:30];
            NSURLResponse *urlResponse;
            NSError *error;
            NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&urlResponse
                                                     error:&error];
            // update thumbnail image
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *originalImage = [[UIImage alloc] initWithData:data];
                UIImage *tmpImage = [self imageWithUIImage:originalImage withBorderWidth:5.0f];
                UIImage *image = [self imageWithShadow:tmpImage];
                
                UIImageView *imageView = [images objectAtIndex:tag];
                [imageView setImage:image];
                
                UIImageView *transitionImageView = [transitionImages objectAtIndex:tag];
                [transitionImageView setImage:image];
            });
            tag++;
        }
        
        // update button and indicator
        dispatch_async(dispatch_get_main_queue(), ^{
            // setup prevButton
            if (self.album.currentPageNumber <= 1) {
                [self.prevButton setEnabled:NO];
            }
            else {
                [self.prevButton setEnabled:YES];
            }
            
            // setup nextButton
            if (self.album.isNextPage) {
                [self.nextButton setEnabled:YES];
            }
            else {
                [self.nextButton setEnabled:NO];
            }
            
            // stop indicator
            if (self.indicator != nil) {
                [self.indicator stopAnimating];
                [self.indicator removeFromSuperview];
                self.indicator = nil;
            }
        });
    });
}


- (void)prevPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    if (self.album.currentPageNumber > 1) {
        self.album.currentPageNumber--;
    }
}


- (void)nextPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    self.album.currentPageNumber++;
}


- (void)showPhoto:(id)sender
{
    int tag = [sender tag];
    
    if (tag < [currentPhotosList count]) {
        RAWretchPhotoURL *photoURL = [currentPhotosList objectAtIndex:tag];
        ShowPhotoViewController *controller = [[ShowPhotoViewController alloc] initWithPhotoURL:photoURL];
        [controller setDelegate:self];
        
        UIImageView *transitionImageView = [transitionImages objectAtIndex:tag];
        CGRect senderRect = [sender frame];
        CGRect rect = [self frameSizeForImage:transitionImageView.image inImageView:transitionImageView];
        thumbnailRect = CGRectMake(senderRect.origin.x + rect.origin.x, senderRect.origin.y + rect.origin.y,rect.size.width , rect.size.height);
        
        transitionImageView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        self.transitionView = [[UIView alloc] initWithFrame:thumbnailRect];
        //self.transitionView.backgroundColor = [UIColor lightGrayColor];
        
        [self.transitionView addSubview:transitionImageView];
        [self.view addSubview:transitionView];
        
        // hide images
        for (UIImageView *imgView in images) {
            imgView.alpha = 0.0f;
        }

        [UIView animateWithDuration:0.3 animations:^{
            self.transitionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
        } completion:^(BOOL finished) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [navController.navigationBar setTintColor:[UIColor grayColor]];
            navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navController animated:YES completion:nil];
        }];
    }
}


- (UIImage *)imageWithUIImage:(UIImage *)aImage withBorderWidth:(CGFloat)border
{
    CGSize size = CGSizeMake(aImage.size.width+border*2, aImage.size.height+border*2);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    CGRect imageRect = CGRectMake(border, border, aImage.size.width, aImage.size.height);
    [aImage drawInRect:imageRect];
    
    
    UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tmpImage;
}


- (UIImage *)imageWithShadow:(UIImage *)aImage
{
    CGSize size = CGSizeMake(aImage.size.width+5, aImage.size.height+5);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShadow(context, CGSizeMake(3, 3), 2);
    CGRect rect = CGRectMake(0, 0, aImage.size.width, aImage.size.height);
    [aImage drawInRect:rect];
    
    UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmpImage;
}


- (CGRect)frameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView
{
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}


@end
