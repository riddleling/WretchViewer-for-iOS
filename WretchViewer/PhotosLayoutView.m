//
//  PhotosLayoutView.m
//  WretchViewer
//
//  Created by Wei-Chen Ling on 2012/10/31.
//
//

#import "PhotosLayoutView.h"

@implementation PhotosLayoutView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.images = [[NSMutableArray alloc] init];
        
        int i = 1;
        int x = 0;
        int y = 0;
        
        // tag 從 10 開始
        for (int tag=10; tag<30; tag++) {
            UIImageView *imageView;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
            }
            else {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
            }
            
            imageView.contentMode = UIViewContentModeScaleAspectFit;
                    
            int offsetX, offsetY;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                offsetX = 50;
                offsetY = 60;
            }
            else {
                offsetX = 3;
                offsetY = 10;
            }
            
            CGSize imageViewSize = imageView.frame.size;
            UIControl *mask = [[UIControl alloc] initWithFrame:CGRectMake(offsetX+x, offsetY+y, imageViewSize.width, imageViewSize.height)];
            [mask addSubview:imageView];
            
            
            imageView.tag = tag + 100;
            mask.tag = tag;
            [self addSubview:mask];
            
            i++;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if (i < 5) {
                    x += 192;
                }
                if (i == 5) {
                    i = 1;
                    x = 0;
                    y += 172;
                }
            }
            else {
                if (i < 5) {
                    x += 80;
                }
                if (i == 5) {
                    i = 1;
                    x = 0;
                    y += 81;
                }
            }
        
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setImages:(NSArray *)array
{
    // imageView 的 tag 從 110 ~ 129
    for (int i=110; i<=129; i++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:i];
        [imageView setImage:nil];
    }
    
    if (array.count <= 20) {
        int i = 110;
        for (UIImage *image in array) {
            UIImageView *imageView = (UIImageView *)[self viewWithTag:i];
            [imageView setImage:image];
            i++;
        }
    }
}




@end
