//
//  Dfetch.h
//  Plistinfo
//
//  Created by Chakra on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Dfetch : NSObject {
    NSString *libraryPlist;
    NSMutableArray *libraryContent;
}

@property (nonatomic, readonly) NSString *libraryPlist;
@property (nonatomic, readonly) NSArray *libraryContent;

- (id)initWithLibraryName:(NSString *)libraryName;
- (NSDictionary *)libraryItemAtIndex:(int)index;
- (int)libraryCount;

@end

