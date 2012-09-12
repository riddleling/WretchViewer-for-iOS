//
//  RAWretchAlbumList.h
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAWretchAlbumList : NSObject

@property int currentPageNumber;
@property (readonly) BOOL isNextPage;
@property (strong, nonatomic) NSString* wretchID;

- (id)initWithWretchID:(NSString *)idString;
- (NSArray *)currentList;

@end
