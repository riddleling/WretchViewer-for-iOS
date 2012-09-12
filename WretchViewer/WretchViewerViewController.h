//
//  WretchViewerViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WretchViewerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *goButton;


- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)searchAlbumsList:(id)sender;

@end
