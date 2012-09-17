//
//  AlbumsTableViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlbumsTableViewController.h"
#import "RAWretchAlbum.h"
#import "PhotosViewController.h"


@interface AlbumsTableViewController (MyMethods)
- (void)backToMainView:(id)sender;
- (void)prevPage:(id)sender;
- (void)nextPage:(id)sender;
- (void)updateTable;
-(UIImage*)_centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect;
@end


@implementation AlbumsTableViewController

@synthesize albums;
@synthesize currentAlbumsList;
@synthesize nextButton;
@synthesize prevButton;


- (id)initWithStyle:(UITableViewStyle)style albums:(RAWretchAlbumList *)albumsListObj
{
    self = [super initWithStyle:style];
    if (self) {
        self.albums = albumsListObj;
        self.currentAlbumsList = [self.albums currentList];
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@">"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(nextPage:)];
        self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(prevPage:)];
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [albums wretchID];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
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
    [self.prevButton setEnabled:NO];
    if (self.albums.isNextPage) {
        [self.nextButton setEnabled:YES];
    }
    else {
        [self.nextButton setEnabled:NO];
    }

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.albums = nil;
    self.currentAlbumsList = nil;
    self.prevButton = nil;
    self.nextButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

    NSString *picturesStr = [[NSString alloc] initWithFormat:@"(%@)", album.pictures];
    cell.detailTextLabel.text = picturesStr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RAWretchAlbum *album = [currentAlbumsList objectAtIndex:indexPath.row];
    NSArray* photos = [album photoURLsOfCurrentPage];
    PhotosViewController *controller = [[PhotosViewController alloc] initWithPhotos:photos];
    
    controller.title = [[tableView cellForRowAtIndexPath:indexPath].textLabel text];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - Other Methods

- (void)backToMainView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)prevPage:(id)sender
{
    if (self.albums.currentPageNumber > 1) {
        self.albums.currentPageNumber--;
    }
    
    if (self.albums.currentPageNumber <=1) {
        [self.prevButton setEnabled:NO];
    }
    
    [self updateTable];
}

- (void)nextPage:(id)sender
{
    self.albums.currentPageNumber++;
    
    if (self.albums.currentPageNumber > 1) {
        [self.prevButton setEnabled:YES];
    }
    
    [self updateTable];
}

- (void)updateTable
{
    self.currentAlbumsList = [self.albums currentList];
    [self.tableView reloadData];
    
    if (self.albums.isNextPage) {
        [self.nextButton setEnabled:YES];
    }
    else {
        [self.nextButton setEnabled:NO];
    }
}

#pragma mark - Private Methods

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
