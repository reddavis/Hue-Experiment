//
//  HUEAverageColorCalculator.m
//  Hue Ambience
//
//  Created by Red Davis on 04/01/2014.
//  Copyright (c) 2014 Red Davis. All rights reserved.
//

#import "HUEAverageColorCalculator.h"


@interface HUEAverageColorCalculator ()

@property (strong, nonatomic) NSOperationQueue *imageOperationQueue;

@end

@implementation HUEAverageColorCalculator

#pragma mark - Initialization

- (id)init
{
	self = [super init];
	if (self)
	{
		self.imageOperationQueue = [[NSOperationQueue alloc] init];
	}
	
	return self;
}

#pragma mark -

struct Pixel {
    unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
};

// http://alienryderflex.com/hsp.html
static inline CGFloat CalculateLuminanceForColor(CGFloat red, CGFloat green, CGFloat blue)
{
	CGFloat luminance = sqrtf((0.299 * (red*red) + 0.587 * (green*green) + 0.114 * (blue*blue)));
	return luminance;
};

- (void)calculateAverageColorAndBrightnessForImage:(UIImage *)image withCompletionBlock:(void (^)(UIColor *, CGFloat))block
{
	[self.imageOperationQueue addOperationWithBlock:^{
		NSUInteger red = 0;
		NSUInteger green = 0;
		NSUInteger blue = 0;
		NSInteger bytePerRow = image.size.width * 4;
//		NSInteger bytesPerPixel = 4;
		
		struct Pixel *pixels = (struct Pixel *)calloc(1, image.size.width * image.size.height * sizeof(struct Pixel));
		if (pixels != nil)
		{
			
			CGContextRef context = CGBitmapContextCreate(
														 (void *)pixels,
														 image.size.width,
														 image.size.height,
														 8,
														 bytePerRow,
														 CGImageGetColorSpace(image.CGImage),
														 (CGBitmapInfo)kCGImageAlphaPremultipliedLast
														 );
			
			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
			NSUInteger numberOfPixels = image.size.width * image.size.height;
			
			// TODO: Rather than looking at every pixel we should just at every nth pixel
			
			// TODO: Rather than using the whole image, we could just look at the bordering
			// pixels. They should provide us with more ambient colour. However, this does require
			// the iPhone to have the full screen in shot and not move too much.
			// NSInteger pixelIndex = (bytePerRow * y) + (x * bytesPerPixel); 
			
			for (NSInteger index = 0; index < numberOfPixels; index++)
			{
				red += pixels[index].r;
				green += pixels[index].g;
				blue += pixels[index].b;
			}
			
			red /= numberOfPixels;
			green /= numberOfPixels;
			blue/= numberOfPixels;
			
			CGContextRelease(context);
			free(pixels);
		}
		
		UIColor *averageColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
		CGFloat brightness = CalculateLuminanceForColor(red, green, blue);
		
		if (block)
		{
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				block(averageColor, brightness);
			}];
		}
	}];
}

@end
