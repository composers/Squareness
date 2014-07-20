//
//  UIView+Copy.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/20/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "UIView+Copy.h"

@implementation UIView (Copy)
- (id) clone {
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}
@end
