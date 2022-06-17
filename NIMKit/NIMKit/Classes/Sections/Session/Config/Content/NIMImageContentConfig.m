//
//  NIMImageContentConfig.m
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "NIMImageContentConfig.h"
#import "UIImage+NIMKit.h"
#import "NIMKit.h"

@implementation NIMImageContentConfig
- (CGSize)contentSize:(CGFloat)cellWidth message:(NIMMessage *)message
{
     NIMImageObject *imageObject = (NIMImageObject*)[message messageObject];
    NSAssert([imageObject isKindOfClass:[NIMImageObject class]], @"message should be image");
    
    CGFloat attachmentImageMinWidth  = (cellWidth / 3.0);
    CGFloat attachmemtImageMaxWidth  = (cellWidth / 2.0);
    

    CGSize imageSize;
    if (!CGSizeEqualToSize(imageObject.size, CGSizeZero)) {
        imageSize = imageObject.size;
    }
    else
    {
        UIImage *image = [UIImage imageWithContentsOfFile:imageObject.thumbPath];
        imageSize = image ? image.size : CGSizeZero;
    }
    if (imageSize.width > attachmemtImageMaxWidth) {
        imageSize.height = attachmemtImageMaxWidth / imageSize.width * imageSize.height;
        imageSize.width = attachmemtImageMaxWidth;
    } else if (imageSize.width < attachmentImageMinWidth) {
        imageSize.height = attachmentImageMinWidth / imageSize.width * imageSize.height;
        imageSize.width = attachmentImageMinWidth;
    }
    if (imageSize.height > attachmemtImageMaxWidth) {
        imageSize.width = attachmemtImageMaxWidth / imageSize.height * imageSize.width;
        imageSize.height = attachmemtImageMaxWidth;
    }
    return imageSize;
}

- (NSString *)cellContent:(NIMMessage *)message
{
    return @"NIMSessionImageContentView";
}

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    return [[NIMKit sharedKit].config setting:message].contentInsets;
}



@end
