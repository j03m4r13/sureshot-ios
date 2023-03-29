//
//  OpenCV.mm
//  OpenCVSample_iOS
//
//  Created by Hiroki Ishiura on 2020/01/04.
//  Copyright © 2020 Hiroki Ishiura. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>
#pragma clang diagnostic pop

#import <UIKit/UIKit.h>
#import "OpenCV.h"

/// Converts an UIImage to Mat.
/// Orientation of UIImage will be lost.
static void UIImageToMat(UIImage *image, cv::Mat &mat) {
	assert(image.size.width > 0 && image.size.height > 0);
	assert(image.CGImage != nil || image.CIImage != nil);

	// Create a pixel buffer.
	NSInteger width = image.size.width;
	NSInteger height = image.size.height;
	cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);

	// Draw all pixels to the buffer.
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (image.CGImage) {
		// Render with using Core Graphics.
		CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
		CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);
		CGContextRelease(contextRef);
	} else {
		// Render with using Core Image.
		static CIContext* context = nil; // I do not like this declaration contains 'static'. But it is for performance.
		if (!context) {
			context = [CIContext contextWithOptions:@{ kCIContextUseSoftwareRenderer: @NO }];
		}
		CGRect bounds = CGRectMake(0, 0, width, height);
		[context render:image.CIImage toBitmap:mat8uc4.data rowBytes:mat8uc4.step bounds:bounds format:kCIFormatRGBA8 colorSpace:colorSpace];
	}
	CGColorSpaceRelease(colorSpace);

	// Adjust byte order of pixel.
	cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
	cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);

	mat = mat8uc3;
}

/// Converts a Mat to UIImage.
static UIImage *MatToUIImage(cv::Mat &mat) {

	// Create a pixel buffer.
	assert(mat.elemSize() == 1 || mat.elemSize() == 3);
	cv::Mat matrgb;
	if (mat.elemSize() == 1) {
		cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
	} else if (mat.elemSize() == 3) {
		cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
	}

	// Change a image format.
	NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
	CGColorSpaceRef colorSpace;
	if (matrgb.elemSize() == 1) {
		colorSpace = CGColorSpaceCreateDeviceGray();
	} else {
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);

	return image;
}

/// Restore the orientation to image.
static UIImage *RestoreUIImageOrientation(UIImage *processed, UIImage *original) {
	if (processed.imageOrientation == original.imageOrientation) {
		return processed;
	}
	return [UIImage imageWithCGImage:processed.CGImage scale:1.0 orientation:original.imageOrientation];
}

@implementation OpenCV

