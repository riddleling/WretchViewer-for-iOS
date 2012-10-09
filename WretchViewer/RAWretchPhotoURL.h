//
//  RAWretchPhotoURL.h
//  WretchViewer
//
//  Created by Wei-Chen Ling on 12/9/3.
//


#import <Foundation/Foundation.h>

@interface RAWretchPhotoURL : NSObject

@property (strong, nonatomic) NSString *urlValue;
@property (strong, nonatomic) NSString *thumbnailURL;
@property (readonly) BOOL isPrevPage;
@property (readonly) BOOL isNextPage;
@property (readonly, strong, nonatomic) NSString *prevPageURL;
@property (readonly, strong, nonatomic) NSString *nextPageURL;
@property (strong, nonatomic) NSString *fileName;


- (id)initWithURL:(NSString *)photoURLString withThumbnailURL:(NSString *)thumbnailURLString;
- (NSString *)convertToFileURL;

@end
