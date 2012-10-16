//
//  PhotosViewController.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/13.
//


#import "PhotosViewController.h"
#import "RAWretchPhotoURL.h"
#import "ShowPhotoViewController.h"

@interface PhotosViewController (PrivateMethods)
- (void)updateImages;
- (void)prevPage:(id)sender;
- (void)nextPage:(id)sender;
- (void)showPhoto:(id)sender;
@end


@implementation PhotosViewController

@synthesize album;
@synthesize currentPhotosList;
@synthesize prevButton;
@synthesize nextButton;
@synthesize indicator;
@synthesize images;


- (id)initWithAlbum:(RAWretchAlbum *)aAlbum
{
    self = [super init];
    if (self != nil)
    {
        self.album = aAlbum;
        self.images = [[NSMutableArray alloc] init];
        [album addObserver:self forKeyPath:@"currentPageNumber" options:NSKeyValueObservingOptionNew context:NULL];
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
    
    
    // setup indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 30)];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.9f];

    [self.navigationController.view addSubview:self.indicator];
    
    // setup title
    self.title = self.album.name;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];

    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    int i = 1;
    int x = 0;
    int y = 0;
    
    for (int tag=0; tag<=20; tag++) {
        UIImageView *imageView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        }
        else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        // add imageView to images array
        [images addObject:imageView];
        
        int offsetX, offsetY;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offsetX = 50;
            offsetY = 50;
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
                y += 180;
            }
        }
        else {
            if (i < 5) {
                x += 80;
            }
            if (i == 5) {
                i = 1;
                x = 0;
                y += 80;
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


#pragma mark - Private Methods

- (void)updateImages
{
    [self.indicator startAnimating];
    
    for (int i=0; i<=20; i++) {
        UIImageView *imageView = [images objectAtIndex:i];
        [imageView setImage:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // get photoURLs
        self.currentPhotosList = [album photoURLsOfCurrentPage];
        
        // update images
        int tag = 0;
        for (RAWretchPhotoURL *photo in self.currentPhotosList) {
            NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
            //NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            
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
                UIImage *image = [[UIImage alloc] initWithData:data];
                UIImageView *imageView = [images objectAtIndex:tag];
                [imageView setImage:image];
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
            [self.indicator stopAnimating];
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
    //NSLog(@"tag: %d", tag);
    
    if (tag < [currentPhotosList count]) {
        RAWretchPhotoURL *photoURL = [currentPhotosList objectAtIndex:tag];
        ShowPhotoViewController *controller = [[ShowPhotoViewController alloc] initWithPhotoURL:photoURL];
    
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}


@end
