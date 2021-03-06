//
//  Settings.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectEntity;

@interface Settings : NSManagedObject {
@private
}

// core data properties
@property (nonatomic, strong) NSNumber * doLiveUpdate;
@property (nonatomic, strong) NSNumber * doBibtex;
@property (nonatomic, strong) NSNumber * doPS2PDF;
@property (nonatomic, strong) NSString * engineName;
@property (nonatomic, strong) NSString * bibtexCommand;
@property (nonatomic, strong) NSString * outputDirectory;
@property (nonatomic, strong) NSString * language;
@property (nonatomic, strong) NSNumber * nCompile;
@property (nonatomic, strong) NSNumber * openConsole;
@property (nonatomic, strong) NSNumber * showStatusBar;
@property (nonatomic, strong) NSNumber * stopOnError;
@property (nonatomic, strong) ProjectEntity *project;


@end
