//
//  RAWretchAlbum.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/3.
//


#import <Foundation/Foundation.h>

@interface RAWretchAlbum : NSObject

@property int currentPageNumber;
@property (readonly) BOOL isNextPage;
@property (readonly, strong, nonatomic) NSString *wretchID;
@property (readonly, strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *pictures;
@property (strong, nonatomic) NSString *coverURL;


- (id)initWithWretchID:(NSString *)idStr number:(NSString *)numStr;
- (NSArray *)photoURLsOfCurrentPage;

@end
