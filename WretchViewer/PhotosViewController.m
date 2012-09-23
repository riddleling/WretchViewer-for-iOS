//
//  PhotosViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"
#import "RAWretchPhotoURL.h"
#import "ShowPhotoViewController.h"

@interface PhotosViewController (PrivateMethods)
- (void)updateImages;
- (void)prevPage:(id)sender;
- (void)nextPage:(id)sender;
- (void)showPhoto:(id)sender;
-(UIImage*) _centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect;
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
        
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@">"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(nextPage:)];
        self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(prevPage:)];
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 64, 320, 25)];
        
    }
    return self;
}


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.album.name;
    
    NSMutableArray *tbitems = [[NSMutableArray alloc] init];
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = 5.0f;
    UIBarButtonItem *spaceButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton2.width = 20.0f;
    
    [tbitems addObject:self.nextButton];
    [tbitems addObject:spaceButton1];
    [tbitems addObject:self.prevButton];
    [tbitems addObject:spaceButton2];
    
    self.navigationItem.rightBarButtonItems = tbitems;
    
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.8f];
    
    [self.navigationController.view addSubview:self.indicator];
    
    [album addObserver:self forKeyPath:@"currentPageNumber" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    int i = 1;
    int x = 0;
    int y = 0;
    
    for (int tag=0; tag<=20; tag++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        // add imageView to images array
        [images addObject:imageView];
        
        CGSize imageViewSize = imageView.frame.size;
        UIControl *mask = [[UIControl alloc] initWithFrame:CGRectMake(3+x, 10+y, imageViewSize.width, imageViewSize.height)];
        [mask addSubview:imageView];
        
        [mask addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
        mask.tag = tag;
        [self.view addSubview:mask];
        
        i++;
        if (i < 5) {
            x += 80;
        }
        if (i == 5) {
            i = 1;
            x = 0;
            y += 80;
        }

    }
    
    [self updateImages];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.album = nil;
    self.currentPhotosList = nil;
    self.prevButton = nil;
    self.nextButton = nil;
    self.indicator = nil;
    self.images = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [album removeObserver:self forKeyPath:@"currentPageNumber"];
    //NSLog(@"dealloc...");
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isMemberOfClass:[RAWretchAlbum class]]) {
        if ([keyPath isEqualToString:@"currentPageNumber"]) {
            int pages = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
            //NSLog(@"pages: %d", pages);
            
            // get and update current images, and update nextButton.
            [self updateImages];
            
            // setup prevButton
            if (pages <= 1) {
                [self.prevButton setEnabled:NO];
            }
            else {
                [self.prevButton setEnabled:YES];
            }
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
        self.currentPhotosList = [album photoURLsOfCurrentPage];
        // update image and nextButton
        dispatch_async(dispatch_get_main_queue(), ^{
            int tag = 0;
            for (RAWretchPhotoURL *photo in self.currentPhotosList) {
                NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
                NSData *data = [[NSData alloc] initWithContentsOfURL:url];
                UIImage *image = [[UIImage alloc] initWithData:data];
                
                UIImageView *imageView = [images objectAtIndex:tag];
                [imageView setImage:image];
                tag++;
            }
            if (self.album.isNextPage) {
                [self.nextButton setEnabled:YES];
            }
            else {
                [self.nextButton setEnabled:NO];
            }
            [self.indicator stopAnimating];
        });
    });
}


- (void)prevPage:(id)sender
{
    if (self.album.currentPageNumber > 1) {
        self.album.currentPageNumber--;
    }
}


- (void)nextPage:(id)sender
{
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


-(UIImage*) _centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect
{
    
    CGSize size= thumbRect.size;
    UIGraphicsBeginImageContext(size);  
    //calculation
    [inImage drawInRect:CGRectMake((size.width-inImage.size.width)/2, (size.height-inImage.size.height)/2, inImage.size.width, inImage.size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
    // pop the context
    UIGraphicsEndImageContext();
    return newThumbnail;
}


@end