//+ (nonnull UIImage *)cvtColorBGR2GRAY:(nonnull UIImage *)image {
//	cv::Mat bgrMat;
//	UIImageToMat(image, bgrMat);
//	cv::Mat grayMat;
//
//	cv::cvtColor(bgrMat, grayMat, cv::COLOR_BGR2GRAY);
//	UIImage *grayImage = MatToUIImage(grayMat);
//	return RestoreUIImageOrientation(grayImage, image);
//}
+ (bool)detectLaser:(UIImage *)image withH:(float) H {
    cv::Mat mat1;
    cv::Mat mat2;
    cv::Mat mat3;
    cv::Mat mat;
    cv::Mat dst;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<std::vector<cv::Point> > contours;
    UIImageToMat(image, mat);
    cv::bitwise_not(mat, mat);
    cv::cvtColor(mat, mat1, cv::COLOR_BGR2HSV);
    cv::GaussianBlur(mat, mat1, cv::Size(5.0, 5.0), 2.0);
//    cv::Scalar lower_range(0.0, 70.0, 50.0);
//    cv::Scalar upper_range(10.0, 255.0, 255.0);
//    cv::Scalar lower_range_b(0.0, 70.0, 50.0);
//    cv::Scalar upper_range_b(30.0, 255.0, 255.0);
//    cv::Scalar lower_range(230, 100, 50);
//    cv::Scalar upper_range(250, 255, 255);
//    cv::Scalar lower_range_b(230 , 100, 50);
//    cv::Scalar upper_range_b(10, 255, 255);
        //working at night
//    cv::Scalar lower_range(240, 200, 50);
//    cv::Scalar upper_range(255, 255, 250);
//    cv::Scalar lower_range_b(245 , 200, 50);
//    cv::Scalar upper_range_b(255, 255, 250);

//
//    cv::Scalar lower_range(50, 200, 20);
//    cv::Scalar upper_range(100, 255, 250);
//    cv::Scalar lower_range_b(100 , 200, 20);
//    cv::Scalar upper_range_b(179, 255, 250);

    cv::Scalar lower_range(150, 200, 10);
    cv::Scalar upper_range(170, 255, 25);
    cv::Scalar lower_range_b(190 , 250, 10);
    cv::Scalar upper_range_b(210, 255, 30);

    cv::inRange(mat1, lower_range, upper_range, mat2);
    cv::inRange(mat1, lower_range_b, upper_range_b, mat3);
    cv::bitwise_or(mat2, mat3, dst);
    cv::findContours(dst, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    int contourCntr;
    for(contourCntr = 0; contourCntr < contours.size(); contourCntr++){
        if(contourCntr >= 1) break;
        cv::Mat_<cv::Point2f> approxCurve;
   
        cv::Mat_<cv::Point2f> contour2f = cv::Mat(contours[contourCntr]);


        double approxDistance = cv::arcLength(contour2f, true) * 0.02;
        cv::approxPolyDP(contour2f, approxCurve, approxDistance, true);
        cv::Mat points = cv::Mat(approxCurve); // define a matrix of 2D points
        cv::Rect rect = cv::boundingRect(points);
        
        double shotX = rect.x + (rect.width / 2.0);
        double shotY = rect.y + (rect.height / 2.0);
        
        
    }
    if (contourCntr >= 1)
        return true;
    
    return false;
//    UIImage *contoured = MatToUIImage(dst);
//    return RestoreUIImageOrientation(contoured, image);
}


+ (nonnull UIImage*)detectRed:(UIImage *)image withOrigFrame:(UIImage *) origFrame withXYArray:(CGPoint[])XYArray withIndex: (int) index{
    cv::Mat mat1;
    cv::Mat mat2;
    cv::Mat mat3;
    cv::Mat mat;
    cv::Mat dst;
    cv::Mat origFrameMat;
    
    std::vector<cv::Vec4i> hierarchy;
    std::vector<std::vector<cv::Point> > contours;
    UIImageToMat(image, mat);
    UIImageToMat(origFrame, origFrameMat);
    cv::bitwise_not(mat, mat);
    cv::cvtColor(mat, mat1, cv::COLOR_BGR2HSV);
    cv::GaussianBlur(mat, mat1, cv::Size(5.0, 5.0), 2.0);
//
//    cv::Scalar lower_range(230, 100, 50);
//    cv::Scalar upper_range(230, 255, 255);
//    cv::Scalar lower_range_b(230 , 100, 50);
////    cv::Scalar upper_range_b(10, 255, 255);
    // working at night
//    cv::Scalar lower_range(240, 200, 50);
//    cv::Scalar upper_range(255, 255, 250);
//    cv::Scalar lower_range_b(245 , 200, 50);
//    cv::Scalar upper_range_b(255, 255, 250);

//    cv::Scalar lower_range(50, 200, 20);
//    cv::Scalar upper_range(100, 255, 250);
//    cv::Scalar lower_range_b(100 , 200, 20);
//    cv::Scalar upper_range_b(179, 255, 250);

    cv::Scalar lower_range(150, 200, 10);
    cv::Scalar upper_range(170, 255, 25);
    cv::Scalar lower_range_b(190 , 250, 10);
    cv::Scalar upper_range_b(210, 255, 30);

    cv::inRange(mat1, lower_range, upper_range, mat2);
    cv::inRange(mat1, lower_range_b, upper_range_b, mat3);
    cv::bitwise_or(mat2, mat3, dst);
    cv::findContours(dst, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    int contourCntr;
    for(contourCntr = 0; contourCntr < contours.size(); contourCntr++){
        if(contourCntr >= 1) break;
        cv::Mat_<cv::Point2f> approxCurve;
   
        cv::Mat_<cv::Point2f> contour2f = cv::Mat(contours[contourCntr]);

        
        double approxDistance = cv::arcLength(contour2f, true) * 0.02;
        cv::approxPolyDP(contour2f, approxCurve, approxDistance, true);
        cv::Mat points = cv::Mat(approxCurve); // define a matrix of 2D points
        cv::Rect rect = cv::boundingRect(points);
        
        double shotX = rect.x + (rect.width / 2.0);
        double shotY = rect.y + (rect.height / 2.0);
       // circle(origFrameMat, org.opencv.core.Point(shotX, shotY),7, Scalar(0.0, 255.0, 0.0), 2)
    
        CGPoint point = CGPointMake(shotX, shotY);
        XYArray[index].x = point.x;
        XYArray[index].y = point.y;
        
        cv::circle(origFrameMat, cv::Point(shotX, shotY), 7, cv::Scalar(0, 255, 0), 5);

    }
    //if (contourCntr >= 1)
    //    return true;
    //
    //return false;
    UIImage *markedFrame = MatToUIImage(origFrameMat);
    return RestoreUIImageOrientation(markedFrame, image);
}

+ (nonnull UIImage*)show10Results:(UIImage *)image withOrigFrame:(UIImage *) origFrame withXYArray:(CGPoint[])XYArray{
    cv::Mat mat1;
    cv::Mat mat2;
    cv::Mat mat3;
    cv::Mat mat;
    cv::Mat dst;
    cv::Mat origFrameMat;
    
    UIImageToMat(image, mat);
    UIImageToMat(origFrame, origFrameMat);
    for(int i = 0; i < 10; i++){
        cv::circle(origFrameMat, cv::Point(XYArray[i].x, XYArray[i].y), 7, cv::Scalar(0, 255, 0), 5);

    }
    //cv::circle(origFrameMat, cv::Point(shotX, shotY), 7, cv::Scalar(0, 255, 0), 5);

    UIImage *markedFrame = MatToUIImage(origFrameMat);
    return RestoreUIImageOrientation(markedFrame, image);
}

+ (nonnull UIImage*)calib:(UIImage *)image withH:(float) H;{
    cv::Mat mat1;
    cv::Mat mat2;
    cv::Mat mat3;
    cv::Mat mat;
    cv::Mat dst;
    std::vector<cv::Vec4i> hierarchy;
    std::vector<std::vector<cv::Point> > contours;
    UIImageToMat(image, mat);
    cv::bitwise_not(mat, mat);
    cv::cvtColor(mat, mat1, cv::COLOR_BGR2HSV);
    cv::GaussianBlur(mat, mat1, cv::Size(5.0, 5.0), 2.0);
//    cv::Scalar lower_range(0.0, 70.0, 50.0);
//    cv::Scalar upper_range(10.0, 255.0, 255.0);
//    cv::Scalar lower_range_b(0.0, 70.0, 50.0);
//    cv::Scalar upper_range_b(30.0, 255.0, 255.0);
//    cv::Scalar lower_range(H, 70, 50);
//    cv::Scalar upper_range(H+10, 255, 255);
//    cv::Scalar lower_range_b(H , 70, 50);
//    cv::Scalar upper_range_b(H-220, 255, 255);
    cv::Scalar lower_range(150, 200, 10);
    cv::Scalar upper_range(170, 255, 25);
    cv::Scalar lower_range_b(190 , 250, 10);
    cv::Scalar upper_range_b(210, 255, 30);

    cv::inRange(mat1, lower_range, upper_range, mat2);
    cv::inRange(mat1, lower_range_b, upper_range_b, mat3);
    cv::bitwise_or(mat2, mat3, dst);
//    cv::findContours(dst, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
//    int contourCntr;
//    for(contourCntr = 0; contourCntr < contours.size(); contourCntr++){
//        //if(contourCntr >= 1) break;
//        cv::Mat_<cv::Point2f> approxCurve;
//
//        cv::Mat_<cv::Point2f> contour2f = cv::Mat(contours[contourCntr]);
//
//
//        double approxDistance = cv::arcLength(contour2f, true) * 0.02;
//        cv::approxPolyDP(contour2f, approxCurve, approxDistance, true);
//        cv::Mat points = cv::Mat(approxCurve); // define a matrix of 2D points
//        cv::Rect rect = cv::boundingRect(points);
//
//        double shotX = rect.x + (rect.width / 2.0);
//        double shotY = rect.y + (rect.height / 2.0);
//
//
//    }
//    if(contourCntr >= 1){
//        printf("%d Contour Found\n", contourCntr);
//
//    }

    UIImage *contoured = MatToUIImage(mat3);
    return RestoreUIImageOrientation(contoured, image);
}

@end
