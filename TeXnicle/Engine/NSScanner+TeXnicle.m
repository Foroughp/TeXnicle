//
//  NSScanner+TeXnicle.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSScanner+TeXnicle.h"

@implementation NSScanner (TeXnicle)

- (NSString*)stringForTag:(NSString*)tag
{
  NSString *tagStart = [NSString stringWithFormat:@"<%@>", tag];
  NSString *tagEnd   = [NSString stringWithFormat:@"</%@>", tag];
  [self setScanLocation:0];
  [self scanUpToString:tagStart intoString:NULL];
  NSInteger start = [self scanLocation];
  if (start<[[self string] length]) {
    start += [tagStart length];
  }
  [self scanUpToString:tagEnd intoString:NULL];
  NSInteger stop = [self scanLocation];
  if (stop > start) {
    NSString *template = [[[self string] substringWithRange:NSMakeRange(start, stop-start)] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSArray *lines = [template componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *processedLines = [NSMutableArray array];
    for (NSString *line in lines) {
      [processedLines addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    return [processedLines componentsJoinedByString:@"\n"];
  }
  
  return nil;
}

@end
