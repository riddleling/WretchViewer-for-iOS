//
//  RAWretchAlbumList.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RAWretchAlbumList.h"
#import "RAWretchAlbum.h"


@interface RAWretchAlbumList (RAPrivateMethods)
- (NSString *)_htmlContent:(NSString *) urlString;
- (void)_searchNextPageFromHtmlText:(NSString *)htmlString;
- (NSArray *)_albumsOfPage:(NSString *)htmlString;
@end


@implementation RAWretchAlbumList

@synthesize wretchID;
@synthesize currentPageNumber;
@synthesize isNextPage;


- (id)initWithWretchID:(NSString *)idString
{
    self = [super init];
    if (self != nil) {
        isNextPage = NO;
        wretchID = idString;
        currentPageNumber = 1;
    }
    return self;
}


- (NSArray *)currentList
{
    NSString *albumsURL;
    if (currentPageNumber < 2) {
        albumsURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", wretchID];
    }
    else {
        albumsURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@&page=%d", wretchID, currentPageNumber];
    }
    //NSLog(@"%@", albumsURL);
    
    NSString *htmlText = [self _htmlContent:albumsURL];
    NSArray *albums = [self _albumsOfPage:htmlText];
    // setup isNextPage
    [self _searchNextPageFromHtmlText:htmlText];
    
    if (albums) {
        return albums;
    }
    
    return nil;
}


- (NSArray *)_albumsOfPage:(NSString *)htmlString
{
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    // get albums number, cover URL 
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<a href=\"\\./album\\.php\\?id=%@&book=(\\d+)[^>]+>[^<]+<img src=\"(.+)\" border=\"0\" alt=", wretchID];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexpStr
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    NSArray *array = [expression matchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    
    for (NSTextCheckingResult *matchStr in array)
    {
        NSRange range1 = [matchStr rangeAtIndex:1];
        NSString *numStr = [htmlString substringWithRange:range1];
        
        NSRange range2 = [matchStr rangeAtIndex:2];
        NSString *coverURLStr = [htmlString substringWithRange:range2];
        
        RAWretchAlbum *album = [[RAWretchAlbum alloc] initWithWretchID:wretchID number:numStr];
        [albums addObject:album];
        
        album.coverURL = coverURLStr;
    }
    
    if ([albums count] > 0) {
        // get album name
        NSString *regexpStr2 = [[NSString alloc] initWithFormat:@"<a href=\"\\./album\\.php\\?id=%@&book=(\\d+)\">(.+)</a>", wretchID];
        NSRegularExpression *expression2 = [NSRegularExpression regularExpressionWithPattern:regexpStr2
                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                       error:nil];
        NSArray *array2 = [expression2 matchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
        NSMutableDictionary *nameDict = [[NSMutableDictionary alloc] init];
        
        for (NSTextCheckingResult *matchStr in array2) {
            NSRange range1 = [matchStr rangeAtIndex:1];
            NSString *numStr = [htmlString substringWithRange:range1];
        
            NSRange range2 = [matchStr rangeAtIndex:2];
            NSString *nameStr = [htmlString substringWithRange:range2];
            [nameDict setObject:nameStr forKey:numStr];
        }
    
        for (RAWretchAlbum *album in albums) {
            album.name = [nameDict objectForKey:album.number];
        }
    
        // get pictures
        NSString *regexpStr3 = [[NSString alloc] initWithFormat:@"(\\d+)pictures\\s*</font>"];
        NSRegularExpression *expression3 = [NSRegularExpression regularExpressionWithPattern:regexpStr3
                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                       error:nil];
        NSArray *array3 = [expression3 matchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    
        int index = 0;
        for (NSTextCheckingResult *matchStr in array3) {
            NSRange range = [matchStr rangeAtIndex:1];
            NSString *picturesStr = [htmlString substringWithRange:range];
            if (index < [albums count]) { 
                RAWretchAlbum *album = [albums objectAtIndex:index];
                album.pictures = picturesStr;
            }
            index++;
        }
        
        return [albums copy];
    }
    return nil;
}


- (void)_searchNextPageFromHtmlText:(NSString *)htmlString
{
    int nextPageNumber = currentPageNumber + 1;
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"href=\"%@&page=%d\"", wretchID, nextPageNumber];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexpStr
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSUInteger matchsNumber = [expression numberOfMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length])];
    
    if (matchsNumber) {
        isNextPage =YES;
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
