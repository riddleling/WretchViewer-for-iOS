//
//  AlbumsTableViewController.m
//  WretchViewer
//
//  Created by Wei-Chen Linge on 2012/9/12.
//


#import "AlbumsTableViewController.h"
#import "RAWretchAlbum.h"
#import "PhotosViewController.h"


@interface AlbumsTableViewController (PrivateMethods)
- (void)updateTable;
- (void)backToMainView:(id)sender;
- (void)prevPage:(id)sender;
- (void)nextPage:(id)sender;
- (UIImage*)_centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect;
@end


@implementation AlbumsTableViewController

@synthesize albums;
@synthesize currentAlbumsList;
@synthesize nextButton;
@synthesize prevButton;
@synthesize indicator;


- (id)initWithStyle:(UITableViewStyle)style albums:(RAWretchAlbumList *)albumsListObj
{
    self = [super initWithStyle:style];
    if (self) {
        self.albums = albumsListObj;
        [albums addObserver:self forKeyPath:@"currentPageNumber" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}


- (void)loadView
{
    [super loadView];

    // setup Back BarButtonItem
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    // setup switch BarButtonItem
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"▼"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextPage:)];
    self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"▲"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(prevPage:)];
    
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
    
    
    // setup indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 35)];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicator setBackgroundColor:[UIColor darkGrayColor]];
    [self.indicator setAlpha:0.8f];
    
    [self.navigationController.view addSubview:self.indicator];

    
    // setup title
    self.title = [albums wretchID];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    [self updateTable];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.currentAlbumsList = nil;
    self.prevButton = nil;
    self.nextButton = nil;
    self.indicator = nil;
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
    [albums removeObserver:self forKeyPath:@"currentPageNumber"];
}


#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isMemberOfClass:[RAWretchAlbumList class]]) {
        if ([keyPath isEqualToString:@"currentPageNumber"]) {
            //int pages = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
            //NSLog(@"pages: %d", pages);

            // get current album list and update tableView, and update nextButton.
            [self updateTable];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentAlbumsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    RAWretchAlbum *album = [currentAlbumsList objectAtIndex:indexPath.row];
    cell.textLabel.text = album.name;
    
    NSURL *url = [NSURL URLWithString:album.coverURL];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    UIImage *coverImage = [self _centerImage:tempImage inRect:CGRectMake(0, 0, 70, 65)];
    cell.imageView.image = coverImage;

    NSString *picturesStr = [[NSString alloc] initWithFormat:@"%@", album.pictures];
    cell.detailTextLabel.text = picturesStr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAWretchAlbum *album = [currentAlbumsList objectAtIndex:indexPath.row];
    album.currentPageNumber = 1;
    PhotosViewController *controller = [[PhotosViewController alloc] initWithAlbum:album];

    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - Private Methods

- (void)updateTable
{
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // get current list
        self.currentAlbumsList = [self.albums currentList];
        // update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointZero animated:NO];
            
            // setup prevButton
            if (self.albums.currentPageNumber <= 1) {
                [self.prevButton setEnabled:NO];
            }
            else {
                [self.prevButton setEnabled:YES];
            }
            
            // setup nextButton
            if (self.albums.isNextPage) {
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

- (void)backToMainView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)prevPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    if (self.albums.currentPageNumber > 1) {
        self.albums.currentPageNumber--;
    }
}

- (void)nextPage:(id)sender
{
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    
    self.albums.currentPageNumber++;
}


- (UIImage*)_centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect
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
