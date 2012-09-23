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
@end



@implementation ShowPhotoViewController

@synthesize photoURL;
@synthesize indicator;


- (id)initWithPhotoURL:(RAWretchPhotoURL *)aPhotoURL
{
    self = [super init];
    if (self != nil)
    {
        self.photoURL = aPhotoURL;
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
	// Do any additional setup after loading the view.
    self.title = @"Photo";
    
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.8f];
    
    [self.navigationController.view addSubview:self.indicator];
    [self photoDisplay];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private Methods

- (void)photoDisplay
{
    [self.indicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:[self.photoURL convertToFileURL]];
        NSData *data;
        if (url != nil) {
            data = [[NSData alloc] initWithContentsOfURL:url];
        }
        else {
            NSURL *turl = [NSURL URLWithString:[self.photoURL thumbnailURL]];
            data = [[NSData alloc] initWithContentsOfURL:turl];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [[UIImage alloc] initWithData:data];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-20-44)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:imageView];
            [self.indicator stopAnimating];
        });
    });
}


@end
