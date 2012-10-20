//
//  WretchViewerViewController.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/3.
//


#import "WretchViewerViewController.h"
#import "RAWretchAlbumList.h"
#import "RAWretchAlbum.h"
#import "AlbumsTableViewController.h"

/*
@interface WretchViewerViewController ()

@end
*/


@implementation WretchViewerViewController
@synthesize textField;
@synthesize goButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *backgroundTexture = [UIImage imageNamed:@"wood_pattern.png"];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundTexture];
    [self.view setBackgroundColor:backgroundColor];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)searchAlbumsList:(id)sender
{
    NSString *wretchID = textField.text;
    RAWretchAlbumList *albums = [[RAWretchAlbumList alloc] initWithWretchID:wretchID];
    
    AlbumsTableViewController *masterViewController = [[AlbumsTableViewController alloc] initWithStyle:UITableViewStylePlain albums:albums];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    [navController.navigationBar setTintColor:[UIColor grayColor]];
    
    [self presentViewController:navController animated:NO completion:nil];
    
}


@end
