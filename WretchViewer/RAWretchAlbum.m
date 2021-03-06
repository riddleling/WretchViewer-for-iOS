//
//  RAWretchAlbum.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/3.
//


#import "RAWretchAlbum.h"
#import "RAWretchPhotoURL.h"


@interface RAWretchAlbum (RAPrivateMethods)

- (NSMutableArray *)_photoURLsOfPage:(NSString *)htmlString;
- (void)_searchNextPageFromHtmlText:(NSString *)htmlString;
- (NSString *)_htmlContent:(NSString *) urlString;

@end


@implementation RAWretchAlbum

@synthesize currentPageNumber;
@synthesize isNextPage;
@synthesize wretchID;
@synthesize number;
@synthesize name;
@synthesize pictures;
@synthesize coverURL;

- (id)initWithWretchID:(NSString *)idStr number:(NSString *)numStr
{
    self = [super init];
    if (self != nil)
    {
        isNextPage = NO;
        currentPageNumber = 1;
        wretchID = idStr;
        number = numStr;
    }
    return self;
}


- (NSArray *)photoURLsOfCurrentPage
{
    NSString *albumURL;
    if (currentPageNumber <= 1) {
        albumURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/album.php?id=%@&book=%@", wretchID, number];
    }
    else {
        albumURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/album.php?id=%@&book=%@&page=%d", wretchID, number, currentPageNumber];
    }
    
    NSString *htmlText = [self _htmlContent:albumURL];
    if (htmlText != nil) {
        NSMutableArray *photos = [self _photoURLsOfPage:htmlText];
        // setup isNextPage
        [self _searchNextPageFromHtmlText:htmlText];
    
        if (photos) {
            return photos;
        }
    }

    return nil;
}


- (NSMutableArray *)_photoURLsOfPage:(NSString *)htmlString
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<a href=\"\\./(show\\.php\\?i=%@&b=%@&f=\\d+&p=\\d+&sp=\\d+)\".+><img src=\"(.+)\" border=\"0\"", wretchID, number];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexpStr
                                                                                options:NSRegularExpressionCaseInsensitive 
                                                                                  error:nil];
    NSArray *array = [expression matchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    
    for (NSTextCheckingResult *matchStr in array)
    {
        NSRange range1 = [matchStr rangeAtIndex:1];
        NSString *photoURLStr = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", [htmlString substringWithRange:range1]];
        
        NSRange range2 = [matchStr rangeAtIndex:2];
        NSString *thumbnailURLStr = [htmlString substringWithRange:range2];
        
        RAWretchPhotoURL *photoURL = [[RAWretchPhotoURL alloc] initWithURL:photoURLStr withThumbnailURL:thumbnailURLStr];
        [urls addObject:photoURL];
    }
    
    
    if ([urls count] > 0)
    {
        return urls;
    }
    return nil;
}


- (void)_searchNextPageFromHtmlText:(NSString *)htmlString
{
    int nextPageNumber = currentPageNumber + 1;
    NSString *nextPageURL = [[NSString alloc] initWithFormat:@"album\\.php\\?id=%@&book=%@&page=%d", wretchID, number, nextPageNumber];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:nextPageURL
                                                                                options:NSRegularExpressionCaseInsensitive 
                                                                                  error:nil];
    NSUInteger matchsNumber = [expression numberOfMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    
    if (matchsNumber) {
        isNextPage = YES;
    }
    else {
        isNextPage = NO;
    }
    
}


// Get HTML.
- (NSString *)_htmlContent:(NSString *) urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:30];
    NSURLResponse *urlResponse;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                 returningResponse:&urlResponse
                                                             error:&error];
    if(responseData)
    {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", responseString);
        return responseString;
    }
    return nil;
}

@end
