//
//  OpenCV.h
//  OpenCVSample_iOS
//
//  Created by Hiroki Ishiura on 2020/01/04.
//  Copyright © 2020 Hiroki Ishiura. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCV : NSObject

/// Converts a full color image to grayscale image with using OpenCV.
+ (int)detectLaser:(UIImage *)image withH:(float) H;
+ (nonnull UIImage*)calib:(UIImage *)image withH:(float) H;
+ (nonnull UIImage*)detectRed:(UIImage *)image withOrigFrame:(UIImage *) origFrame withXYArray:(CGPoint[])XYArray withIndex: (int) index;
+ (nonnull UIImage*)show10Results:(UIImage *)image withOrigFrame:(UIImage *) origFrame withXYArray:(CGPoint[])XYArray;
+ (nonnull UIImage*)detectLaser2:(UIImage *)image withH:(float) H;
@end

NS_ASSUME_NONNULL_END
