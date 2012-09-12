//
//  PhotosViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"
#import "RAWretchPhotoURL.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController
@synthesize photos;

- (id)initWithPhotos:(NSArray *)array
{
    self = [super init];
    if (self != nil)
    {
        self.photos = array;
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
    
    //self.view.backgroundColor = [UIColor whiteColor];
    
    int i = 1;
    int x = 0;
    int y = 0;
    
    for (RAWretchPhotoURL *photo in photos) {
        NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        imageView.frame = CGRectMake(3+x, 3+y, 75, 75);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:imageView];
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
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.photos = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
