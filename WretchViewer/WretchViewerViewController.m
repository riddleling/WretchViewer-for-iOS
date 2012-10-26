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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.textField = nil;
    self.goButton = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [self.navigationController pushViewController:masterViewController animated:YES];
}


@end
