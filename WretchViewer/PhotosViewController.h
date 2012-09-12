//
//  PhotosViewController.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosViewController : UIViewController

@property (strong, nonatomic) NSArray *photos;

- (id)initWithPhotos:(NSArray *)array;

@end
