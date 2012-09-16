//
//  RAWretchPhotoURL.m
//  WretchViewer
//
//  Created by Ling Riddle on 12/9/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RAWretchPhotoURL.h"


@interface RAWretchPhotoURL (RAPrivateMethods)
- (NSString *)_htmlContent:(NSString *) urlString;
- (NSTextCheckingResult *)_matchString:(NSString *)aString regexpPattern:(NSString *)regexpStr;
@end


@implementation RAWretchPhotoURL

@synthesize urlValue;
@synthesize thumbnailURL;


- (id)initWithURL:(NSString *)photoURLString withThumbnailURL:(NSString *)thumbnailURLString
{
    self = [super init];
    if (self != nil)
    {
        urlValue = photoURLString;
        thumbnailURL = thumbnailURLString;
    }
    return self;
}


- (NSString *)convertToFileURL
{
    NSString *htmlText = [self _htmlContent:urlValue];
    NSString *outString;
    
    NSString *regexpStr = [[NSString alloc] initWithFormat:@"<img id='DisplayImage' src='([^']+)' "];
    NSTextCheckingResult *urlMatchStr = [self _matchString:htmlText regexpPattern:regexpStr];
    
    if (urlMatchStr) {
        NSRange range = [urlMatchStr rangeAtIndex:1];
        outString = [htmlText substringWithRange:range];
        return outString;
    }
    else {
        NSString *regexpStr2 = [[NSString alloc] initWithFormat:@"<img class='displayimg' src='([^']+)' "];
        NSTextCheckingResult *urlMatchStr2 = [self _matchString:htmlText regexpPattern:regexpStr2];
        
        if (urlMatchStr2) {
            NSRange range = [urlMatchStr2 rangeAtIndex:1];
            outString = [htmlText substringWithRange:range];
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
