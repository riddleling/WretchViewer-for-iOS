//
//  RAWretchPhotoURL.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAWretchPhotoURL : NSObject

@property (strong, nonatomic) NSString *urlValue;
@property (strong, nonatomic) NSString *thumbnailURL;
@property (readonly) BOOL isPrevPage;
@property (readonly) BOOL isNextPage;
@property (readonly, strong, nonatomic) NSString *prevPageURL;
@property (readonly, strong, nonatomic) NSString *nextPageURL;


- (id)initWithURL:(NSString *)photoURLString withThumbnailURL:(NSString *)thumbnailURLString;
- (NSString *)convertToFileURL;

@end
