//
//  WretchViewerViewController.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/3.
//


#import <UIKit/UIKit.h>

@interface WretchViewerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *goButton;


- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)searchAlbumsList:(id)sender;

@end
