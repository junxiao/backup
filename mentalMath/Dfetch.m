//
//  Dfetch.m
//  Plistinfo
//
//  Created by Chakra on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Dfetch.h"


@implementation Dfetch

@synthesize libraryContent, libraryPlist;


- (id)initWithLibraryName:(NSString *)libraryName {
    if (self = [super init]) {
        libraryPlist = libraryName;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *path = [documentsDirectory stringByAppendingPathComponent:libraryName]; 
        
        libraryContent = [[NSMutableArray alloc] initWithContentsOfFile:path];
        [libraryContent removeObjectAtIndex:0];
    }
    return self;
}


- (NSDictionary *)libraryItemAtIndex:(int)index {
    return (libraryContent != nil && [libraryContent count] > 0 && index < [libraryContent count]) 
	? [libraryContent objectAtIndex:index]
	: nil;
}

- (int)libraryCount {
    return (libraryContent != nil) ? [libraryContent count] : 0;
}

- (void) dealloc {
    if (libraryContent) [libraryContent release];
    [super dealloc];
}


@end
