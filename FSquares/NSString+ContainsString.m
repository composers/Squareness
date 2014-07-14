//
//  NSString+ContainsString.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/13/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "NSString+ContainsString.h"

@implementation NSString (ContainsString)
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}
@end
