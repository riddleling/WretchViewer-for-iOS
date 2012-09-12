//
//  AlbumsTableViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlbumsTableViewController.h"
#import "RAWretchAlbum.h"


@interface AlbumsTableViewController (MyMethods)
- (void)backToMainView:(id)sender;
-(UIImage*)_centerImage:(UIImage *)inImage inRect:(CGRect) thumbRect;
@end


@implementation AlbumsTableViewController

@synthesize albums;


- (id)initWithStyle:(UITableViewStyle)style albums:(NSArray *)array
{
    self = [super initWithStyle:style];
    if (self) {
        self.albums = array;
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
    self.title = [[albums objectAtIndex:0] wretchID];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backToMainView:)];
    self.navigationItem.leftBarButtonItem = backButton;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.albums = nil;
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
    return [albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    RAWretchAlbum *album = [albums objectAtIndex:indexPath.row];
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
    UIViewController *controller = [[UIViewController alloc] init];
    controller.title = [[tableView cellForRowAtIndexPath:indexPath].textLabel text];
    controller.view = [[UIView alloc] init];
    controller.view.backgroundColor = [UIColor redColor];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - Action Methods

- (void)backToMainView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
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
