//
//  NSColor+ContrastingLabelExtensions.h

#import <Cocoa/Cocoa.h>

@interface NSColor (ContrastingLabelExtensions)

- (NSColor *)contrastingLabelColor;
- (NSString*) stringArray;
- (BOOL) isEqualToColor:(NSColor *)otherColor;

@end
