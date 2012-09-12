//
//  WretchViewerViewController.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WretchViewerViewController.h"
#import "RAWretchAlbumList.h"
#import "RAWretchAlbum.h"
#import "AlbumsTableViewController.h"

@interface WretchViewerViewController ()

@end


@implementation WretchViewerViewController
@synthesize textField;
@synthesize goButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.textField = nil;
    self.goButton = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)searchAlbumsList:(id)sender
{
    NSString *wretchID = textField.text;
    RAWretchAlbumList *albums = [[RAWretchAlbumList alloc] initWithWretchID:wretchID];
    NSArray *list = [albums currentList];
    /*
    int i = 1;
    for (RAWretchAlbum *album in list) {
        NSLog(@"%d: %@, %@, %@, %@", i, album.wretchID, album.number, album.name, album.pictures);
        NSLog(@" => %@", album.coverURL);
        i++;
    }*/
    
    AlbumsTableViewController *masterViewController = [[AlbumsTableViewController alloc] initWithStyle:UITableViewStylePlain albums:list];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [self presentViewController:navController animated:NO completion:^{}];
    
}


@end
