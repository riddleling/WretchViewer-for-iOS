//
//  RAWretchPhotoURL.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/9/3.
//


#import "RAWretchPhotoURL.h"


@interface RAWretchPhotoURL (RAPrivateMethods)
- (NSString *)_htmlContent:(NSString *) urlString;
- (NSTextCheckingResult *)_matchString:(NSString *)aString regexpPattern:(NSString *)regexpStr;
- (void)_searchPrevPageFromHtmlText:(NSString *)htmlString;
- (void)_searchNextPageFromHtmlText:(NSString *)htmlString;
- (void)_settingFileNameFromURLString:(NSString *)aString;
@end


@implementation RAWretchPhotoURL

@synthesize urlValue;
@synthesize thumbnailURL;
@synthesize isPrevPage;
@synthesize isNextPage;
@synthesize prevPageURL;
@synthesize nextPageURL;
@synthesize fileName;


- (id)initWithURL:(NSString *)photoURLString withThumbnailURL:(NSString *)thumbnailURLString
{
    self = [super init];
    if (self != nil)
    {
        self.urlValue = photoURLString;
        self.thumbnailURL = thumbnailURLString;
        isPrevPage = NO;
        isNextPage = NO;
        self.fileName = @"photo.jpg";
    }
    return self;
}


- (NSString *)convertToFileURL
{
    NSString *htmlText = [self _htmlContent:urlValue];
    if (htmlText == nil){
        NSLog(@"html => %@", htmlText);
    }
    NSString *outString;
    
    // setup isPrevPage
    [self _searchPrevPageFromHtmlText:htmlText];
    
    // setup isNextPage
    [self _searchNextPageFromHtmlText:htmlText];
    
    
    // get file URL.
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<img id='DisplayImage' src='([^']+)' "];
    NSTextCheckingResult *urlMatchStr = [self _matchString:htmlText regexpPattern:regexpStr];
    
    if (urlMatchStr) {
        NSRange range = [urlMatchStr rangeAtIndex:1];
        outString = [htmlText substringWithRange:range];
        [self _settingFileNameFromURLString:outString];
        return outString;
    }
    else {
        NSString *regexpStr2 = [[NSString alloc] initWithFormat:@"<img class='displayimg' src='([^']+)' "];
        NSTextCheckingResult *urlMatchStr2 = [self _matchString:htmlText regexpPattern:regexpStr2];
        
        if (urlMatchStr2) {
            NSRange range = [urlMatchStr2 rangeAtIndex:1];
            outString = [htmlText substringWithRange:range];
            [self _settingFileNameFromURLString:outString];
            return outString;
        }
    }
    return nil;
}


- (NSTextCheckingResult *)_matchString:(NSString *)aString regexpPattern:(NSString *)regexpStr
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexpStr
                                                                                   options:NSRegularExpressionCaseInsensitive 
                                                                                     error:nil];
    NSTextCheckingResult *matchStr = [expression firstMatchInString:aString
                                                                  options:0 
                                                                    range:NSMakeRange(0, [aString length])];
    return matchStr;
}


- (void)_settingFileNameFromURLString:(NSString *)aString
{
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"http://.+/(.+\\.jpg)\\?.+"];
    NSTextCheckingResult *matchStr = [self _matchString:aString regexpPattern:regexpStr];
    
    if (matchStr) {
        NSRange range = [matchStr rangeAtIndex:1];
        self.fileName = [aString substringWithRange:range];
    }
    else {
        self.fileName = @"photo.jpg";
    }
}


- (void)_searchPrevPageFromHtmlText:(NSString *)htmlString
{
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<a id=\"prev\" href=\"\\./(.+?)\" title="];
    NSTextCheckingResult *urlMatchStr = [self _matchString:htmlString regexpPattern:regexpStr];
    
    if (urlMatchStr) {
        NSRange range = [urlMatchStr rangeAtIndex:1];
        prevPageURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", [htmlString substringWithRange:range]];
        isPrevPage = YES;
        //NSLog(@"prev url: (%@)", prevPageURL);
        return;
    }
    
    
    NSString *regexpStr2 = [[NSString alloc] initWithFormat:@"<a class=\"prev_photo\" href=\"\\./(.+?)\" title="];
    NSTextCheckingResult *urlMatchStr2 = [self _matchString:htmlString regexpPattern:regexpStr2];
        
    if (urlMatchStr2) {
        NSRange range = [urlMatchStr2 rangeAtIndex:1];
        prevPageURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", [htmlString substringWithRange:range]];
        isPrevPage = YES;
        //NSLog(@"prev url: (%@)", prevPageURL);
        return;
    }
    
    
    prevPageURL = nil;
    isPrevPage = NO;

}


- (void)_searchNextPageFromHtmlText:(NSString *)htmlString
{
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<a href=\"\\./(.+?)\" id=\"next\" title="];
    NSTextCheckingResult *urlMatchStr = [self _matchString:htmlString regexpPattern:regexpStr];
    
    if (urlMatchStr) {
        NSRange range = [urlMatchStr rangeAtIndex:1];
        nextPageURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", [htmlString substringWithRange:range]];
        isNextPage = YES;
        //NSLog(@"next url: (%@)", nextPageURL);
        return;
    }
    
    
    NSString *regexpStr2 = [[NSString alloc] initWithFormat:@"<a class=\"next_photo\" href=\"\\./(.+?)\" title="];
    NSTextCheckingResult *urlMatchStr2 = [self _matchString:htmlString regexpPattern:regexpStr2];
    
    if (urlMatchStr2){
        NSRange range = [urlMatchStr2 rangeAtIndex:1];
        nextPageURL = [[NSString alloc] initWithFormat:@"http://www.wretch.cc/album/%@", [htmlString substringWithRange:range]];
        isNextPage = YES;
        //NSLog(@"next url: (%@)", nextPageURL);
        return;
    }
    
    
    nextPageURL = nil;
    isNextPage = NO;
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
