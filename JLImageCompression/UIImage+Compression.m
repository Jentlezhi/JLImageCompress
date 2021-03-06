//
//  UIImage+Compression.m
//  JLImageCompression
//
//  Created by Rong Mac mini on 2017/9/9.
//  Copyright © 2017年 Ronginet. All rights reserved.
//

#import "UIImage+Compression.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Compression)

+ (UIImage *)jl_compressWithImage:(UIImage *)image imageType:(JLImageFormat)imageType specifySize:(CGFloat)size {
    if (size == 0) {
        return image;
    }
    
    if (imageType == JLImageFormatPNG) {
        NSData *data = UIImagePNGRepresentation(image);
        return [self jl_compressWithImage:data specifySize:size];
    }
    
    if (imageType == JLImageFormatJPEG) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        return [self jl_compressWithImage:data specifySize:size];
    }
    
    return image;
}

+ (UIImage *)jl_compressWithImage:(NSData *)imageData specifySize:(CGFloat)size {
    if (!imageData || size == 0) {
        return nil;
    }
    
    CGFloat specifySize = size * 1000 * 1000;
    
    JLImageFormat imageFormat = [NSData jl_imageFormatWithImageData:imageData];
    if (imageFormat == JLImageFormatPNG) {
        UIImage *image = [UIImage imageWithData:imageData];
        while (imageData.length > specifySize) {
            CGFloat targetWidth = image.size.width * 0.9;
            CGFloat targetHeight = image.size.height * 0.9;
            CGRect maxRect = CGRectMake(0, 0, targetWidth, targetHeight);
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(floorf(targetWidth), floorf(targetHeight)), NO, [UIScreen mainScreen].scale);
            [image drawInRect:maxRect];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            imageData = UIImagePNGRepresentation(image);
        }
        return image;
    }
    
    if (imageFormat == JLImageFormatJPEG) {
        UIImage *image = [UIImage imageWithData:imageData];
        while (imageData.length > specifySize) {
            imageData = UIImageJPEGRepresentation(image, 0.9);
            image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        }
        return image;
    }
    
    if (imageFormat == JLImageFormatGIF) {
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        size_t count = CGImageSourceGetCount(source);
        NSTimeInterval duration = count * (1 / 30.0);
        NSMutableArray<UIImage *> *images = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
            UIImage *image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [images addObject:image];
            CGImageRelease(cgImage);
        }
        CFRelease(source);
        
        while (imageData.length > size) {
            for (UIImage *image in images) {
                UIImage *img = image;
                CGFloat targetWidth = img.size.width * 0.9;
                CGFloat targetHeight = img.size.height * 0.9;
                CGRect maxRect = CGRectMake(0, 0, targetWidth, targetHeight);
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(floorf(targetWidth), floorf(targetHeight)), NO, [UIScreen mainScreen].scale);
                [img drawInRect:maxRect];
                img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                imageData = UIImagePNGRepresentation(img);
            }
        }
        return [UIImage animatedImageWithImages:images duration:duration];
    }
    
    return [UIImage imageWithData:imageData];
}

@end
