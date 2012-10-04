//
//  RAWretchAlbumList.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 12/9/8.
//


#import <Foundation/Foundation.h>

@interface RAWretchAlbumList : NSObject

@property int currentPageNumber;
@property (readonly) BOOL isNextPage;
@property (strong, nonatomic) NSString* wretchID;

- (id)initWithWretchID:(NSString *)idString;
- (NSArray *)currentList;

@end
