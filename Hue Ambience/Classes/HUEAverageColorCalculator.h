//
//  HUEAverageColorCalculator.h
//  Hue Ambience
//
//  Created by Red Davis on 04/01/2014.
//  Copyright (c) 2014 Red Davis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HUEAverageColorCalculator : NSObject

- (void)calculateAverageColorAndBrightnessForImage:(UIImage *)image withCompletionBlock:(void (^)(UIColor *color, CGFloat brightness))block;

@end
